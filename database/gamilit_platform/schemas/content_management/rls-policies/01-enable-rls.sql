-- =====================================================
-- Enable RLS for content_management tables
-- Created: 2025-10-27
-- Description: Habilita Row Level Security en todas las
--              tablas del schema content_management
-- =====================================================

-- Tablas con RLS habilitado
ALTER TABLE content_management.content_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_management.marie_curie_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_management.media_files ENABLE ROW LEVEL SECURITY;

-- Comentarios
COMMENT ON TABLE content_management.content_templates IS 'RLS enabled: Plantillas de contenido';
COMMENT ON TABLE content_management.marie_curie_content IS 'RLS enabled: Contenido Marie Curie, visible según estado de publicación';
COMMENT ON TABLE content_management.media_files IS 'RLS enabled: Archivos multimedia';
