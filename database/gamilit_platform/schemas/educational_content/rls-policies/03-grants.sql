-- =====================================================
-- Grants and Permissions for educational_content
-- Created: 2025-10-27
-- Description: Permisos de acceso al schema de contenido educativo
-- =====================================================

-- Schema permissions
GRANT USAGE ON SCHEMA educational_content TO gamilit_user;

-- Table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA educational_content TO gamilit_user;
GRANT TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA educational_content TO gamilit_user;

-- Sequence permissions
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA educational_content TO gamilit_user;

-- Specific table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON educational_content.exercises TO gamilit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON educational_content.modules TO gamilit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON educational_content.assessment_rubrics TO gamilit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON educational_content.media_resources TO gamilit_user;

-- Comentarios sobre permisos
COMMENT ON SCHEMA educational_content IS
    'Schema para contenido educativo - ejercicios y módulos protegidos con RLS';
