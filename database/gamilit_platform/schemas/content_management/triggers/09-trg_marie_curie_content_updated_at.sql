-- =====================================================
-- Trigger: trg_marie_curie_content_updated_at
-- Table: content_management.marie_curie_content
-- Function: update_updated_at_column
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_marie_curie_content_updated_at ON content_management.marie_curie_content CASCADE;

CREATE TRIGGER trg_marie_curie_content_updated_at BEFORE UPDATE ON content_management.marie_curie_content FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column()

