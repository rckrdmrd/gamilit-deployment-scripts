-- =====================================================
-- Trigger: trg_exercises_updated_at
-- Table: educational_content.exercises
-- Function: update_updated_at_column
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_exercises_updated_at ON educational_content.exercises CASCADE;

CREATE TRIGGER trg_exercises_updated_at BEFORE UPDATE ON educational_content.exercises FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column()

