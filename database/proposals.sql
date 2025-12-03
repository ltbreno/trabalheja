-- Tabela para armazenar propostas de freelancers para serviços
CREATE TABLE IF NOT EXISTS proposals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_request_id UUID NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
  freelancer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  
  -- Informações da proposta
  proposed_price DECIMAL(10, 2) NOT NULL,
  availability_value INTEGER NOT NULL,
  availability_unit TEXT NOT NULL CHECK (availability_unit IN ('Horas', 'Dias', 'Semanas', 'Meses')),
  message TEXT,
  
  -- Status da proposta
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'cancelled')),
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraint: Um freelancer pode enviar apenas uma proposta por serviço
  CONSTRAINT unique_freelancer_service_request UNIQUE (freelancer_id, service_request_id)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_proposals_service_request_id ON proposals(service_request_id);
CREATE INDEX IF NOT EXISTS idx_proposals_freelancer_id ON proposals(freelancer_id);
CREATE INDEX IF NOT EXISTS idx_proposals_status ON proposals(status);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_proposals_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar updated_at
CREATE TRIGGER trigger_update_proposals_updated_at
  BEFORE UPDATE ON proposals
  FOR EACH ROW
  EXECUTE FUNCTION update_proposals_updated_at();

-- Habilitar RLS (Row Level Security)
ALTER TABLE proposals ENABLE ROW LEVEL SECURITY;

-- Política: Freelancers podem criar suas próprias propostas
CREATE POLICY "Freelancers can create their own proposals"
  ON proposals FOR INSERT
  WITH CHECK (
    auth.uid() = freelancer_id AND
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND account_type = 'freelancer'
    ) AND
    EXISTS (
      SELECT 1 FROM service_requests 
      WHERE id = service_request_id AND status = 'pending'
    )
  );

-- Política: Freelancers podem ver suas próprias propostas
CREATE POLICY "Freelancers can view their own proposals"
  ON proposals FOR SELECT
  USING (
    auth.uid() = freelancer_id OR
    EXISTS (
      SELECT 1 FROM service_requests sr
      JOIN profiles p ON sr.client_id = p.id
      WHERE sr.id = proposals.service_request_id 
      AND p.id = auth.uid()
      AND p.account_type = 'client'
    )
  );

-- Política: Clientes podem ver propostas de seus serviços
CREATE POLICY "Clients can view proposals for their service requests"
  ON proposals FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM service_requests sr
      JOIN profiles p ON sr.client_id = p.id
      WHERE sr.id = proposals.service_request_id 
      AND p.id = auth.uid()
      AND p.account_type = 'client'
    )
  );

-- Política: Freelancers podem atualizar suas próprias propostas (apenas se pending)
CREATE POLICY "Freelancers can update their own pending proposals"
  ON proposals FOR UPDATE
  USING (
    auth.uid() = freelancer_id AND status = 'pending'
  );

-- Política: Clientes podem atualizar status das propostas de seus serviços
CREATE POLICY "Clients can update proposal status for their service requests"
  ON proposals FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM service_requests sr
      JOIN profiles p ON sr.client_id = p.id
      WHERE sr.id = proposals.service_request_id 
      AND p.id = auth.uid()
      AND p.account_type = 'client'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM service_requests sr
      JOIN profiles p ON sr.client_id = p.id
      WHERE sr.id = proposals.service_request_id 
      AND p.id = auth.uid()
      AND p.account_type = 'client'
    )
  );

-- Comentários para documentação
COMMENT ON TABLE proposals IS 'Tabela para armazenar propostas de freelancers para serviços';
COMMENT ON COLUMN proposals.service_request_id IS 'ID do serviço solicitado pelo cliente';
COMMENT ON COLUMN proposals.freelancer_id IS 'ID do freelancer que enviou a proposta';
COMMENT ON COLUMN proposals.proposed_price IS 'Valor proposto pelo freelancer para realizar o serviço';
COMMENT ON COLUMN proposals.availability_value IS 'Valor numérico da disponibilidade (ex: 5)';
COMMENT ON COLUMN proposals.availability_unit IS 'Unidade de tempo da disponibilidade (Horas, Dias, Semanas, Meses)';
COMMENT ON COLUMN proposals.message IS 'Mensagem personalizada do freelancer para o cliente';
COMMENT ON COLUMN proposals.status IS 'Status da proposta: pending, accepted, rejected, cancelled';

