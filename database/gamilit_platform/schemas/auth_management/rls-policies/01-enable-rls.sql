-- =====================================================
-- Enable RLS for auth_management tables
-- Created: 2025-10-27
-- Updated: 2025-10-28 (Agent 3 - Comprehensive RLS Integration)
-- Description: Habilita Row Level Security en todas las tablas
--              de gestión de autenticación
-- =====================================================

-- Enable Row Level Security on all auth_management tables
-- Schema: auth_management
-- Tables: 9 tables with RLS protection

ALTER TABLE auth_management.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_management.user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_management.password_reset_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_management.email_verification_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_management.security_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_management.auth_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_management.memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_management.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_management.user_roles ENABLE ROW LEVEL SECURITY;

-- Comentarios
COMMENT ON TABLE auth_management.profiles IS 'RLS enabled: Perfiles de usuario con acceso controlado por rol';
COMMENT ON TABLE auth_management.user_sessions IS 'RLS enabled: Sesiones de usuario - solo lectura propia';
COMMENT ON TABLE auth_management.password_reset_tokens IS 'RLS enabled: Tokens de reset - validación propia';
COMMENT ON TABLE auth_management.email_verification_tokens IS 'RLS enabled: Tokens de verificación - validación propia';
COMMENT ON TABLE auth_management.security_events IS 'RLS enabled: Eventos de seguridad - lectura propia + admin';
COMMENT ON TABLE auth_management.auth_attempts IS 'RLS enabled: Intentos de autenticación - solo sistema';
COMMENT ON TABLE auth_management.memberships IS 'RLS enabled: Membresías - aislamiento por tenant';
COMMENT ON TABLE auth_management.tenants IS 'RLS enabled: Tenants - acceso solo al propio tenant';
COMMENT ON TABLE auth_management.user_roles IS 'RLS enabled: Roles de usuario - lectura propia';
