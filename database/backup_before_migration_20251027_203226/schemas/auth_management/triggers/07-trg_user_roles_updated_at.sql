-- =====================================================
-- Trigger: trg_user_roles_updated_at
-- Table: auth_management.user_roles
-- Function: update_updated_at_column
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_user_roles_updated_at ON auth_management.user_roles CASCADE;

CREATE TRIGGER trg_user_roles_updated_at BEFORE UPDATE ON auth_management.user_roles FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column()

