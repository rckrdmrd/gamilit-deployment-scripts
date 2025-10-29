-- =====================================================
-- Trigger: trg_update_user_stats_on_exercise
-- Table: progress_tracking.exercise_attempts
-- Function: update_user_stats_on_exercise_complete
-- Event: AFTER INSERT
-- Level: FOR EACH ROW
-- Description: Actualiza estadísticas de usuario al completar ejercicios
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_update_user_stats_on_exercise ON progress_tracking.exercise_attempts CASCADE;

CREATE TRIGGER trg_update_user_stats_on_exercise AFTER INSERT ON progress_tracking.exercise_attempts FOR EACH ROW EXECUTE FUNCTION gamilit.update_user_stats_on_exercise_complete()

