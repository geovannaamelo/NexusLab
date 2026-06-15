USE nexus_lab;

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
