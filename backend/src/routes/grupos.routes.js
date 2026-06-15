const express = require('express');
const db = require('../db');
const asyncHandler = require('../asyncHandler');

const router = express.Router();

router.get('/', asyncHandler(async (req, res) => {
  const [rows] = await db.query(`
    SELECT id_grupo, nome_grupo, descricao, data_criacao
    FROM grupos_usuarios
    ORDER BY nome_grupo
  `);
  res.json(rows);
}));

router.post('/', asyncHandler(async (req, res) => {
  const { nome_grupo, descricao } = req.body;

  if (!nome_grupo) {
    return res.status(400).json({ erro: 'O campo nome_grupo é obrigatório.' });
  }

  const [result] = await db.query(
    `INSERT INTO grupos_usuarios (nome_grupo, descricao) VALUES (?, ?)`,
    [nome_grupo, descricao || null]
  );

  res.status(201).json({ mensagem: 'Grupo cadastrado com sucesso.', result });
}));

module.exports = router;
