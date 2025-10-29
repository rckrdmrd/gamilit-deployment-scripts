-- =====================================================
-- Trigger: trg_achievements_updated_at
-- Table: gamification_system.achievements
-- Function: update_updated_at_column
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_achievements_updated_at ON gamification_system.achievements CASCADE;

CREATE TRIGGER trg_achievements_updated_at BEFORE UPDATE ON gamification_system.achievements FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column()

