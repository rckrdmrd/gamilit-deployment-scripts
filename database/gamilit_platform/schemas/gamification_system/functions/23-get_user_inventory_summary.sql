-- Function: gamification_system.get_user_inventory_summary
-- Description: Obtiene resumen completo del inventario del usuario con estadísticas y adquisiciones recientes
-- Parameters:
--   - p_user_id: UUID - ID del usuario
-- Returns: TABLE (total_items, total_value_coins, items_by_category, consumables_count, cosmetics_count, boosts_count, recent_acquisitions)
-- Example:
--   SELECT * FROM gamification_system.get_user_inventory_summary('123e4567-e89b-12d3-a456-426614174000');
-- Dependencies: gamification_system.user_inventory, store_items
-- Created: 2025-10-28
-- Modified: 2025-10-28

CREATE OR REPLACE FUNCTION gamification_system.get_user_inventory_summary(
    p_user_id UUID
)
RETURNS TABLE (
    total_items INTEGER,
    total_value_coins INTEGER,
    items_by_category JSONB,
    consumables_count INTEGER,
    cosmetics_count INTEGER,
    boosts_count INTEGER,
    recent_acquisitions JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::INTEGER as total_items,
        SUM(si.price_ml_coins * ui.quantity)::INTEGER as total_value_coins,
        jsonb_object_agg(
            si.category,
            COUNT(*)
        ) as items_by_category,
        COUNT(*) FILTER (WHERE si.item_type = 'CONSUMABLE')::INTEGER as consumables_count,
        COUNT(*) FILTER (WHERE si.item_type = 'COSMETIC')::INTEGER as cosmetics_count,
        COUNT(*) FILTER (WHERE si.item_type = 'BOOST')::INTEGER as boosts_count,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'item_name', si2.name,
                    'quantity', ui2.quantity,
                    'acquired_at', ui2.acquired_at
                )
            )
            FROM gamification_system.user_inventory ui2
            JOIN gamification_system.store_items si2 ON si2.id = ui2.item_id
            WHERE ui2.user_id = p_user_id
            ORDER BY ui2.acquired_at DESC
            LIMIT 5
        ) as recent_acquisitions
    FROM gamification_system.user_inventory ui
    JOIN gamification_system.store_items si ON si.id = ui.item_id
    WHERE ui.user_id = p_user_id
    GROUP BY ui.user_id;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION gamification_system.get_user_inventory_summary(UUID) IS
    'Obtiene resumen completo del inventario del usuario con estadísticas';

-- Grant permissions
GRANT EXECUTE ON FUNCTION gamification_system.get_user_inventory_summary(UUID) TO authenticated;
