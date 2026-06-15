USE nexus_lab;

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
        INSERT INTO usuarios_grupos (id_usuario, id_grupo)
        VALUES (v_id_usuario, p_id_grupo);
    END IF;

    SELECT v_id_usuario AS id_usuario_criado;
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
