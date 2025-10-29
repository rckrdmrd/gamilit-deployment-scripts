-- =====================================================
-- Function: gamilit.update_updated_at_column
-- Description: Actualiza automáticamente el campo updated_at
-- Parameters: None
-- Returns: trigger
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamilit.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = gamilit.now_mexico();
    RETURN NEW;
END;
$function$;

COMMENT ON FUNCTION gamilit.update_updated_at_column() IS 'Actualiza automáticamente el campo updated_at';
