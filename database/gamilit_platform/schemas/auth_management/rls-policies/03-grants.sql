-- =====================================================
-- Grants and Permissions for auth_management
-- Created: 2025-10-27
-- Description: Permisos de acceso al schema de autenticación
-- =====================================================

-- Schema permissions
GRANT USAGE ON SCHEMA auth_management TO gamilit_user;

-- Table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA auth_management TO gamilit_user;
GRANT TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA auth_management TO gamilit_user;

-- Sequence permissions
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA auth_management TO gamilit_user;

-- Specific table permissions - profiles (con RLS)
GRANT SELECT, UPDATE ON auth_management.profiles TO gamilit_user;

-- Otras tablas del schema
GRANT SELECT, INSERT, UPDATE, DELETE ON auth_management.auth_attempts TO gamilit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON auth_management.email_verification_tokens TO gamilit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON auth_management.memberships TO gamilit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON auth_management.password_reset_tokens TO gamilit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON auth_management.security_events TO gamilit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON auth_management.tenants TO gamilit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON auth_management.user_roles TO gamilit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON auth_management.user_sessions TO gamilit_user;

-- Comentarios sobre permisos
COMMENT ON SCHEMA auth_management IS
    'Schema para gestión de autenticación - perfiles protegidos con RLS';
