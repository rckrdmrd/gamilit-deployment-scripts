-- =====================================================
-- Enable RLS for progress_tracking tables
-- Created: 2025-10-27
-- Updated: 2025-10-28 (Agent 3 - Comprehensive RLS Integration)
-- Description: Habilita Row Level Security en todas las
--              tablas del schema progress_tracking
-- =====================================================

-- Enable Row Level Security on all progress_tracking tables
-- Schema: progress_tracking
-- Tables: 4 tables with RLS protection

ALTER TABLE progress_tracking.module_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_tracking.exercise_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_tracking.exercise_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_tracking.learning_sessions ENABLE ROW LEVEL SECURITY;

-- Comentarios
COMMENT ON TABLE progress_tracking.module_progress IS 'RLS enabled: Progreso de módulos - lectura propia + teacher + admin';
COMMENT ON TABLE progress_tracking.exercise_attempts IS 'RLS enabled: Intentos de ejercicios - lectura propia + teacher';
COMMENT ON TABLE progress_tracking.exercise_submissions IS 'RLS enabled: Entregas de ejercicios - gestión propia + calificación teacher';
COMMENT ON TABLE progress_tracking.learning_sessions IS 'RLS enabled: Sesiones de aprendizaje de usuarios';
