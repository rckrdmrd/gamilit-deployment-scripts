-- =====================================================
-- Indexes: gamification_system.inventory_transactions
-- Description: Índices para optimizar consultas de transacciones de inventario
-- Table: gamification_system.inventory_transactions
-- Created: 2025-10-28
-- =====================================================

-- Index: Transacciones por usuario
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_user
    ON gamification_system.inventory_transactions(user_id);

-- Index: Transacciones por item
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_item
    ON gamification_system.inventory_transactions(item_id);

-- Index: Transacciones por usuario e item (compuesto)
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_user_item
    ON gamification_system.inventory_transactions(user_id, item_id);

-- Index: Transacciones por tipo
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_type
    ON gamification_system.inventory_transactions(transaction_type);

-- Index: Transacciones por fecha (descendente)
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_created
    ON gamification_system.inventory_transactions(created_at DESC);

-- Index: Metadata JSON (GIN)
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_metadata
    ON gamification_system.inventory_transactions USING GIN(metadata);

-- Comments
COMMENT ON INDEX gamification_system.idx_inventory_transactions_user IS 'Índice para consultar historial de transacciones de un usuario';
COMMENT ON INDEX gamification_system.idx_inventory_transactions_item IS 'Índice para consultar transacciones de un item específico';
COMMENT ON INDEX gamification_system.idx_inventory_transactions_user_item IS 'Índice compuesto para consultas de usuario + item';
COMMENT ON INDEX gamification_system.idx_inventory_transactions_type IS 'Índice para filtrar por tipo de transacción';
COMMENT ON INDEX gamification_system.idx_inventory_transactions_created IS 'Índice para ordenar transacciones por fecha (más recientes primero)';
COMMENT ON INDEX gamification_system.idx_inventory_transactions_metadata IS 'Índice GIN para búsquedas en metadata JSON';
