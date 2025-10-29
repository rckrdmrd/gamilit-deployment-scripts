-- =====================================================
-- Function: gamilit.initialize_user_stats
-- Description: Inicializa estadísticas de gamificación para nuevos usuarios
-- Parameters: None
-- Returns: trigger
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamilit.initialize_user_stats()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.role = 'student' THEN
        INSERT INTO gamification_system.user_stats (
            user_id,
            tenant_id,
            ml_coins,
            ml_coins_earned_total
        ) VALUES (
            NEW.id,
            NEW.tenant_id,
            100, -- Welcome bonus
            100
        );

        -- Create comodines inventory
        INSERT INTO gamification_system.comodines_inventory (
            user_id
        ) VALUES (
            NEW.id
        );

        -- Create initial user rank
        INSERT INTO gamification_system.user_ranks (
            user_id,
            tenant_id,
            current_rank
        ) VALUES (
            NEW.id,
            NEW.tenant_id,
            'nacom'
        );
    END IF;

    RETURN NEW;
END;
$function$

COMMENT ON FUNCTION gamilit.initialize_user_stats() IS 'Inicializa estadísticas de gamificación para nuevos usuarios';
