USE nexus_lab;

CREATE OR REPLACE VIEW vw_reservas_detalhadas AS
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
INNER JOIN usuarios u ON u.id_usuario = r.id_usuario
INNER JOIN laboratorios l ON l.id_laboratorio = r.id_laboratorio;

CREATE OR REPLACE VIEW vw_ocupacao_laboratorios AS
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
LEFT JOIN reservas r ON r.id_laboratorio = l.id_laboratorio
GROUP BY l.id_laboratorio, l.nome, l.capacidade;

CREATE OR REPLACE VIEW vw_equipamentos_manutencao AS
SELECT
    l.nome AS laboratorio,
    e.id_equipamento,
    e.nome AS equipamento,
    e.numero_patrimonio,
    e.status AS status_equipamento,
    COUNT(CASE WHEN m.status <> 'CONCLUIDA' THEN m.id_manutencao END) AS manutencoes_abertas
FROM equipamentos e
INNER JOIN laboratorios l ON l.id_laboratorio = e.id_laboratorio
LEFT JOIN manutencoes m ON m.id_equipamento = e.id_equipamento
GROUP BY l.nome, e.id_equipamento, e.nome, e.numero_patrimonio, e.status;
