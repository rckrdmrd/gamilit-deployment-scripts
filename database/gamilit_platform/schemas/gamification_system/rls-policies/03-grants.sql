-- =====================================================
-- Grants and Permissions for gamification_system
-- Created: 2025-10-27
-- Description: Permisos de acceso al schema de gamificación
-- =====================================================

-- Schema permissions
GRANT USAGE ON SCHEMA gamification_system TO gamilit_user;

-- Table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA gamification_system TO gamilit_user;
GRANT TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA gamification_system TO gamilit_user;

-- Sequence permissions
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA gamification_system TO gamilit_user;

-- Specific table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON gamification_system.achievements TO gamilit_user;
GRANT SELECT, INSERT ON gamification_system.ml_coins_transactions TO gamilit_user;
GRANT SELECT, INSERT ON gamification_system.user_achievements TO gamilit_user;
GRANT SELECT, UPDATE ON gamification_system.user_stats TO gamilit_user;

-- Comentarios sobre permisos
COMMENT ON SCHEMA gamification_system IS
    'Schema para sistema de gamificación - acceso controlado por RLS para datos de usuario';
