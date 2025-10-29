-- =====================================================
-- Function: gamilit.update_classroom_member_count
-- Description: Actualiza contador de miembros en aulas
-- Parameters: None
-- Returns: trigger
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamilit.update_classroom_member_count()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE social_features.classrooms
        SET current_students_count = current_students_count + 1
        WHERE id = NEW.classroom_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE social_features.classrooms
        SET current_students_count = GREATEST(0, current_students_count - 1)
        WHERE id = OLD.classroom_id;
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$function$;

COMMENT ON FUNCTION gamilit.update_classroom_member_count() IS 'Actualiza contador de miembros en aulas';
