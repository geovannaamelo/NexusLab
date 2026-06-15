const express = require('express');
const db = require('../db');
const asyncHandler = require('../asyncHandler');

const router = express.Router();

router.get('/', asyncHandler(async (req, res) => {
  const [rows] = await db.query(`
    SELECT 
      u.id_usuario,
      u.nome,
      u.email,
      u.ativo,
      u.data_criacao,
      COALESCE(GROUP_CONCAT(g.nome_grupo ORDER BY g.nome_grupo SEPARATOR ', '), 'Sem grupo') AS grupos
    FROM usuarios u
    LEFT JOIN usuarios_grupos ug ON ug.id_usuario = u.id_usuario
    LEFT JOIN grupos_usuarios g ON g.id_grupo = ug.id_grupo
    GROUP BY u.id_usuario, u.nome, u.email, u.ativo, u.data_criacao
    ORDER BY u.data_criacao DESC
  `);

  res.json(rows);
}));

router.post('/', asyncHandler(async (req, res) => {
  const { nome, email, senha, id_grupo } = req.body;

  if (!nome || !email || !senha) {
    return res.status(400).json({ erro: 'Nome, email e senha são obrigatórios.' });
  }

  await db.query('CALL sp_cadastrar_usuario(?, ?, ?, ?)', [
    nome,
    email,
    senha,
    id_grupo || null
  ]);

  res.status(201).json({ mensagem: 'Usuário cadastrado com sucesso.' });
}));

router.patch('/:id/alternar-status', asyncHandler(async (req, res) => {
  const { id } = req.params;

  await db.query(
    'UPDATE usuarios SET ativo = NOT ativo WHERE id_usuario = ?',
    [id]
  );

  res.json({ mensagem: 'Status do usuário atualizado com sucesso.' });
}));

module.exports = router;
