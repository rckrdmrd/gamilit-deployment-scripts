-- =====================================================
-- Trigger: trg_teams_updated_at
-- Table: social_features.teams
-- Function: update_updated_at_column
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_teams_updated_at ON social_features.teams CASCADE;

CREATE TRIGGER trg_teams_updated_at BEFORE UPDATE ON social_features.teams FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column()

