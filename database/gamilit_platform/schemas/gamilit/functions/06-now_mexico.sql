-- =====================================================
-- Function: gamilit.now_mexico
-- Description: Retorna timestamp actual en zona horaria de México (America/Mexico_City)
-- Parameters: None
-- Returns: timestamp with time zone
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamilit.now_mexico()
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
    RETURN NOW() AT TIME ZONE 'America/Mexico_City';
END;
$function$;

COMMENT ON FUNCTION gamilit.now_mexico() IS 'Retorna timestamp actual en zona horaria de México (America/Mexico_City)';
