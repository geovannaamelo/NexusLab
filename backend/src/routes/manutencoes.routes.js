/*
  Importa o Express.

  O Express é a biblioteca usada para criar as rotas da API.
  Neste arquivo, vamos criar as rotas relacionadas às manutenções.
*/
const express = require('express');

/*
  Importa a conexão com o banco de dados MySQL.

  O arquivo db.js cria a conexão usando mysql2.
  Com esse objeto "db", conseguimos executar comandos SQL no banco.
*/
const db = require('../db');

/*
  Importa o asyncHandler.

  Ele serve para capturar erros automaticamente em funções assíncronas.
  Assim, se uma consulta ao banco falhar, o erro será tratado pelo servidor.
*/
const asyncHandler = require('../asyncHandler');

/*
  Cria um roteador do Express.

  Esse router será usado apenas para as rotas de manutenções.
*/
const router = express.Router();

/*
  Rota GET /

  Como no server.js essa rota é registrada assim:

  app.use('/api/manutencoes', manutencoesRoutes);

  então este router.get('/') representa:

  GET /api/manutencoes

  Essa rota lista todas as manutenções cadastradas no sistema.
*/
router.get('/', asyncHandler(async (req, res) => {
  /*
    Consulta SQL que busca as manutenções.

    Aqui usamos INNER JOIN porque cada manutenção pertence a um equipamento.

    A tabela manutencoes possui o campo id_equipamento.
    Esse campo se relaciona com a tabela equipamentos.

    Assim conseguimos mostrar:
    - dados da manutenção;
    - nome do equipamento;
    - número de patrimônio do equipamento.
  */
  const [rows] = await db.query(`
    SELECT 
      m.id_manutencao,
      m.descricao,
      m.data_abertura,
      m.data_fechamento,
      m.status,
      e.nome AS equipamento,
      e.numero_patrimonio
    FROM manutencoes m
    INNER JOIN equipamentos e 
      ON e.id_equipamento = m.id_equipamento
    ORDER BY m.data_abertura DESC
  `);

  /*
    Retorna os dados em formato JSON.

    O frontend recebe esse JSON e monta a tabela de manutenções.
  */
  res.json(rows);
}));

/*
  Rota POST /

  Como esta rota está dentro de /api/manutencoes,
  ela representa:

  POST /api/manutencoes

  Essa rota cadastra uma nova manutenção no banco de dados.
*/
router.post('/', asyncHandler(async (req, res) => {
  /*
    Pega os dados enviados pelo frontend.

    Esses dados vêm do formulário da tela manutencoes.html.

    Exemplo:
    {
      "id_equipamento": "EQP000001",
      "descricao": "Equipamento não liga."
    }
  */
  const { id_equipamento, descricao } = req.body;

  /*
    Validação simples dos campos obrigatórios.

    Para cadastrar uma manutenção, é necessário informar:
    - equipamento;
    - descrição do problema.

    Se algum desses campos não for enviado, a API retorna erro 400.
  */
  if (!id_equipamento || !descricao) {
    return res.status(400).json({
      erro: 'Equipamento e descrição são obrigatórios.'
    });
  }

  /*
    Insere a manutenção no banco de dados.

    Repare que NÃO enviamos o id_manutencao.

    Isso acontece porque o banco gera o ID automaticamente
    por meio da trigger:

    trg_manutencoes_before_insert

    Essa trigger chama a function:

    fn_gerar_id_manutencao()

    Assim, o ID fica no formato:

    MAN000001
    MAN000002
    MAN000003
  */
  await db.query(
    `
      INSERT INTO manutencoes (
        id_equipamento, 
        descricao, 
        status
      ) VALUES (?, ?, 'ABERTA')
    `,
    [
      id_equipamento,
      descricao
    ]
  );

  /*
    Depois desse INSERT, o MySQL executa automaticamente
    a trigger trg_manutencoes_after_insert.

    Essa trigger faz duas coisas:

    1. Atualiza o equipamento para status MANUTENCAO.
    2. Registra um log na tabela logs_auditoria.

    Ou seja, essa regra não depende apenas do JavaScript.
    Ela também fica protegida dentro do banco de dados.
  */

  /*
    Retorna resposta de sucesso para o frontend.

    O status 201 significa que um novo registro foi criado.
  */
  res.status(201).json({
    mensagem: 'Manutenção cadastrada com sucesso.'
  });
}));

/*
  Exporta o router para ser usado no server.js.

  No server.js deve existir algo parecido com:

  const manutencoesRoutes = require('./src/routes/manutencoes.routes');
  app.use('/api/manutencoes', manutencoesRoutes);
*/
module.exports = router;