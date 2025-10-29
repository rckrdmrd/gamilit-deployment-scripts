-- =====================================================
-- Enable RLS for educational_content tables
-- Created: 2025-10-27
-- Description: Habilita Row Level Security en todas las
--              tablas del schema educational_content
-- =====================================================

-- Tablas con RLS habilitado
ALTER TABLE educational_content.assessment_rubrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE educational_content.media_resources ENABLE ROW LEVEL SECURITY;

-- Comentarios
COMMENT ON TABLE educational_content.assessment_rubrics IS 'RLS enabled: Rúbricas de evaluación';
COMMENT ON TABLE educational_content.media_resources IS 'RLS enabled: Recursos multimedia educativos';
