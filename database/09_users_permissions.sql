-- Este script deve ser executado por um usuário administrador do MySQL apenas no momento da configuração.
-- A aplicação NÃO usa root. Ela usa app_operador, conforme arquivo backend/.env.

DROP USER IF EXISTS 'app_admin'@'localhost';
DROP USER IF EXISTS 'app_operador'@'localhost';
DROP USER IF EXISTS 'app_consulta'@'localhost';

CREATE USER 'app_admin'@'localhost' IDENTIFIED BY 'Admin@123';
CREATE USER 'app_operador'@'localhost' IDENTIFIED BY 'Operador@123';
CREATE USER 'app_consulta'@'localhost' IDENTIFIED BY 'Consulta@123';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON nexus_lab.* TO 'app_admin'@'localhost';
GRANT SELECT, INSERT, UPDATE, EXECUTE ON nexus_lab.* TO 'app_operador'@'localhost';
GRANT SELECT ON nexus_lab.* TO 'app_consulta'@'localhost';

FLUSH PRIVILEGES;

