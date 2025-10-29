-- =====================================================
-- Grants and Permissions for system_configuration
-- Created: 2025-10-27
-- Description: Permisos de acceso al schema de configuración del sistema
-- =====================================================

-- Schema permissions
GRANT USAGE ON SCHEMA system_configuration TO gamilit_user;

-- Table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA system_configuration TO gamilit_user;
GRANT TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA system_configuration TO gamilit_user;

-- Sequence permissions
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA system_configuration TO gamilit_user;

-- Specific table permissions
GRANT SELECT, UPDATE ON system_configuration.feature_flags TO gamilit_user;
GRANT SELECT, UPDATE ON system_configuration.system_settings TO gamilit_user;

-- Comentarios sobre permisos
COMMENT ON SCHEMA system_configuration IS
    'Schema para configuración del sistema - acceso controlado con RLS';
