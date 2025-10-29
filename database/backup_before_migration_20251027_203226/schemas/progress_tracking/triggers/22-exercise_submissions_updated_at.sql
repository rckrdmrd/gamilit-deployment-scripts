-- =====================================================
-- Trigger: exercise_submissions_updated_at
-- Table: progress_tracking.exercise_submissions
-- Function: update_exercise_submissions_updated_at
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS exercise_submissions_updated_at ON progress_tracking.exercise_submissions CASCADE;

CREATE TRIGGER exercise_submissions_updated_at BEFORE UPDATE ON progress_tracking.exercise_submissions FOR EACH ROW EXECUTE FUNCTION progress_tracking.update_exercise_submissions_updated_at()

