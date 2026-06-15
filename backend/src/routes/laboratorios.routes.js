const express = require('express');
const db = require('../db');
const asyncHandler = require('../asyncHandler');

const router = express.Router();

router.get('/', asyncHandler(async (req, res) => {
  const [rows] = await db.query(`
    SELECT id_laboratorio, nome, localizacao, capacidade, ativo, data_criacao
    FROM laboratorios
    ORDER BY nome
  `);
  res.json(rows);
}));

router.post('/', asyncHandler(async (req, res) => {
  const { nome, localizacao, capacidade } = req.body;

  if (!nome || !localizacao || !capacidade) {
    return res.status(400).json({ erro: 'Nome, localização e capacidade são obrigatórios.' });
  }

  await db.query(
    `INSERT INTO laboratorios (nome, localizacao, capacidade) VALUES (?, ?, ?)`,
    [nome, localizacao, capacidade]
  );

  res.status(201).json({ mensagem: 'Laboratório cadastrado com sucesso.' });
}));

module.exports = router;
