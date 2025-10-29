-- =====================================================
-- Trigger: trg_module_progress_updated_at
-- Table: progress_tracking.module_progress
-- Function: update_updated_at_column
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_module_progress_updated_at ON progress_tracking.module_progress CASCADE;

CREATE TRIGGER trg_module_progress_updated_at BEFORE UPDATE ON progress_tracking.module_progress FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column()

