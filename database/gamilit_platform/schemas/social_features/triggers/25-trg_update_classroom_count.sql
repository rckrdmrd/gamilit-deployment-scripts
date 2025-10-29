-- =====================================================
-- Trigger: trg_update_classroom_count
-- Table: social_features.classroom_members
-- Function: update_classroom_member_count
-- Event: AFTER INSERT
-- Level: FOR EACH ROW
-- Description: Actualiza el contador de miembros en el aula cuando se agregan miembros
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_update_classroom_count ON social_features.classroom_members CASCADE;

CREATE TRIGGER trg_update_classroom_count AFTER INSERT OR DELETE ON social_features.classroom_members FOR EACH ROW EXECUTE FUNCTION gamilit.update_classroom_member_count()

