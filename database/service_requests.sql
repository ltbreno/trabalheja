-- Tabela para armazenar solicitações de serviços (bicos)
CREATE TABLE IF NOT EXISTS service_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  
  -- Informações do serviço
  service_description TEXT NOT NULL,
  budget DECIMAL(10, 2) NOT NULL,
  deadline_hours INTEGER NOT NULL, -- Prazo em horas
  additional_info TEXT,
  
  -- Localização do serviço
  service_latitude DECIMAL(10, 8) NOT NULL,
  service_longitude DECIMAL(11, 8) NOT NULL,
  
  -- Status do serviço
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'in_progress', 'completed', 'cancelled')),
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_service_requests_client_id ON service_requests(client_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_status ON service_requests(status);
CREATE INDEX IF NOT EXISTS idx_service_requests_location ON service_requests USING GIST (
  point(service_longitude, service_latitude)
);

-- Índice para busca por texto
CREATE INDEX IF NOT EXISTS idx_service_requests_description ON service_requests USING gin(to_tsvector('portuguese', service_description));

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_service_requests_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar updated_at
CREATE TRIGGER trigger_update_service_requests_updated_at
  BEFORE UPDATE ON service_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_service_requests_updated_at();

-- Habilitar RLS (Row Level Security)
ALTER TABLE service_requests ENABLE ROW LEVEL SECURITY;

-- Política: Clientes podem criar suas próprias solicitações
CREATE POLICY "Clients can create their own service requests"
  ON service_requests FOR INSERT
  WITH CHECK (
    auth.uid() = client_id AND
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND account_type = 'client'
    )
  );

-- Política: Clientes podem ver suas próprias solicitações
CREATE POLICY "Clients can view their own service requests"
  ON service_requests FOR SELECT
  USING (
    auth.uid() = client_id OR
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND account_type = 'freelancer'
    )
  );

-- Política: Clientes podem atualizar suas próprias solicitações (apenas se pending)
CREATE POLICY "Clients can update their own pending service requests"
  ON service_requests FOR UPDATE
  USING (
    auth.uid() = client_id AND status = 'pending'
  );

-- Política: Freelancers podem ver solicitações pending
CREATE POLICY "Freelancers can view pending service requests"
  ON service_requests FOR SELECT
  USING (
    status = 'pending' AND
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND account_type = 'freelancer'
    )
  );

-- Comentários para documentação
COMMENT ON TABLE service_requests IS 'Tabela para armazenar solicitações de serviços (bicos) criadas por clientes';
COMMENT ON COLUMN service_requests.client_id IS 'ID do cliente que criou a solicitação';
COMMENT ON COLUMN service_requests.service_description IS 'Descrição do serviço solicitado';
COMMENT ON COLUMN service_requests.budget IS 'Orçamento disponível para o serviço';
COMMENT ON COLUMN service_requests.deadline_hours IS 'Prazo para conclusão em horas';
COMMENT ON COLUMN service_requests.service_latitude IS 'Latitude da localização onde o serviço será realizado';
COMMENT ON COLUMN service_requests.service_longitude IS 'Longitude da localização onde o serviço será realizado';
COMMENT ON COLUMN service_requests.status IS 'Status da solicitação: pending, accepted, in_progress, completed, cancelled';

