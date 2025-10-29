-- =====================================================
-- Function: gamilit.update_updated_at
-- Description: Trigger function to automatically update updated_at field
-- Parameters: None
-- Returns: trigger
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamilit.update_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = gamilit.now_mexico();
    RETURN NEW;
END;
$function$

COMMENT ON FUNCTION gamilit.update_updated_at() IS 'Trigger function to automatically update updated_at field';
