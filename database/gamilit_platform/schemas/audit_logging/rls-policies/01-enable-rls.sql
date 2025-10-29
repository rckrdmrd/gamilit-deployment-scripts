-- =====================================================
-- Enable RLS for audit_logging tables
-- Created: 2025-10-27
-- Description: Habilita Row Level Security en todas las
--              tablas del schema audit_logging
-- =====================================================

-- Tablas con RLS habilitado
ALTER TABLE audit_logging.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logging.performance_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logging.system_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logging.system_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logging.user_activity_logs ENABLE ROW LEVEL SECURITY;

-- Comentarios
COMMENT ON TABLE audit_logging.audit_logs IS 'RLS enabled: Admin y usuarios propios pueden ver sus registros';
COMMENT ON TABLE audit_logging.performance_metrics IS 'RLS enabled: Métricas de rendimiento del sistema';
COMMENT ON TABLE audit_logging.system_alerts IS 'RLS enabled: Alertas del sistema';
COMMENT ON TABLE audit_logging.system_logs IS 'RLS enabled: Logs del sistema';
COMMENT ON TABLE audit_logging.user_activity_logs IS 'RLS enabled: Logs de actividad de usuarios';
