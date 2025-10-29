-- =====================================================
-- Trigger: trg_system_alerts_updated_at
-- Table: audit_logging.system_alerts
-- Function: update_updated_at_column
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_system_alerts_updated_at ON audit_logging.system_alerts CASCADE;

CREATE TRIGGER trg_system_alerts_updated_at BEFORE UPDATE ON audit_logging.system_alerts FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column()

