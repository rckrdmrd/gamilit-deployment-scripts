-- =====================================================
-- Grants and Permissions for audit_logging
-- Created: 2025-10-27
-- Description: Permisos de acceso al schema de auditoría
-- =====================================================

-- Schema permissions
GRANT USAGE ON SCHEMA audit_logging TO gamilit_user;

-- Table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA audit_logging TO gamilit_user;
GRANT TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA audit_logging TO gamilit_user;

-- Sequence permissions
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA audit_logging TO gamilit_user;

-- Specific table permissions
GRANT INSERT, SELECT ON audit_logging.audit_logs TO gamilit_user;
GRANT INSERT, SELECT ON audit_logging.performance_metrics TO gamilit_user;
GRANT INSERT, SELECT ON audit_logging.system_alerts TO gamilit_user;
GRANT INSERT, SELECT ON audit_logging.system_logs TO gamilit_user;
GRANT INSERT, SELECT ON audit_logging.user_activity_logs TO gamilit_user;

-- Comentarios sobre permisos
COMMENT ON SCHEMA audit_logging IS
    'Schema para auditoría y logging - acceso controlado por RLS';
