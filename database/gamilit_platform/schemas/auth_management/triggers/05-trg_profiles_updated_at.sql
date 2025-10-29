-- =====================================================
-- Trigger: trg_profiles_updated_at
-- Table: auth_management.profiles
-- Function: update_updated_at_column
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON auth_management.profiles CASCADE;

CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON auth_management.profiles FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column()

