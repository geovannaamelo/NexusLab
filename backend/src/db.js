/*
  Importa a biblioteca mysql2 com suporte a Promises.

  Essa biblioteca permite que o Node.js se conecte ao banco MySQL
  e execute comandos SQL usando async/await.
*/
const mysql = require('mysql2/promise');

/*
  Importa o módulo path do Node.js.

  Ele ajuda a montar caminhos de arquivos de forma segura,
  independente do sistema operacional.
*/
const path = require('path');

/*
  Carrega as variáveis de ambiente do arquivo .env.

  O arquivo .env guarda informações sensíveis ou configuráveis, como:
  - host do banco;
  - porta;
  - usuário;
  - senha;
  - nome do banco;
  - porta do servidor Node.

  Usamos path.resolve para garantir que o backend leia o .env da raiz do projeto.
*/
require('dotenv').config({
  path: path.resolve(__dirname, '../../.env')
});

/*
  Cria um pool de conexões com o MySQL.

  Um pool é um conjunto de conexões reutilizáveis.
  Em vez de abrir e fechar uma conexão nova a cada requisição,
  o sistema reutiliza conexões, deixando a aplicação mais eficiente.
*/
const pool = mysql.createPool({
  /*
    Endereço do banco de dados.

    Normalmente, usando XAMPP local, fica localhost.
    Também pode ser 127.0.0.1.
  */
  host: process.env.DB_HOST || 'localhost',

  /*
    Porta do MySQL.

    No XAMPP, normalmente é 3306.
    Se a porta foi alterada, pode ser 3307.
  */
  port: Number(process.env.DB_PORT || 3306),

  /*
    Usuário usado pela aplicação para acessar o banco.

    O trabalho exige que a aplicação NÃO use root.
    Por isso foi criado o usuário app_operador.
  */
  user: process.env.DB_USER || 'app_operador',

  /*
    Senha do usuário do banco.

    Essa senha deve ser igual à senha definida no script 09_users_permissions.sql.
  */
  password: process.env.DB_PASSWORD || 'Operador@123',

  /*
    Nome do banco de dados usado pelo sistema.

    No projeto, o banco se chama nexus_lab.
  */
  database: process.env.DB_NAME || 'nexus_lab',

  /*
    Faz com que o sistema aguarde uma conexão disponível
    caso todas estejam ocupadas.
  */
  waitForConnections: true,

  /*
    Número máximo de conexões simultâneas no pool.

    Aqui foi definido 10, o que é suficiente para um projeto acadêmico.
  */
  connectionLimit: 10,

  /*
    Define o limite da fila de espera por conexões.

    O valor 0 significa que não há limite fixo para a fila.
  */
  queueLimit: 0,

  /*
    Configurações de Keep-Alive para evitar que a conexão com a nuvem feche por inatividade.
  */
  idleTimeout: 1800000, // 30 minutos
  enableKeepAlive: true,
  keepAliveInitialDelay: 10000,

  /*
    Configura SSL caso exigido pelo servidor de banco de dados.
  */
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined
});

/*
  Warmup: Executa uma query simples imediatamente após criar o pool.
  Isso inicia o handshake SSL em segundo plano, acelerando a primeira requisição.
*/
pool.query('SELECT 1').catch((err) => {
  if (err.code === 'ETIMEDOUT') {
    console.error('Erro no warmup do pool de conexões: Conexão expirou (ETIMEDOUT). Verifique as configurações do banco de dados e de rede.');
  } else {
    console.error('Erro no warmup do pool de conexões:', err);
  }
});

/*
  Exporta o pool de conexões.

  Outros arquivos do backend importam esse pool para executar consultas SQL.

  Exemplo:

  const db = require('../db');

  const [rows] = await db.query('SELECT * FROM usuarios');
*/
module.exports = pool;