# Justificativas dos recursos de banco de dados

## Índices

- `idx_usuarios_nome`: melhora a busca por usuários pelo nome.
- `uk_usuarios_email`: impede duplicidade de e-mail e acelera consultas de autenticação.
- `idx_reservas_laboratorio_data`: acelera a verificação da agenda de um laboratório em determinada data.
- `idx_reservas_usuario`: melhora consultas de reservas realizadas por usuário.
- `idx_reservas_status`: facilita filtros por reservas ativas, canceladas ou finalizadas.
- `idx_equipamentos_laboratorio`: melhora a listagem de equipamentos por laboratório.
- `idx_manutencoes_status`: facilita consultas por manutenções abertas ou concluídas.
- `idx_logs_tabela_acao`: melhora a consulta dos registros de auditoria por tabela e tipo de ação.

## Triggers

- `trg_usuarios_before_insert`: gera automaticamente o ID do usuário quando ele não é informado.
- `trg_grupos_before_insert`: gera automaticamente o ID do grupo de usuário.
- `trg_laboratorios_before_insert`: gera automaticamente o ID do laboratório.
- `trg_equipamentos_before_insert`: gera automaticamente o ID do equipamento.
- `trg_reservas_before_insert`: gera o ID da reserva e impede conflitos de horário no mesmo laboratório.
- `trg_reservas_after_insert`: cria um log de auditoria quando uma reserva é cadastrada.
- `trg_reservas_after_update`: cria um log de auditoria quando o status da reserva muda.
- `trg_manutencoes_after_insert`: altera o status do equipamento para manutenção e registra log.

## Views

- `vw_reservas_detalhadas`: centraliza dados de reservas, usuários e laboratórios, facilitando a exibição no frontend.
- `vw_ocupacao_laboratorios`: consolida a quantidade de reservas por laboratório e o tempo total reservado.
- `vw_equipamentos_manutencao`: exibe equipamentos com quantidade de manutenções abertas.

## Procedures

- `sp_cadastrar_usuario`: padroniza o cadastro de usuários, gera ID e vincula o usuário a um grupo.
- `sp_criar_reserva`: padroniza a criação de reservas e aproveita as validações da trigger.
- `sp_cancelar_reserva`: altera o status da reserva para cancelada sem excluir o registro.
- `sp_concluir_manutencao`: conclui a manutenção e libera o equipamento caso não existam outras manutenções abertas.

## Functions

- Funções `fn_gerar_id_*`: criam IDs próprios com prefixos, como `USR000001`, `LAB000001` e `RES000001`.
- `fn_duracao_reserva`: calcula a duração da reserva em minutos, sendo utilizada em relatórios e Views.

## Controle de acesso

A aplicação não acessa o banco pelo usuário root. Foram definidos três usuários:

- `app_admin`: possui acesso total ao banco da aplicação.
- `app_operador`: utilizado pela API, com permissões de leitura, inserção, atualização e execução de procedures/functions.
- `app_consulta`: possui somente permissão de leitura.

Essa estratégia aplica o princípio do menor privilégio e reduz riscos de segurança.
