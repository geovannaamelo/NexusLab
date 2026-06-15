const express = require('express');
const db = require('../db');
const asyncHandler = require('../asyncHandler');

const router = express.Router();

router.get('/', asyncHandler(async (req, res) => {
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

  res.json(rows);
}));

router.post('/', asyncHandler(async (req, res) => {
  const { id_usuario, id_laboratorio, data_reserva, hora_inicio, hora_fim } = req.body;

  if (!id_usuario || !id_laboratorio || !data_reserva || !hora_inicio || !hora_fim) {
    return res.status(400).json({ erro: 'Todos os campos são obrigatórios.' });
  }

  await db.query('CALL sp_criar_reserva(?, ?, ?, ?, ?)', [
    id_usuario,
    id_laboratorio,
    data_reserva,
    hora_inicio,
    hora_fim
  ]);

  res.status(201).json({ mensagem: 'Reserva criada com sucesso.' });
}));

router.put('/:id/cancelar', asyncHandler(async (req, res) => {
  const { id } = req.params;

  await db.query('CALL sp_cancelar_reserva(?)', [id]);

  res.json({ mensagem: 'Reserva cancelada com sucesso.' });
}));

module.exports = router;
