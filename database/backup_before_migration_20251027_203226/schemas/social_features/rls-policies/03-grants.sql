-- =====================================================
-- Grants and Permissions for social_features
-- Created: 2025-10-27
-- Description: Permisos de acceso al schema de características sociales
-- =====================================================

-- Schema permissions
GRANT USAGE ON SCHEMA social_features TO glit_user;

-- Table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA social_features TO glit_user;
GRANT TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA social_features TO glit_user;

-- Sequence permissions
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA social_features TO glit_user;

-- Specific table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON social_features.classrooms TO glit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON social_features.classroom_members TO glit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON social_features.teams TO glit_user;

-- Comentarios sobre permisos
COMMENT ON SCHEMA social_features IS
    'Schema para características sociales - profesores gestionan sus aulas, estudiantes ven sus membresías';
