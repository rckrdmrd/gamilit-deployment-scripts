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
        -- Use NEW.user_id which points to auth.users.id (correct foreign key reference)
        INSERT INTO gamification_system.user_stats (
            user_id,
            tenant_id,
            ml_coins,
            ml_coins_earned_total
        ) VALUES (
            NEW.user_id,  -- Fixed: usar user_id en lugar de id
            NEW.tenant_id,
            100, -- Welcome bonus
            100
        )
        ON CONFLICT (user_id) DO NOTHING;  -- Prevent duplicates

        -- Create comodines inventory
        INSERT INTO gamification_system.comodines_inventory (
            user_id
        ) VALUES (
            NEW.user_id  -- Fixed: usar user_id en lugar de id
        )
        ON CONFLICT (user_id) DO NOTHING;

        -- Create initial user rank (starting with MERCENARIO - lowest rank)
        INSERT INTO gamification_system.user_ranks (
            user_id,
            tenant_id,
            current_rank
        ) VALUES (
            NEW.user_id,  -- Fixed: usar user_id en lugar de id
            NEW.tenant_id,
            'MERCENARIO'
        );

        -- NEW: Initialize daily and weekly missions for new student
        -- This ensures missions are available immediately after registration
        PERFORM gamilit.initialize_user_missions(NEW.user_id);
    END IF;

    RETURN NEW;
END;
$function$;

COMMENT ON FUNCTION gamilit.initialize_user_stats() IS 'Inicializa estadísticas de gamificación para nuevos usuarios';
