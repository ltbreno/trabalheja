-- Script para popular a tabela service_requests com dados de teste
-- Usando as coordenadas próximas ao CEP 58045-100 (João Pessoa - PB)
-- Baseado nas coordenadas: -7.1204843, -34.8286778 e -7.1205064, -34.8286653

-- Certifique-se de que os IDs de clientes existem na tabela profiles
-- Se não existirem, você precisará criar perfis de clientes primeiro

INSERT INTO service_requests (
  client_id,
  service_description,
  budget,
  deadline_hours,
  additional_info,
  service_latitude,
  service_longitude,
  status
) VALUES
-- Cliente 1: e0f4db28-519b-4270-9ae9-3cfc4dcfb057
('e0f4db28-519b-4270-9ae9-3cfc4dcfb057', 'Trocar chuveiro', 150.00, 4, 'Chuveiro já comprado, só instalar. Fiação pronta.', -7.1204843, -34.8286778, 'pending'),
('e0f4db28-519b-4270-9ae9-3cfc4dcfb057', 'Montagem de armário', 300.00, 8, 'Armário de 6 portas, manual incluso. Precisa montar no quarto.', -7.1202000, -34.8285500, 'pending'),
('e0f4db28-519b-4270-9ae9-3cfc4dcfb057', 'Reparo elétrico', 180.00, 5, 'Tomada soltando faísca. Preciso de alguém qualificado.', -7.1209500, -34.8290500, 'pending'),
('e0f4db28-519b-4270-9ae9-3cfc4dcfb057', 'Instalar ventilador de teto', 200.00, 6, 'Fiação já está pronta, só precisa instalar o ventilador.', -7.1203200, -34.8281200, 'pending'),
('e0f4db28-519b-4270-9ae9-3cfc4dcfb057', 'Higienização de sofá', 220.00, 6, 'Sofá de 3 lugares, precisa de limpeza profunda.', -7.1208300, -34.8284000, 'pending'),
('e0f4db28-519b-4270-9ae9-3cfc4dcfb057', 'Troca de torneira', 140.00, 3, 'Torneira da pia com vazamento constante.', -7.1202700, -34.8287800, 'pending'),

-- Cliente 2: 56669cae-b832-4cc5-a830-166b4f8b0293
('56669cae-b832-4cc5-a830-166b4f8b0293', 'Instalar prateleira', 120.00, 6, 'Parede de alvenaria, preciso instalar 2 prateleiras na sala.', -7.1205064, -34.8286653, 'pending'),
('56669cae-b832-4cc5-a830-166b4f8b0293', 'Pintura de quarto', 450.00, 24, 'Quarto de 3x4 metros, tinta já foi comprada. Precisa preparar parede e pintar.', -7.1207500, -34.8289000, 'pending'),
('56669cae-b832-4cc5-a830-166b4f8b0293', 'Limpeza pós-obra', 350.00, 10, 'Apartamento pequeno, precisa limpar sala e cozinha após reforma.', -7.1201000, -34.8283000, 'pending'),
('56669cae-b832-4cc5-a830-166b4f8b0293', 'Conserto de porta', 130.00, 6, 'Porta da sala desalinhada, não fecha direito. Precisa ajustar dobradiças.', -7.1206200, -34.8282500, 'pending'),
('56669cae-b832-4cc5-a830-166b4f8b0293', 'Instalação de luminárias', 160.00, 4, 'Preciso instalar 2 luminárias no corredor. Fiação já está pronta.', -7.1205800, -34.8289500, 'pending'),
('56669cae-b832-4cc5-a830-166b4f8b0293', 'Pequenos reparos gerais', 250.00, 12, 'Vazamento leve no banheiro e vedação do box. Dois problemas pequenos.', -7.1204100, -34.8284900, 'pending');

-- Verificar se os dados foram inseridos
SELECT 
  sr.id,
  sr.service_description,
  sr.budget,
  p.full_name as cliente,
  sr.service_latitude,
  sr.service_longitude,
  sr.status
FROM service_requests sr
JOIN profiles p ON sr.client_id = p.id
ORDER BY sr.created_at DESC;

