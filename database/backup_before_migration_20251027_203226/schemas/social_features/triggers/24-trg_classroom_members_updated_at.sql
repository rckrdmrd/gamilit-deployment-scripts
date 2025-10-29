-- =====================================================
-- Trigger: trg_classroom_members_updated_at
-- Table: social_features.classroom_members
-- Function: update_updated_at_column
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_classroom_members_updated_at ON social_features.classroom_members CASCADE;

CREATE TRIGGER trg_classroom_members_updated_at BEFORE UPDATE ON social_features.classroom_members FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column()

