-- =====================================================
-- Trigger: notifications_updated_at
-- Table: gamification_system.notifications
-- Function: update_notifications_updated_at
-- Event: BEFORE UPDATE
-- Level: FOR EACH ROW
-- Description: Actualiza automáticamente el campo updated_at cuando se modifica un registro
-- Created: 2025-10-27
-- =====================================================

DROP TRIGGER IF EXISTS notifications_updated_at ON gamification_system.notifications CASCADE;

CREATE TRIGGER notifications_updated_at BEFORE UPDATE ON gamification_system.notifications FOR EACH ROW EXECUTE FUNCTION gamification_system.update_notifications_updated_at()

