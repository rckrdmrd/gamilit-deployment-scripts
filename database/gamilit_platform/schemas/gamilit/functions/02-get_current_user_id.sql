-- =====================================================
-- Function: gamilit.get_current_user_id
-- Description: Retorna el ID del usuario actual de la sesión
-- Parameters: None
-- Returns: uuid
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamilit.get_current_user_id()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE
AS $function$
BEGIN
    -- This should be set by the application via SET SESSION
    -- Example: SET SESSION app.current_user_id = '<uuid>';
    RETURN NULLIF(current_setting('app.current_user_id', true), '')::UUID;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$function$;

COMMENT ON FUNCTION gamilit.get_current_user_id() IS 'Retorna el ID del usuario actual de la sesión';
