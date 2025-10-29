-- =====================================================
-- Trigger: missions_updated_at
-- Table: gamification_system.missions
-- Function: update_missions_updated_at
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS missions_updated_at ON gamification_system.missions CASCADE;

CREATE TRIGGER missions_updated_at BEFORE UPDATE ON gamification_system.missions FOR EACH ROW EXECUTE FUNCTION gamification_system.update_missions_updated_at()

