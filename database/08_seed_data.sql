USE nexus_lab;

INSERT INTO grupos_usuarios (nome_grupo, descricao) VALUES
('ADMINISTRADOR', 'Acesso completo ao sistema e aos relatórios.'),
('PROFESSOR', 'Pode realizar reservas e consultar laboratórios.'),
('ALUNO', 'Pode consultar reservas e laboratórios.'),
('TECNICO', 'Pode registrar manutenções e acompanhar equipamentos.'),
('CONSULTA', 'Acesso somente para visualização de dados.'),
('OPERADOR', 'Pode cadastrar e atualizar informações operacionais.'),
('COORDENADOR', 'Pode acompanhar relatórios e ocupação dos laboratórios.'),
('SUPORTE', 'Pode atuar em manutenção de equipamentos.'),
('AUDITOR', 'Pode consultar logs e relatórios.'),
('VISITANTE', 'Perfil demonstrativo com acesso restrito.');

CALL sp_cadastrar_usuario('Administrador do Sistema', 'admin@nexuslab.com', '123456', 'GRP000001');
CALL sp_cadastrar_usuario('Professor João Silva', 'joao@nexuslab.com', '123456', 'GRP000002');
CALL sp_cadastrar_usuario('Aluna Ana Souza', 'ana@nexuslab.com', '123456', 'GRP000003');
CALL sp_cadastrar_usuario('Técnico Marcos Lima', 'marcos@nexuslab.com', '123456', 'GRP000004');
CALL sp_cadastrar_usuario('Coordenadora Carla Mendes', 'carla@nexuslab.com', '123456', 'GRP000007');
CALL sp_cadastrar_usuario('Operador Pedro Alves', 'pedro@nexuslab.com', '123456', 'GRP000006');
CALL sp_cadastrar_usuario('Auditora Beatriz Rocha', 'beatriz@nexuslab.com', '123456', 'GRP000009');
CALL sp_cadastrar_usuario('Aluno Lucas Ferreira', 'lucas@nexuslab.com', '123456', 'GRP000003');
CALL sp_cadastrar_usuario('Professora Marina Castro', 'marina@nexuslab.com', '123456', 'GRP000002');
CALL sp_cadastrar_usuario('Suporte Rafael Costa', 'rafael@nexuslab.com', '123456', 'GRP000008');

INSERT INTO laboratorios (nome, localizacao, capacidade) VALUES
('Laboratório de Banco de Dados', 'Bloco A - Sala 101', 30),
('Laboratório de Redes', 'Bloco A - Sala 102', 25),
('Laboratório de Programação', 'Bloco B - Sala 203', 40),
('Laboratório de Inteligência Artificial', 'Bloco C - Sala 301', 20),
('Laboratório de Hardware', 'Bloco D - Sala 110', 18),
('Laboratório de Sistemas Web', 'Bloco B - Sala 204', 35),
('Laboratório de Engenharia de Software', 'Bloco C - Sala 210', 28),
('Laboratório de Segurança da Informação', 'Bloco E - Sala 115', 22),
('Laboratório de Computação Gráfica', 'Bloco F - Sala 305', 24),
('Laboratório Maker', 'Bloco G - Sala 001', 16);

INSERT INTO equipamentos (id_laboratorio, nome, numero_patrimonio, status) VALUES
('LAB000001', 'Servidor MySQL Principal', 'PAT-DB-001', 'DISPONIVEL'),
('LAB000001', 'Projetor Multimídia', 'PAT-DB-002', 'DISPONIVEL'),
('LAB000002', 'Switch Gerenciável', 'PAT-RD-001', 'DISPONIVEL'),
('LAB000003', 'Estação de Desenvolvimento 01', 'PAT-PR-001', 'DISPONIVEL'),
('LAB000003', 'Estação de Desenvolvimento 02', 'PAT-PR-002', 'DISPONIVEL'),
('LAB000004', 'GPU Workstation', 'PAT-IA-001', 'DISPONIVEL'),
('LAB000005', 'Kit Arduino', 'PAT-HW-001', 'DISPONIVEL'),
('LAB000006', 'Servidor Web de Testes', 'PAT-WEB-001', 'DISPONIVEL'),
('LAB000008', 'Firewall de Laboratório', 'PAT-SEG-001', 'DISPONIVEL'),
('LAB000010', 'Impressora 3D', 'PAT-MK-001', 'DISPONIVEL');

CALL sp_criar_reserva('USR000002', 'LAB000001', CURDATE(), '08:00:00', '10:00:00');
CALL sp_criar_reserva('USR000003', 'LAB000003', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '10:00:00', '12:00:00');
CALL sp_criar_reserva('USR000005', 'LAB000004', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '14:00:00', '16:00:00');
CALL sp_criar_reserva('USR000009', 'LAB000006', DATE_ADD(CURDATE(), INTERVAL 3 DAY), '09:00:00', '11:00:00');
CALL sp_criar_reserva('USR000006', 'LAB000010', DATE_ADD(CURDATE(), INTERVAL 4 DAY), '13:30:00', '15:00:00');

INSERT INTO manutencoes (id_equipamento, descricao, status) VALUES
('EQP000010', 'Verificação de calibração da impressora 3D.', 'ABERTA');
