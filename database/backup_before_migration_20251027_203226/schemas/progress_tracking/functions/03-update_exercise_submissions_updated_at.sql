-- =====================================================
-- Function: progress_tracking.update_exercise_submissions_updated_at
-- Description: No description available
-- Parameters: None
-- Returns: trigger
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION progress_tracking.update_exercise_submissions_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$
