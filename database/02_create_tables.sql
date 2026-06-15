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
