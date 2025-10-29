-- =====================================================
-- Function: gamilit.initialize_user_missions
-- Description: Inicializa misiones diarias y semanales para un nuevo usuario
-- Parameters: p_user_id UUID - ID del usuario
-- Returns: void
-- Created: 2025-10-28
-- Note: missions.user_id references profiles.id, not auth.users.id
-- =====================================================

CREATE OR REPLACE FUNCTION gamilit.initialize_user_missions(p_user_id UUID)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_profile_id UUID;
    v_daily_end_date TIMESTAMP WITH TIME ZONE;
    v_weekly_end_date TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Get profile_id for the user (missions.user_id references profiles.id)
    SELECT id INTO v_profile_id
    FROM auth_management.profiles
    WHERE user_id = p_user_id;

    IF v_profile_id IS NULL THEN
        RAISE EXCEPTION 'Profile not found for user %', p_user_id;
    END IF;

    -- Daily missions expire at end of day (23:59:59 UTC)
    v_daily_end_date := (CURRENT_DATE + INTERVAL '1 day' - INTERVAL '1 second') AT TIME ZONE 'UTC';

    -- Weekly missions expire at end of week (Sunday 23:59:59 UTC)
    v_weekly_end_date := (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '7 days' - INTERVAL '1 second') AT TIME ZONE 'UTC';

    -- Create 3 daily missions (simplified templates)
    -- Mission 1: Complete 3 exercises
    INSERT INTO gamification_system.missions (
        user_id,
        mission_type,
        template_id,
        title,
        description,
        objectives,
        rewards,
        end_date
    ) VALUES (
        v_profile_id,
        'daily',
        'daily_complete_exercises',
        'Completa 3 Ejercicios',
        'Completa 3 ejercicios hoy para ganar recompensas',
        '[{"type": "complete_exercises", "target": 3, "current": 0}]'::jsonb,
        '{"xp": 50, "mlCoins": 25}'::jsonb,
        v_daily_end_date
    );

    -- Mission 2: Earn 100 XP
    INSERT INTO gamification_system.missions (
        user_id,
        mission_type,
        template_id,
        title,
        description,
        objectives,
        rewards,
        end_date
    ) VALUES (
        v_profile_id,
        'daily',
        'daily_earn_xp',
        'Gana 100 XP',
        'Gana 100 puntos de experiencia hoy',
        '[{"type": "earn_xp", "target": 100, "current": 0}]'::jsonb,
        '{"xp": 25, "mlCoins": 15}'::jsonb,
        v_daily_end_date
    );

    -- Mission 3: Perfect score
    INSERT INTO gamification_system.missions (
        user_id,
        mission_type,
        template_id,
        title,
        description,
        objectives,
        rewards,
        end_date
    ) VALUES (
        v_profile_id,
        'daily',
        'daily_perfect_score',
        'Puntaje Perfecto',
        'Consigue un 100% en cualquier ejercicio',
        '[{"type": "perfect_score", "target": 1, "current": 0}]'::jsonb,
        '{"xp": 75, "mlCoins": 35}'::jsonb,
        v_daily_end_date
    );

    -- Create 5 weekly missions
    -- Weekly Mission 1: Complete 15 exercises
    INSERT INTO gamification_system.missions (
        user_id,
        mission_type,
        template_id,
        title,
        description,
        objectives,
        rewards,
        end_date
    ) VALUES (
        v_profile_id,
        'weekly',
        'weekly_complete_exercises',
        'Completa 15 Ejercicios',
        'Completa 15 ejercicios esta semana',
        '[{"type": "complete_exercises", "target": 15, "current": 0}]'::jsonb,
        '{"xp": 200, "mlCoins": 100}'::jsonb,
        v_weekly_end_date
    );

    -- Weekly Mission 2: Earn 500 XP
    INSERT INTO gamification_system.missions (
        user_id,
        mission_type,
        template_id,
        title,
        description,
        objectives,
        rewards,
        end_date
    ) VALUES (
        v_profile_id,
        'weekly',
        'weekly_earn_xp',
        'Gana 500 XP',
        'Gana 500 puntos de experiencia esta semana',
        '[{"type": "earn_xp", "target": 500, "current": 0}]'::jsonb,
        '{"xp": 150, "mlCoins": 75}'::jsonb,
        v_weekly_end_date
    );

    -- Weekly Mission 3: 7-day streak
    INSERT INTO gamification_system.missions (
        user_id,
        mission_type,
        template_id,
        title,
        description,
        objectives,
        rewards,
        end_date
    ) VALUES (
        v_profile_id,
        'weekly',
        'weekly_7_day_streak',
        'Racha de 7 Días',
        'Mantén una racha de 7 días seguidos',
        '[{"type": "maintain_streak", "target": 7, "current": 0}]'::jsonb,
        '{"xp": 300, "mlCoins": 150}'::jsonb,
        v_weekly_end_date
    );

    -- Weekly Mission 4: Complete module
    INSERT INTO gamification_system.missions (
        user_id,
        mission_type,
        template_id,
        title,
        description,
        objectives,
        rewards,
        end_date
    ) VALUES (
        v_profile_id,
        'weekly',
        'weekly_complete_module',
        'Completa un Módulo',
        'Completa todos los ejercicios de un módulo',
        '[{"type": "complete_module", "target": 1, "current": 0}]'::jsonb,
        '{"xp": 250, "mlCoins": 125}'::jsonb,
        v_weekly_end_date
    );

    -- Weekly Mission 5: High accuracy
    INSERT INTO gamification_system.missions (
        user_id,
        mission_type,
        template_id,
        title,
        description,
        objectives,
        rewards,
        end_date
    ) VALUES (
        v_profile_id,
        'weekly',
        'weekly_high_accuracy',
        'Alta Precisión',
        'Consigue 90% o más en 5 ejercicios',
        '[{"type": "high_accuracy", "target": 5, "current": 0}]'::jsonb,
        '{"xp": 175, "mlCoins": 90}'::jsonb,
        v_weekly_end_date
    );

    RAISE NOTICE 'Initialized 3 daily and 5 weekly missions for user %', p_user_id;
END;
$function$;

COMMENT ON FUNCTION gamilit.initialize_user_missions(UUID) IS 'Inicializa 3 misiones diarias y 5 semanales para un nuevo usuario estudiante';
