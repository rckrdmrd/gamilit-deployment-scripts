-- =====================================================
-- Function: gamification_system.spend_ml_coins
-- Description: Gasta ML Coins con validación de fondos suficientes
-- Parameters: p_user_id uuid, p_amount integer, p_transaction_type text, p_description text, p_reference_id uuid, p_reference_type text
-- Returns: uuid
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION gamification_system.spend_ml_coins(p_user_id uuid, p_amount integer, p_transaction_type text, p_description text, p_reference_id uuid DEFAULT NULL::uuid, p_reference_type text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_transaction_id UUID;
    v_current_balance INTEGER;
    v_new_balance INTEGER;
BEGIN
    -- Get current balance with row lock to prevent race conditions
    SELECT ml_coins INTO v_current_balance
    FROM gamification_system.user_stats
    WHERE user_id = p_user_id
    FOR UPDATE;

    -- Validate sufficient funds
    IF v_current_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient ML Coins. Current: %, Required: %', v_current_balance, p_amount;
    END IF;

    -- Calculate new balance
    v_new_balance := v_current_balance - p_amount;

    -- Update user stats
    UPDATE gamification_system.user_stats
    SET ml_coins = v_new_balance,
        ml_coins_spent_total = ml_coins_spent_total + p_amount,
        updated_at = gamilit.now_mexico()
    WHERE user_id = p_user_id;

    -- Create transaction record
    INSERT INTO gamification_system.ml_coins_transactions (
        user_id,
        amount,
        balance_before,
        balance_after,
        transaction_type,
        description,
        reference_id,
        reference_type
    ) VALUES (
        p_user_id,
        -p_amount,
        v_current_balance,
        v_new_balance,
        p_transaction_type,
        p_description,
        p_reference_id,
        p_reference_type
    ) RETURNING id INTO v_transaction_id;

    RETURN v_transaction_id;
END;
$function$;

COMMENT ON FUNCTION gamification_system.spend_ml_coins(p_user_id uuid, p_amount integer, p_transaction_type text, p_description text, p_reference_id uuid, p_reference_type text) IS 'Gasta ML Coins con validación de fondos suficientes';
