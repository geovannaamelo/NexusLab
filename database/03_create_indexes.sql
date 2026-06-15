USE nexus_lab;

CREATE INDEX idx_usuarios_nome ON usuarios(nome);
CREATE INDEX idx_reservas_laboratorio_data ON reservas(id_laboratorio, data_reserva);
CREATE INDEX idx_reservas_usuario ON reservas(id_usuario);
CREATE INDEX idx_reservas_status ON reservas(status);
CREATE INDEX idx_equipamentos_laboratorio ON equipamentos(id_laboratorio);
CREATE INDEX idx_manutencoes_status ON manutencoes(status);
CREATE INDEX idx_logs_tabela_acao ON logs_auditoria(tabela_afetada, acao);
