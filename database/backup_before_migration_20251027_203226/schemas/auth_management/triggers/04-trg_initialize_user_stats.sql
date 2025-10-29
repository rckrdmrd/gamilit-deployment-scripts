-- =====================================================
-- Trigger: trg_initialize_user_stats
-- Table: auth_management.profiles
-- Function: initialize_user_stats
-- Event: AFTER INSERT
-- Level: FOR EACH ROW
-- Description: Inicializa estadísticas de usuario al crear un nuevo perfil
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS trg_initialize_user_stats ON auth_management.profiles CASCADE;

CREATE TRIGGER trg_initialize_user_stats AFTER INSERT ON auth_management.profiles FOR EACH ROW EXECUTE FUNCTION gamilit.initialize_user_stats()

