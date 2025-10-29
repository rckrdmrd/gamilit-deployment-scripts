-- =====================================================
-- Grants and Permissions for content_management
-- Created: 2025-10-27
-- Description: Permisos de acceso al schema de gestión de contenido
-- =====================================================

-- Schema permissions
GRANT USAGE ON SCHEMA content_management TO gamilit_user;

-- Table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA content_management TO gamilit_user;
GRANT TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA content_management TO gamilit_user;

-- Sequence permissions
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA content_management TO gamilit_user;

-- Specific table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON content_management.content_templates TO gamilit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON content_management.marie_curie_content TO gamilit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON content_management.media_files TO gamilit_user;

-- Comentarios sobre permisos
COMMENT ON SCHEMA content_management IS
    'Schema para gestión de contenido - marie_curie_content protegido con RLS';
