-- =====================================================
-- Trigger: trg_content_templates_updated_at
-- Table: content_management.content_templates
-- Function: update_updated_at_column
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_content_templates_updated_at ON content_management.content_templates CASCADE;

CREATE TRIGGER trg_content_templates_updated_at BEFORE UPDATE ON content_management.content_templates FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column()

