-- =====================================================
-- Trigger: trg_system_settings_updated_at
-- Table: system_configuration.system_settings
-- Function: update_updated_at_column
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_system_settings_updated_at ON system_configuration.system_settings CASCADE;

CREATE TRIGGER trg_system_settings_updated_at BEFORE UPDATE ON system_configuration.system_settings FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column()

