-- Function: gamification_system.validate_inventory_action
-- Description: Valida si una acción de inventario puede ejecutarse (USE, PURCHASE, GIFT_SENT)
-- Parameters:
--   - p_user_id: UUID - ID del usuario
--   - p_item_id: UUID - ID del item
--   - p_action: VARCHAR(50) - Tipo de acción (USE, PURCHASE, GIFT_SENT)
--   - p_quantity: INTEGER - Cantidad de items (default 1)
-- Returns: TABLE (is_valid, error_code, error_message, current_quantity)
-- Example:
--   SELECT * FROM gamification_system.validate_inventory_action('123e4567-e89b-12d3-a456-426614174000', 'item-uuid', 'USE', 1);
-- Dependencies: gamification_system.store_items, user_inventory
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION gamification_system.validate_inventory_action(
    p_user_id UUID,
    p_item_id UUID,
    p_action VARCHAR(50),
    p_quantity INTEGER DEFAULT 1
)
RETURNS TABLE (
    is_valid BOOLEAN,
    error_code VARCHAR(50),
    error_message TEXT,
    current_quantity INTEGER
) AS $$
DECLARE
    v_current_qty INTEGER := 0;
    v_item_exists BOOLEAN;
BEGIN
    -- Verificar si el item existe
    SELECT EXISTS(
        SELECT 1 FROM gamification_system.store_items
        WHERE id = p_item_id AND is_active = true
    ) INTO v_item_exists;

    IF NOT v_item_exists THEN
        RETURN QUERY SELECT
            false,
            'ITEM_NOT_FOUND'::VARCHAR,
            'El item no existe o no está activo'::TEXT,
            0::INTEGER;
        RETURN;
    END IF;

    -- Obtener cantidad actual en inventario
    SELECT COALESCE(quantity, 0) INTO v_current_qty
    FROM gamification_system.user_inventory
    WHERE user_id = p_user_id AND item_id = p_item_id;

    -- Validar según acción
    CASE p_action
        WHEN 'USE' THEN
            IF v_current_qty < p_quantity THEN
                RETURN QUERY SELECT
                    false,
                    'INSUFFICIENT_QUANTITY'::VARCHAR,
                    'No tienes suficientes items'::TEXT,
                    v_current_qty;
                RETURN;
            END IF;

        WHEN 'PURCHASE' THEN
            -- Validación de compra se hace en otra función
            NULL;

        WHEN 'GIFT_SENT' THEN
            IF v_current_qty < p_quantity THEN
                RETURN QUERY SELECT
                    false,
                    'INSUFFICIENT_QUANTITY'::VARCHAR,
                    'No tienes suficientes items para regalar'::TEXT,
                    v_current_qty;
                RETURN;
            END IF;
    END CASE;

    -- Validación exitosa
    RETURN QUERY SELECT
        true,
        'SUCCESS'::VARCHAR,
        'Acción válida'::TEXT,
        v_current_qty;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION gamification_system.validate_inventory_action(UUID, UUID, VARCHAR, INTEGER) IS
    'Valida si una acción de inventario puede ejecutarse';

-- Grant permissions
GRANT EXECUTE ON FUNCTION gamification_system.validate_inventory_action(UUID, UUID, VARCHAR, INTEGER) TO authenticated;
