-- =====================================================
-- Function: gamilit.audit_profile_changes
-- Description: Audita cambios importantes en perfiles de usuario
-- Parameters: None
-- Returns: trigger
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamilit.audit_profile_changes()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        -- Log role changes
        IF OLD.role != NEW.role THEN
            INSERT INTO audit_logging.audit_logs (
                event_type,
                action,
                resource_type,
                resource_id,
                actor_id,
                old_values,
                new_values,
                description
            ) VALUES (
                'role_changed',
                'UPDATE',
                'profile',
                NEW.id,
                NEW.id,
                jsonb_build_object('role', OLD.role),
                jsonb_build_object('role', NEW.role),
                format('User role changed from %s to %s', OLD.role, NEW.role)
            );
        END IF;

        -- Log status changes
        IF OLD.status != NEW.status THEN
            INSERT INTO audit_logging.audit_logs (
                event_type,
                action,
                resource_type,
                resource_id,
                actor_id,
                old_values,
                new_values,
                description
            ) VALUES (
                'status_changed',
                'UPDATE',
                'profile',
                NEW.id,
                NEW.id,
                jsonb_build_object('status', OLD.status),
                jsonb_build_object('status', NEW.status),
                format('User status changed from %s to %s', OLD.status, NEW.status)
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$function$;

COMMENT ON FUNCTION gamilit.audit_profile_changes() IS 'Audita cambios importantes en perfiles de usuario';
