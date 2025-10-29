-- =====================================================
-- Enable RLS for educational_content tables
-- Created: 2025-10-27
-- Updated: 2025-10-28 (Agent 3 - Comprehensive RLS Integration)
-- Description: Habilita Row Level Security en todas las
--              tablas del schema educational_content
-- =====================================================

-- Enable Row Level Security on educational_content tables
-- Schema: educational_content
-- Tables: 2 tables with comprehensive RLS policies

ALTER TABLE educational_content.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE educational_content.exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE educational_content.assessment_rubrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE educational_content.media_resources ENABLE ROW LEVEL SECURITY;

-- Comentarios
COMMENT ON TABLE educational_content.modules IS 'RLS enabled: Módulos - publicados para estudiantes, todos para profesores/admin';
COMMENT ON TABLE educational_content.exercises IS 'RLS enabled: Ejercicios - activos para estudiantes, todos para profesores/admin';
COMMENT ON TABLE educational_content.assessment_rubrics IS 'RLS enabled: Rúbricas de evaluación';
COMMENT ON TABLE educational_content.media_resources IS 'RLS enabled: Recursos multimedia educativos';
