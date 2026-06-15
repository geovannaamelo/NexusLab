# NEXUS Lab - Trabalho Final de Laboratório de Banco de Dados

Sistema web para gerenciamento de reservas de laboratórios, desenvolvido com:

- **Frontend:** HTML, CSS e JavaScript.
- **Backend:** Node.js + Express.
- **Banco de dados:** MySQL.

O projeto atende aos requisitos do trabalho:

- Tabelas relacionais com relacionamentos.
- Tabelas obrigatórias `usuarios` e `grupos_usuarios`.
- Índices com justificativa.
- Triggers.
- Views.
- Procedures.
- Functions.
- Geração própria de IDs.
- Usuários e permissões no MySQL.
- Frontend exibindo dados carregados do banco.
- Exibição de dados vindos de Views.
- API Node.js comunicando com MySQL.

---

## 1. Pré-requisitos

Instale:

- Node.js.
- MySQL Server.
- MySQL Workbench ou outro cliente SQL.

---

## 2. Configuração do banco de dados

Abra o MySQL Workbench e execute o arquivo:

```text
database/script_completo.sql
```

Ou execute os arquivos separadamente nesta ordem:

```text
01_create_database.sql
02_create_tables.sql
03_create_indexes.sql
04_create_functions.sql
05_create_triggers.sql
06_create_views.sql
07_create_procedures.sql
08_seed_data.sql
09_users_permissions.sql
```

Observação: a criação dos usuários do MySQL deve ser feita por um usuário administrador apenas na configuração inicial. A aplicação não usa root.

Se o MySQL apresentar erro ao criar funções por causa de binary logging, execute como administrador:

```sql
SET GLOBAL log_bin_trust_function_creators = 1;
```

Depois execute novamente o script.

---

## 3. Como rodar pelo VS Code

Abra a pasta do projeto no VS Code. Ela deve conter:

```text
backend/
frontend/
database/
```

No terminal da raiz do projeto, rode:

```bash
npm install
npm run dev
```

Também funciona rodando pela pasta backend:

```bash
cd backend
npm install
npm run dev
```

---

## 4. Como acessar o sistema

Com o backend rodando, abra no navegador:

```text
http://localhost:3000
```

O próprio backend serve os arquivos do frontend.

---

## 5. Configuração do `.env`

Confira o arquivo:

```text
backend/.env
```

Ele deve estar assim:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=app_operador
DB_PASSWORD=Operador@123
DB_NAME=nexus_lab
PORT=3000
```

---

## 6. Rotas da API

### Usuários

```text
GET    /api/usuarios
POST   /api/usuarios
PATCH  /api/usuarios/:id/alternar-status
```

### Grupos

```text
GET  /api/grupos
POST /api/grupos
```

### Laboratórios

```text
GET  /api/laboratorios
POST /api/laboratorios
```

### Equipamentos

```text
GET  /api/equipamentos
POST /api/equipamentos
```

### Reservas

```text
GET /api/reservas
POST /api/reservas
PUT /api/reservas/:id/cancelar
```

### Manutenções

```text
GET  /api/manutencoes
POST /api/manutencoes
```

### Relatórios por Views

```text
GET /api/relatorios/reservas-detalhadas
GET /api/relatorios/ocupacao-laboratorios
GET /api/relatorios/equipamentos-manutencao
```

---

## 7. Usuários de teste da aplicação

O banco já vem com usuários de exemplo cadastrados, como:

```text
admin@nexuslab.com
joao@nexuslab.com
ana@nexuslab.com
```

Senha de exemplo:

```text
123456
```

A aplicação atual não implementa tela de login obrigatória, pois o foco do trabalho é a integração com banco de dados e os recursos do SGBD.

---

## 8. Itens importantes para apresentar

Na apresentação, destaque:

1. A aplicação não acessa o MySQL com root.
2. Os dados da tela de relatórios vêm de Views.
3. A criação de reservas usa Procedure.
4. A validação de conflito de horário é feita por Trigger.
5. Os IDs são gerados por Functions específicas.
6. Os logs são gerados automaticamente por Triggers.
7. A abertura de manutenção altera o status do equipamento por Trigger.
8. O frontend consome a API Node.js.

---

## 9. Estrutura do projeto

```text
nexus-lab-app-completo/
├── backend/
│   ├── server.js
│   ├── package.json
│   ├── .env
│   └── src/
│       ├── db.js
│       ├── asyncHandler.js
│       └── routes/
├── frontend/
│   ├── index.html
│   ├── usuarios.html
│   ├── laboratorios.html
│   ├── equipamentos.html
│   ├── reservas.html
│   ├── manutencoes.html
│   ├── relatorios.html
│   ├── css/
│   └── js/
├── database/
│   ├── script_completo.sql
│   ├── DER.md
│   └── JUSTIFICATIVAS_BANCO.md
├── artigo/
│   ├── artigo_academico_modelo.md
│   └── roteiro_apresentacao_5_minutos.md
├── COMO_RODAR_NO_VSCODE.md
├── rodar.bat
└── package.json
```
