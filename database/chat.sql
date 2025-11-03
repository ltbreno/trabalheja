-- Tabela para armazenar conversas entre usuários
CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant1_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  participant2_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  
  -- Relacionamento com proposta aceita (opcional)
  proposal_id UUID REFERENCES proposals(id) ON DELETE SET NULL,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraint: Uma conversa única entre dois participantes
  CONSTRAINT unique_conversation UNIQUE (participant1_id, participant2_id),
  -- Garantir que participant1_id < participant2_id para evitar duplicatas
  CONSTRAINT check_participants_order CHECK (participant1_id < participant2_id)
);

-- Tabela para armazenar mensagens
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  read_at TIMESTAMP WITH TIME ZONE -- Quando a mensagem foi lida
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_conversations_participant1 ON conversations(participant1_id);
CREATE INDEX IF NOT EXISTS idx_conversations_participant2 ON conversations(participant2_id);
CREATE INDEX IF NOT EXISTS idx_conversations_updated_at ON conversations(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_read_at ON messages(read_at) WHERE read_at IS NULL;

-- Função para atualizar updated_at da conversa automaticamente
CREATE OR REPLACE FUNCTION update_conversation_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE conversations
  SET updated_at = NOW()
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar updated_at quando uma mensagem é criada
CREATE TRIGGER trigger_update_conversation_on_message
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION update_conversation_updated_at();

-- Função para validar que o sender é um participante da conversa
CREATE OR REPLACE FUNCTION validate_message_sender()
RETURNS TRIGGER AS $$
BEGIN
  -- Verificar se o sender é um dos participantes da conversa
  IF NOT EXISTS (
    SELECT 1 FROM conversations c
    WHERE c.id = NEW.conversation_id
    AND (c.participant1_id = NEW.sender_id OR c.participant2_id = NEW.sender_id)
  ) THEN
    RAISE EXCEPTION 'O remetente deve ser um participante da conversa';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar sender antes de inserir mensagem
CREATE TRIGGER trigger_validate_message_sender
  BEFORE INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION validate_message_sender();

-- Habilitar RLS (Row Level Security)
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Política: Usuários podem ver conversas onde são participantes
CREATE POLICY "Users can view their own conversations"
  ON conversations FOR SELECT
  USING (
    participant1_id = auth.uid() OR participant2_id = auth.uid()
  );

-- Política: Usuários podem criar conversas onde são participantes
CREATE POLICY "Users can create conversations where they are participants"
  ON conversations FOR INSERT
  WITH CHECK (
    participant1_id = auth.uid() OR participant2_id = auth.uid()
  );

-- Política: Usuários podem ver mensagens de suas conversas
CREATE POLICY "Users can view messages from their conversations"
  ON messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM conversations c
      WHERE c.id = messages.conversation_id
      AND (c.participant1_id = auth.uid() OR c.participant2_id = auth.uid())
    )
  );

-- Política: Usuários podem enviar mensagens em suas conversas
CREATE POLICY "Users can send messages in their conversations"
  ON messages FOR INSERT
  WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM conversations c
      WHERE c.id = messages.conversation_id
      AND (c.participant1_id = auth.uid() OR c.participant2_id = auth.uid())
    )
  );

-- Política: Usuários podem atualizar suas próprias mensagens (para marcar como lida)
CREATE POLICY "Users can update messages in their conversations"
  ON messages FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM conversations c
      WHERE c.id = messages.conversation_id
      AND (c.participant1_id = auth.uid() OR c.participant2_id = auth.uid())
    )
  );

-- Habilitar Realtime para mensagens
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- Comentários para documentação
COMMENT ON TABLE conversations IS 'Tabela para armazenar conversas entre usuários (cliente e freelancer)';
COMMENT ON COLUMN conversations.participant1_id IS 'ID do primeiro participante (menor ID)';
COMMENT ON COLUMN conversations.participant2_id IS 'ID do segundo participante (maior ID)';
COMMENT ON COLUMN conversations.proposal_id IS 'ID da proposta aceita que gerou esta conversa (opcional)';
COMMENT ON TABLE messages IS 'Tabela para armazenar mensagens das conversas';
COMMENT ON COLUMN messages.conversation_id IS 'ID da conversa à qual a mensagem pertence';
COMMENT ON COLUMN messages.sender_id IS 'ID do usuário que enviou a mensagem';
COMMENT ON COLUMN messages.content IS 'Conteúdo da mensagem';
COMMENT ON COLUMN messages.read_at IS 'Timestamp de quando a mensagem foi lida (NULL = não lida)';

