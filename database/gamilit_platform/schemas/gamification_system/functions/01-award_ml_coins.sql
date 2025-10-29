-- =====================================================
-- Function: gamification_system.award_ml_coins
-- Description: Otorga ML Coins al usuario aplicando multiplicador de rango basado en current_rank y registra la transacción
-- Parameters: p_user_id uuid, p_amount integer, p_transaction_type text, p_description text, p_reference_id uuid, p_reference_type text
-- Returns: uuid
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamification_system.award_ml_coins(p_user_id uuid, p_amount integer, p_transaction_type text, p_description text, p_reference_id uuid DEFAULT NULL::uuid, p_reference_type text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_transaction_id UUID;
    v_current_balance INTEGER;
    v_new_balance INTEGER;
    v_current_rank rango_maya;
    v_multiplier DECIMAL(3,2);
    v_final_amount INTEGER;
BEGIN
    -- Get current balance with row lock to prevent race conditions
    SELECT ml_coins INTO v_current_balance
    FROM gamification_system.user_stats
    WHERE user_id = p_user_id
    FOR UPDATE;

    -- Get current rank
    SELECT current_rank INTO v_current_rank
    FROM gamification_system.user_ranks
    WHERE user_id = p_user_id AND is_current = true;

    -- Calculate multiplier based on rank
    v_multiplier := CASE v_current_rank
        WHEN 'nacom' THEN 1.00
        WHEN 'batab' THEN 1.25
        WHEN 'holcatte' THEN 1.50
        WHEN 'guerrero' THEN 1.75
        WHEN 'mercenario' THEN 2.00
        ELSE 1.00
    END;

    -- Apply rank multiplier to base amount
    v_final_amount := FLOOR(p_amount * v_multiplier);

    -- Calculate new balance with multiplied amount
    v_new_balance := v_current_balance + v_final_amount;

    -- Update user stats with final amount
    UPDATE gamification_system.user_stats
    SET ml_coins = v_new_balance,
        ml_coins_earned_total = ml_coins_earned_total + v_final_amount,
        updated_at = gamilit.now_mexico()
    WHERE user_id = p_user_id;

    -- Create transaction record with metadata
    INSERT INTO gamification_system.ml_coins_transactions (
        user_id,
        amount,
        balance_before,
        balance_after,
        transaction_type,
        description,
        reference_id,
        reference_type,
        multiplier,
        metadata
    ) VALUES (
        p_user_id,
        v_final_amount,
        v_current_balance,
        v_new_balance,
        p_transaction_type,
        p_description,
        p_reference_id,
        p_reference_type,
        v_multiplier,
        jsonb_build_object(
            'base_amount', p_amount,
            'rank', v_current_rank::text,
            'multiplier', v_multiplier,
            'final_amount', v_final_amount
        )
    ) RETURNING id INTO v_transaction_id;

    RETURN v_transaction_id;
END;
$function$;

COMMENT ON FUNCTION gamification_system.award_ml_coins(p_user_id uuid, p_amount integer, p_transaction_type text, p_description text, p_reference_id uuid, p_reference_type text) IS 'Otorga ML Coins al usuario aplicando multiplicador de rango basado en current_rank y registra la transacción';
