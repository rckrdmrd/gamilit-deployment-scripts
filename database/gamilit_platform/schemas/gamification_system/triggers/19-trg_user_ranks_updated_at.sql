-- =====================================================
-- Trigger: trg_user_ranks_updated_at
-- Table: gamification_system.user_ranks
-- Function: update_updated_at_column
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_user_ranks_updated_at ON gamification_system.user_ranks CASCADE;

CREATE TRIGGER trg_user_ranks_updated_at BEFORE UPDATE ON gamification_system.user_ranks FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column()

