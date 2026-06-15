/*
  Importa o Express.

  O Express é a biblioteca principal usada para criar o servidor backend.
  Com ele, conseguimos criar rotas como:
  - GET /api/usuarios
  - POST /api/reservas
  - GET /api/relatorios/reservas-detalhadas
*/
const express = require('express');

/*
  Importa o CORS.

  O CORS permite que o frontend consiga fazer requisições para o backend.
  Mesmo neste projeto estando tudo local, é uma boa prática deixar configurado.
*/
const cors = require('cors');

/*
  Importa o módulo path do Node.js.

  Ele serve para trabalhar com caminhos de pastas e arquivos.
  Aqui será usado para localizar a pasta frontend.
*/
const path = require('path');

/*
  Carrega as variáveis de ambiente do arquivo .env.

  O .env guarda configurações como:
  - porta do servidor;
  - host do banco;
  - usuário do banco;
  - senha do banco;
  - nome do banco.
*/
require('dotenv').config({ path: path.resolve(__dirname, '.env') });

/*
  Importa as rotas de usuários.

  Essas rotas cuidam de:
  - listar usuários;
  - cadastrar usuários;
  - alternar status ativo/inativo.
*/
const usuariosRoutes = require('./src/routes/usuarios.routes');

/*
  Importa as rotas de grupos de usuários.

  Essas rotas cuidam da tabela grupos_usuarios,
  obrigatória no trabalho.
*/
const gruposRoutes = require('./src/routes/grupos.routes');

/*
  Importa as rotas de laboratórios.

  Essas rotas permitem:
  - listar laboratórios;
  - cadastrar laboratórios.
*/
const laboratoriosRoutes = require('./src/routes/laboratorios.routes');

/*
  Importa as rotas de equipamentos.

  Essas rotas permitem:
  - listar equipamentos;
  - cadastrar equipamentos.
*/
const equipamentosRoutes = require('./src/routes/equipamentos.routes');

/*
  Importa as rotas de reservas.

  Essas rotas permitem:
  - listar reservas usando View;
  - criar reserva usando Procedure;
  - cancelar reserva usando Procedure.
*/
const reservasRoutes = require('./src/routes/reservas.routes');

/*
  Importa as rotas de manutenções.

  Essas rotas permitem:
  - listar manutenções;
  - registrar manutenção.
*/
const manutencoesRoutes = require('./src/routes/manutencoes.routes');

/*
  Importa as rotas de relatórios.

  Essas rotas consultam Views do MySQL, como:
  - vw_reservas_detalhadas;
  - vw_ocupacao_laboratorios;
  - vw_equipamentos_manutencao.
*/
const relatoriosRoutes = require('./src/routes/relatorios.routes');

/*
  Cria a aplicação Express.

  A variável app representa o servidor backend.
*/
const app = express();

/*
  Define a porta onde o servidor vai rodar.

  Primeiro tenta usar a porta definida no arquivo .env.
  Se não existir, usa a porta 3000 como padrão.
*/
const PORT = process.env.PORT || 3000;

/*
  Habilita o CORS no servidor.

  Isso permite que o frontend consiga se comunicar com a API.
*/
app.use(cors());

/*
  Permite que o servidor receba dados em formato JSON.

  Sem isso, o backend não conseguiria ler corretamente o corpo das requisições POST,
  como cadastro de usuários, laboratórios, reservas etc.
*/
app.use(express.json());

/*
  Permite abrir o frontend diretamente pelo servidor Node.js.

  A pasta frontend contém arquivos como:
  - index.html;
  - usuarios.html;
  - reservas.html;
  - relatorios.html;
  - css/style.css;
  - js/api.js.

  Com essa configuração, ao acessar:

  http://localhost:3000

  o Express entrega automaticamente a página do frontend.
*/
app.use(express.static(path.join(__dirname, '../frontend')));

