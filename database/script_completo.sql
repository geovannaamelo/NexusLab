DROP DATABASE IF EXISTS nexus_lab;

CREATE DATABASE nexus_lab
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE nexus_lab;

CREATE TABLE controle_ids (
    entidade VARCHAR(50) PRIMARY KEY,
    ultimo_valor INT NOT NULL DEFAULT 0
);

INSERT INTO controle_ids (entidade, ultimo_valor) VALUES
('USUARIO', 0),
('GRUPO', 0),
('LABORATORIO', 0),
('EQUIPAMENTO', 0),
('RESERVA', 0),
('MANUTENCAO', 0),
('LOG', 0);

CREATE TABLE grupos_usuarios (
    id_grupo VARCHAR(20) PRIMARY KEY,
    nome_grupo VARCHAR(80) NOT NULL,
    descricao VARCHAR(255),
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_grupos_nome UNIQUE (nome_grupo)
);

CREATE TABLE usuarios (
    id_usuario VARCHAR(20) PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL,
    senha_hash VARCHAR(256) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_usuarios_email UNIQUE (email)
);

CREATE TABLE usuarios_grupos (
    id_usuario VARCHAR(20) NOT NULL,
    id_grupo VARCHAR(20) NOT NULL,
    data_vinculo TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_grupo),
    CONSTRAINT fk_usuarios_grupos_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    CONSTRAINT fk_usuarios_grupos_grupo
        FOREIGN KEY (id_grupo) REFERENCES grupos_usuarios(id_grupo)
);

CREATE TABLE laboratorios (
    id_laboratorio VARCHAR(20) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    localizacao VARCHAR(120) NOT NULL,
    capacidade INT NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_laboratorios_nome UNIQUE (nome),
    CONSTRAINT ck_laboratorios_capacidade CHECK (capacidade > 0)
);

CREATE TABLE equipamentos (
    id_equipamento VARCHAR(20) PRIMARY KEY,
    id_laboratorio VARCHAR(20) NOT NULL,
    nome VARCHAR(120) NOT NULL,
    numero_patrimonio VARCHAR(60) NOT NULL,
    status ENUM('DISPONIVEL', 'MANUTENCAO', 'INATIVO') NOT NULL DEFAULT 'DISPONIVEL',
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_equipamentos_patrimonio UNIQUE (numero_patrimonio),
    CONSTRAINT fk_equipamentos_laboratorio
        FOREIGN KEY (id_laboratorio) REFERENCES laboratorios(id_laboratorio)
);

CREATE TABLE reservas (
    id_reserva VARCHAR(20) PRIMARY KEY,
    id_usuario VARCHAR(20) NOT NULL,
    id_laboratorio VARCHAR(20) NOT NULL,
    data_reserva DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    status ENUM('ATIVA', 'CANCELADA', 'FINALIZADA') NOT NULL DEFAULT 'ATIVA',
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reservas_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    CONSTRAINT fk_reservas_laboratorio
        FOREIGN KEY (id_laboratorio) REFERENCES laboratorios(id_laboratorio),
    CONSTRAINT ck_reservas_horario CHECK (hora_fim > hora_inicio)
);

CREATE TABLE manutencoes (
    id_manutencao VARCHAR(20) PRIMARY KEY,
    id_equipamento VARCHAR(20) NOT NULL,
    descricao TEXT NOT NULL,
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_fechamento TIMESTAMP NULL,
    status ENUM('ABERTA', 'EM_ANDAMENTO', 'CONCLUIDA') NOT NULL DEFAULT 'ABERTA',
    CONSTRAINT fk_manutencoes_equipamento
        FOREIGN KEY (id_equipamento) REFERENCES equipamentos(id_equipamento)
);

