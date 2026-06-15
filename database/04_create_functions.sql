USE nexus_lab;

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
