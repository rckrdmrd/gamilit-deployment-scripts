-- =====================================================
-- Seed Data: educational_content.assessment_rubrics
-- Description: Rúbricas de evaluación automáticas y manuales
-- Records: 0
-- Created: 2025-10-27
-- =====================================================

SET search_path TO educational_content, public;

TRUNCATE TABLE educational_content.assessment_rubrics RESTART IDENTITY CASCADE;

-- No hay registros para insertar actualmente
-- La tabla está lista para recibir rúbricas de evaluación
-- Tipos soportados:
-- - automatic: Evaluación automática por el sistema
-- - manual: Evaluación manual por docentes
-- - hybrid: Combinación de ambas
-- - peer_review: Evaluación entre pares
