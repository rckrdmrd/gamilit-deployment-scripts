-- =====================================================
-- Grants and Permissions for progress_tracking
-- Created: 2025-10-27
-- Description: Permisos de acceso al schema de seguimiento de progreso
-- =====================================================

-- Schema permissions
GRANT USAGE ON SCHEMA progress_tracking TO gamilit_user;

-- Table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA progress_tracking TO gamilit_user;
GRANT TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA progress_tracking TO gamilit_user;

-- Sequence permissions
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA progress_tracking TO gamilit_user;

-- Specific table permissions
GRANT SELECT, INSERT ON progress_tracking.exercise_attempts TO gamilit_user;
GRANT SELECT, INSERT, UPDATE ON progress_tracking.module_progress TO gamilit_user;
GRANT SELECT, INSERT, UPDATE ON progress_tracking.learning_sessions TO gamilit_user;

-- Comentarios sobre permisos
COMMENT ON SCHEMA progress_tracking IS
    'Schema para seguimiento de progreso - acceso controlado por RLS, profesores pueden ver progreso de estudiantes';