CREATE TABLE logs_auditoria (
    id_log VARCHAR(20) PRIMARY KEY,
    tabela_afetada VARCHAR(80) NOT NULL,
    acao VARCHAR(30) NOT NULL,
    descricao VARCHAR(500) NOT NULL,
    data_evento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_usuarios_nome ON usuarios(nome);
CREATE INDEX idx_reservas_laboratorio_data ON reservas(id_laboratorio, data_reserva);
CREATE INDEX idx_reservas_usuario ON reservas(id_usuario);
CREATE INDEX idx_reservas_status ON reservas(status);
CREATE INDEX idx_equipamentos_laboratorio ON equipamentos(id_laboratorio);
CREATE INDEX idx_manutencoes_status ON manutencoes(status);
CREATE INDEX idx_logs_tabela_acao ON logs_auditoria(tabela_afetada, acao);

DELIMITER $$

CREATE FUNCTION fn_gerar_id_usuario()
RETURNS VARCHAR(20)
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE novo_valor INT;

    UPDATE controle_ids
    SET ultimo_valor = LAST_INSERT_ID(ultimo_valor + 1)
    WHERE entidade = 'USUARIO';

    SET novo_valor = LAST_INSERT_ID();

    RETURN CONCAT('USR', LPAD(novo_valor, 6, '0'));
END$$

CREATE FUNCTION fn_gerar_id_grupo()
RETURNS VARCHAR(20)
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE novo_valor INT;

    UPDATE controle_ids
    SET ultimo_valor = LAST_INSERT_ID(ultimo_valor + 1)
    WHERE entidade = 'GRUPO';

    SET novo_valor = LAST_INSERT_ID();

    RETURN CONCAT('GRP', LPAD(novo_valor, 6, '0'));
END$$

CREATE FUNCTION fn_gerar_id_laboratorio()
RETURNS VARCHAR(20)
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE novo_valor INT;

    UPDATE controle_ids
    SET ultimo_valor = LAST_INSERT_ID(ultimo_valor + 1)
    WHERE entidade = 'LABORATORIO';

    SET novo_valor = LAST_INSERT_ID();

    RETURN CONCAT('LAB', LPAD(novo_valor, 6, '0'));
END$$

CREATE FUNCTION fn_gerar_id_equipamento()
RETURNS VARCHAR(20)
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE novo_valor INT;

    UPDATE controle_ids
    SET ultimo_valor = LAST_INSERT_ID(ultimo_valor + 1)
    WHERE entidade = 'EQUIPAMENTO';

    SET novo_valor = LAST_INSERT_ID();

    RETURN CONCAT('EQP', LPAD(novo_valor, 6, '0'));
END$$

CREATE FUNCTION fn_gerar_id_reserva()
RETURNS VARCHAR(20)
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE novo_valor INT;

    UPDATE controle_ids
    SET ultimo_valor = LAST_INSERT_ID(ultimo_valor + 1)
    WHERE entidade = 'RESERVA';

    SET novo_valor = LAST_INSERT_ID();

    RETURN CONCAT('RES', LPAD(novo_valor, 6, '0'));
END$$

CREATE FUNCTION fn_gerar_id_manutencao()
RETURNS VARCHAR(20)
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE novo_valor INT;

    UPDATE controle_ids
    SET ultimo_valor = LAST_INSERT_ID(ultimo_valor + 1)
    WHERE entidade = 'MANUTENCAO';

    SET novo_valor = LAST_INSERT_ID();

    RETURN CONCAT('MAN', LPAD(novo_valor, 6, '0'));
END$$

CREATE FUNCTION fn_gerar_id_log()
RETURNS VARCHAR(20)
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE novo_valor INT;

    UPDATE controle_ids
    SET ultimo_valor = LAST_INSERT_ID(ultimo_valor + 1)
    WHERE entidade = 'LOG';

    SET novo_valor = LAST_INSERT_ID();

    RETURN CONCAT('LOG', LPAD(novo_valor, 6, '0'));
END$$

CREATE FUNCTION fn_duracao_reserva(
    p_hora_inicio TIME,
    p_hora_fim TIME
)
RETURNS INT
DETERMINISTIC
NO SQL
BEGIN
    RETURN FLOOR(TIME_TO_SEC(TIMEDIFF(p_hora_fim, p_hora_inicio)) / 60);
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_grupos_before_insert
BEFORE INSERT ON grupos_usuarios
FOR EACH ROW
BEGIN
    IF NEW.id_grupo IS NULL OR NEW.id_grupo = '' THEN
        SET NEW.id_grupo = fn_gerar_id_grupo();
    END IF;
END$$

CREATE TRIGGER trg_usuarios_before_insert
BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
    IF NEW.id_usuario IS NULL OR NEW.id_usuario = '' THEN
        SET NEW.id_usuario = fn_gerar_id_usuario();
    END IF;
END$$

CREATE TRIGGER trg_laboratorios_before_insert
BEFORE INSERT ON laboratorios
FOR EACH ROW
BEGIN
    IF NEW.id_laboratorio IS NULL OR NEW.id_laboratorio = '' THEN
        SET NEW.id_laboratorio = fn_gerar_id_laboratorio();
    END IF;
END$$

CREATE TRIGGER trg_equipamentos_before_insert
BEFORE INSERT ON equipamentos
FOR EACH ROW
BEGIN
    IF NEW.id_equipamento IS NULL OR NEW.id_equipamento = '' THEN
        SET NEW.id_equipamento = fn_gerar_id_equipamento();
    END IF;
END$$

CREATE TRIGGER trg_reservas_before_insert
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    IF NEW.id_reserva IS NULL OR NEW.id_reserva = '' THEN
        SET NEW.id_reserva = fn_gerar_id_reserva();
    END IF;

    IF NEW.hora_fim <= NEW.hora_inicio THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A hora final da reserva deve ser maior que a hora inicial.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM reservas
        WHERE id_laboratorio = NEW.id_laboratorio
          AND data_reserva = NEW.data_reserva
          AND status <> 'CANCELADA'
          AND NEW.hora_inicio < hora_fim
          AND NEW.hora_fim > hora_inicio
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Já existe uma reserva para este laboratório neste horário.';
    END IF;
END$$

CREATE TRIGGER trg_manutencoes_before_insert
BEFORE INSERT ON manutencoes
FOR EACH ROW
BEGIN
    IF NEW.id_manutencao IS NULL OR NEW.id_manutencao = '' THEN
        SET NEW.id_manutencao = fn_gerar_id_manutencao();
    END IF;
END$$

CREATE TRIGGER trg_logs_before_insert
BEFORE INSERT ON logs_auditoria
FOR EACH ROW
BEGIN
    IF NEW.id_log IS NULL OR NEW.id_log = '' THEN
        SET NEW.id_log = fn_gerar_id_log();
    END IF;
END$$

CREATE TRIGGER trg_reservas_after_insert
AFTER INSERT ON reservas
FOR EACH ROW
BEGIN
    INSERT INTO logs_auditoria (
        tabela_afetada,
        acao,
        descricao
    ) VALUES (
        'reservas',
        'INSERT',
        CONCAT('Reserva criada: ', NEW.id_reserva, ' para o laboratório ', NEW.id_laboratorio)
    );
END$$

CREATE TRIGGER trg_reservas_after_update
AFTER UPDATE ON reservas
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO logs_auditoria (
            tabela_afetada,
            acao,
            descricao
        ) VALUES (
            'reservas',
            'UPDATE',
            CONCAT('Reserva ', NEW.id_reserva, ' alterada de ', OLD.status, ' para ', NEW.status)
        );
    END IF;
END$$

CREATE TRIGGER trg_manutencoes_after_insert
AFTER INSERT ON manutencoes
FOR EACH ROW
BEGIN
    UPDATE equipamentos
    SET status = 'MANUTENCAO'
    WHERE id_equipamento = NEW.id_equipamento;

    INSERT INTO logs_auditoria (
        tabela_afetada,
        acao,
        descricao
    ) VALUES (
        'manutencoes',
        'INSERT',
        CONCAT('Manutenção aberta: ', NEW.id_manutencao, ' para o equipamento ', NEW.id_equipamento)
    );
END$$

DELIMITER ;

CREATE OR REPLACE SQL SECURITY INVOKER VIEW vw_reservas_detalhadas AS
SELECT 
    r.id_reserva,
    u.id_usuario,
    u.nome AS nome_usuario,
    u.email AS email_usuario,
    l.id_laboratorio,
    l.nome AS nome_laboratorio,
    l.localizacao,
    r.data_reserva,
    r.hora_inicio,
    r.hora_fim,
    fn_duracao_reserva(r.hora_inicio, r.hora_fim) AS duracao_minutos,
    r.status,
    r.data_criacao
FROM reservas r
INNER JOIN usuarios u 
    ON u.id_usuario = r.id_usuario
INNER JOIN laboratorios l 
    ON l.id_laboratorio = r.id_laboratorio;

CREATE OR REPLACE SQL SECURITY INVOKER VIEW vw_ocupacao_laboratorios AS
SELECT 
    l.id_laboratorio,
    l.nome AS laboratorio,
    l.capacidade,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(CASE WHEN r.status = 'ATIVA' THEN 1 ELSE 0 END) AS reservas_ativas,
    COALESCE(SUM(CASE 
        WHEN r.status <> 'CANCELADA' THEN fn_duracao_reserva(r.hora_inicio, r.hora_fim)
        ELSE 0
    END), 0) AS minutos_reservados
FROM laboratorios l
LEFT JOIN reservas r 
    ON r.id_laboratorio = l.id_laboratorio
GROUP BY 
    l.id_laboratorio,
    l.nome,
    l.capacidade;

CREATE OR REPLACE SQL SECURITY INVOKER VIEW vw_equipamentos_manutencao AS
SELECT
    l.nome AS laboratorio,
    e.id_equipamento,
    e.nome AS equipamento,
    e.numero_patrimonio,
    e.status AS status_equipamento,
    COUNT(CASE 
        WHEN m.status <> 'CONCLUIDA' THEN m.id_manutencao 
    END) AS manutencoes_abertas
FROM equipamentos e
INNER JOIN laboratorios l 
    ON l.id_laboratorio = e.id_laboratorio
LEFT JOIN manutencoes m 
    ON m.id_equipamento = e.id_equipamento
GROUP BY 
    l.nome,
    e.id_equipamento,
    e.nome,
    e.numero_patrimonio,
    e.status;

DELIMITER $$

CREATE PROCEDURE sp_cadastrar_usuario(
    IN p_nome VARCHAR(120),
    IN p_email VARCHAR(120),
    IN p_senha VARCHAR(120),
    IN p_id_grupo VARCHAR(20)
)
BEGIN
    DECLARE v_id_usuario VARCHAR(20);

    SET v_id_usuario = fn_gerar_id_usuario();

    INSERT INTO usuarios (
        id_usuario,
        nome,
        email,
        senha_hash,
        ativo
    ) VALUES (
        v_id_usuario,
        p_nome,
        p_email,
        SHA2(p_senha, 256),
        TRUE
    );

    IF p_id_grupo IS NOT NULL AND p_id_grupo <> '' THEN
        INSERT INTO usuarios_grupos (
            id_usuario,
            id_grupo
        ) VALUES (
            v_id_usuario,
            p_id_grupo
        );
    END IF;
END$$

CREATE PROCEDURE sp_criar_reserva(
    IN p_id_usuario VARCHAR(20),
    IN p_id_laboratorio VARCHAR(20),
    IN p_data_reserva DATE,
    IN p_hora_inicio TIME,
    IN p_hora_fim TIME
)
BEGIN
    INSERT INTO reservas (
        id_usuario,
        id_laboratorio,
        data_reserva,
        hora_inicio,
        hora_fim,
        status
    ) VALUES (
        p_id_usuario,
        p_id_laboratorio,
        p_data_reserva,
        p_hora_inicio,
        p_hora_fim,
        'ATIVA'
    );
END$$

CREATE PROCEDURE sp_cancelar_reserva(
    IN p_id_reserva VARCHAR(20)
)
BEGIN
    UPDATE reservas
    SET status = 'CANCELADA'
    WHERE id_reserva = p_id_reserva
      AND status = 'ATIVA';
END$$

CREATE PROCEDURE sp_concluir_manutencao(
    IN p_id_manutencao VARCHAR(20)
)
BEGIN
    DECLARE v_id_equipamento VARCHAR(20);

    SELECT id_equipamento INTO v_id_equipamento
    FROM manutencoes
    WHERE id_manutencao = p_id_manutencao;

    UPDATE manutencoes
    SET status = 'CONCLUIDA',
        data_fechamento = CURRENT_TIMESTAMP
    WHERE id_manutencao = p_id_manutencao;

    IF NOT EXISTS (
        SELECT 1
        FROM manutencoes
        WHERE id_equipamento = v_id_equipamento
          AND status <> 'CONCLUIDA'
    ) THEN
        UPDATE equipamentos
        SET status = 'DISPONIVEL'
        WHERE id_equipamento = v_id_equipamento;
    END IF;
END$$

DELIMITER ;

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

DROP USER IF EXISTS 'app_admin'@'localhost';
DROP USER IF EXISTS 'app_operador'@'localhost';
DROP USER IF EXISTS 'app_consulta'@'localhost';

DROP USER IF EXISTS 'app_admin'@'127.0.0.1';
DROP USER IF EXISTS 'app_operador'@'127.0.0.1';
DROP USER IF EXISTS 'app_consulta'@'127.0.0.1';

CREATE USER 'app_admin'@'localhost' IDENTIFIED BY 'Admin@123';
CREATE USER 'app_operador'@'localhost' IDENTIFIED BY 'Operador@123';
CREATE USER 'app_consulta'@'localhost' IDENTIFIED BY 'Consulta@123';

CREATE USER 'app_admin'@'127.0.0.1' IDENTIFIED BY 'Admin@123';
CREATE USER 'app_operador'@'127.0.0.1' IDENTIFIED BY 'Operador@123';
CREATE USER 'app_consulta'@'127.0.0.1' IDENTIFIED BY 'Consulta@123';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON nexus_lab.* TO 'app_admin'@'localhost';
GRANT SELECT, INSERT, UPDATE, EXECUTE ON nexus_lab.* TO 'app_operador'@'localhost';
GRANT SELECT ON nexus_lab.* TO 'app_consulta'@'localhost';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON nexus_lab.* TO 'app_admin'@'127.0.0.1';
GRANT SELECT, INSERT, UPDATE, EXECUTE ON nexus_lab.* TO 'app_operador'@'127.0.0.1';
GRANT SELECT ON nexus_lab.* TO 'app_consulta'@'127.0.0.1';

FLUSH PRIVILEGES;