const express = require('express');
const db = require('../db');

const router = express.Router();

function montarErro(error) {
  return {
    message: error?.message || String(error),
    sqlMessage: error?.sqlMessage,
    code: error?.code,
    errno: error?.errno,
    sqlState: error?.sqlState,
    sql: error?.sql
  };
}

function responderErro(res, error, nomeView) {
  const erroDetalhado = montarErro(error);

  console.error(`Erro ao consultar ${nomeView}:`);
  console.error(erroDetalhado);

  return res.status(500).json({
    erro: `Não foi possível consultar a View ${nomeView}.`,
    detalhe:
      erroDetalhado.sqlMessage ||
      erroDetalhado.message ||
      'Erro não identificado no MySQL.',
    diagnostico: erroDetalhado
  });
}

router.get('/reservas-detalhadas', async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
        id_reserva,
        id_usuario,
        nome_usuario,
        email_usuario,
        id_laboratorio,
        nome_laboratorio,
        localizacao,
        data_reserva,
        hora_inicio,
        hora_fim,
        duracao_minutos,
        status,
        data_criacao
      FROM vw_reservas_detalhadas
      ORDER BY data_reserva DESC, hora_inicio DESC
    `);

    return res.json(rows);
  } catch (error) {
    return responderErro(res, error, 'vw_reservas_detalhadas');
  }
});

router.get('/ocupacao-laboratorios', async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
        id_laboratorio,
        laboratorio,
        capacidade,
        total_reservas,
        reservas_ativas,
        minutos_reservados
      FROM vw_ocupacao_laboratorios
      ORDER BY total_reservas DESC, laboratorio ASC
    `);

    return res.json(rows);
  } catch (error) {
    return responderErro(res, error, 'vw_ocupacao_laboratorios');
  }
});

router.get('/equipamentos-manutencao', async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
        laboratorio,
        id_equipamento,
        equipamento,
        numero_patrimonio,
        status_equipamento,
        manutencoes_abertas
      FROM vw_equipamentos_manutencao
      ORDER BY laboratorio ASC, equipamento ASC
    `);

    return res.json(rows);
  } catch (error) {
    return responderErro(res, error, 'vw_equipamentos_manutencao');
  }
});

router.get('/diagnostico', async (req, res) => {
  try {
    const [database] = await db.query('SELECT DATABASE() AS banco_atual');
    const [usuario] = await db.query('SELECT CURRENT_USER() AS usuario_mysql');
    const [views] = await db.query(`
      SHOW FULL TABLES
      WHERE Table_type = 'VIEW'
    `);

    res.json({
      banco_atual: database,
      usuario_mysql: usuario,
      views_encontradas: views
    });
  } catch (error) {
    res.status(500).json({
      erro: 'Erro no diagnóstico do banco.',
      diagnostico: montarErro(error)
    });
  }
});

module.exports = router;