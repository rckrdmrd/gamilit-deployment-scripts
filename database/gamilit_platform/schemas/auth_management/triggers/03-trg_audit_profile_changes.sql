-- =====================================================
-- Trigger: trg_audit_profile_changes
-- Table: auth_management.profiles
-- Function: audit_profile_changes
-- Event: AFTER UPDATE
-- Level: FOR EACH ROW
-- Description: Registra cambios en perfiles de usuario para auditoría
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_audit_profile_changes ON auth_management.profiles CASCADE;

CREATE TRIGGER trg_audit_profile_changes AFTER UPDATE ON auth_management.profiles FOR EACH ROW EXECUTE FUNCTION gamilit.audit_profile_changes()

