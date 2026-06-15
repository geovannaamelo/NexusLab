const express = require('express');
const db = require('../db');
const asyncHandler = require('../asyncHandler');

const router = express.Router();

router.get('/', asyncHandler(async (req, res) => {
  const [rows] = await db.query(`
    SELECT 
      e.id_equipamento,
      e.nome,
      e.numero_patrimonio,
      e.status,
      e.data_criacao,
      l.nome AS laboratorio
    FROM equipamentos e
    INNER JOIN laboratorios l ON l.id_laboratorio = e.id_laboratorio
    ORDER BY e.nome
  `);
  res.json(rows);
}));

router.post('/', asyncHandler(async (req, res) => {
  const { id_laboratorio, nome, numero_patrimonio, status } = req.body;

  if (!id_laboratorio || !nome || !numero_patrimonio) {
    return res.status(400).json({ erro: 'Laboratório, nome e patrimônio são obrigatórios.' });
  }

  await db.query(
    `INSERT INTO equipamentos (id_laboratorio, nome, numero_patrimonio, status) VALUES (?, ?, ?, ?)`,
    [id_laboratorio, nome, numero_patrimonio, status || 'DISPONIVEL']
  );

  res.status(201).json({ mensagem: 'Equipamento cadastrado com sucesso.' });
}));

module.exports = router;