/*
  Rota de teste da API.

  Ela serve para verificar se o backend está funcionando.

  Quando acessamos:

  GET /api/health

  o servidor responde com uma mensagem simples.
*/
app.get('/api/health', (req, res) => {
  res.json({
    status: 'online',
    projeto: 'NEXUS Lab',
    mensagem: 'API funcionando corretamente'
  });
});

/*
  Registra as rotas de usuários.

  Tudo que começar com /api/usuarios será enviado para usuarios.routes.js.

  Exemplos:
  GET  /api/usuarios
  POST /api/usuarios
*/
app.use('/api/usuarios', usuariosRoutes);

/*
  Registra as rotas de grupos.

  Tudo que começar com /api/grupos será enviado para grupos.routes.js.

  Exemplos:
  GET  /api/grupos
  POST /api/grupos
*/
app.use('/api/grupos', gruposRoutes);

/*
  Registra as rotas de laboratórios.

  Exemplos:
  GET  /api/laboratorios
  POST /api/laboratorios
*/
app.use('/api/laboratorios', laboratoriosRoutes);

/*
  Registra as rotas de equipamentos.

  Exemplos:
  GET  /api/equipamentos
  POST /api/equipamentos
*/
app.use('/api/equipamentos', equipamentosRoutes);

/*
  Registra as rotas de reservas.

  Exemplos:
  GET  /api/reservas
  POST /api/reservas
  PUT  /api/reservas/RES000001/cancelar
*/
app.use('/api/reservas', reservasRoutes);

/*
  Registra as rotas de manutenções.

  Exemplos:
  GET  /api/manutencoes
  POST /api/manutencoes
*/
app.use('/api/manutencoes', manutencoesRoutes);

/*
  Registra as rotas de relatórios.

  Essas rotas consultam Views do MySQL.

  Exemplos:
  GET /api/relatorios/reservas-detalhadas
  GET /api/relatorios/ocupacao-laboratorios
  GET /api/relatorios/equipamentos-manutencao
*/
app.use('/api/relatorios', relatoriosRoutes);

/*
  Middleware para rotas não encontradas.

  Se o usuário tentar acessar uma rota que não existe,
  o servidor responde com erro 404.

  Exemplo:
  GET /api/rota-inexistente
*/
app.use((req, res) => {
  res.status(404).json({
    erro: 'Rota não encontrada'
  });
});

/*
  Middleware central de tratamento de erros.

  Se alguma rota der erro, por exemplo:
  - erro de SQL;
  - problema de conexão com o banco;
  - campo duplicado;
  - falha em uma procedure;

  esse middleware captura o erro e devolve uma resposta JSON.
*/
app.use((error, req, res, next) => {
  /*
    Mostra o erro no terminal do VS Code.
    Isso ajuda a identificar o problema durante o desenvolvimento.
  */
  console.error(error);

  /*
    Envia uma resposta de erro para o frontend.
    O status 500 significa erro interno no servidor.
  */
  res.status(500).json({
    erro: 'Erro interno no servidor',
    detalhe: error.message
  });
});

/*
  Inicia o servidor.

  Quando o comando npm run dev é executado,
  o Node roda este arquivo e começa a escutar requisições na porta configurada.

  Exemplo:
  http://localhost:3000
*/
/*
  Importa o pool de banco de dados para configurar o ping periódico
*/
const db = require('./src/db');

/*
  Inicia um ping a cada 30 segundos para manter a conexão ativa
  com o banco de dados e evitar timeouts.
*/
setInterval(() => {
  db.query('SELECT 1').catch(err => {
    if (err.code === 'ETIMEDOUT') {
      console.error('Erro no ping de keep-alive: Conexão expirou (ETIMEDOUT). Verifique a conexão com o banco de dados.');
    } else {
      console.error('Erro no ping de keep-alive do banco:', err.message);
    }
  });
}, 30000);

app.listen(PORT, () => {
  console.log(`Servidor NEXUS Lab rodando em http://localhost:${PORT}`);
});