-- =====================================================
-- Table: gamification_system.inventory_transactions
-- Description: Historial de transacciones de items del inventario (compras, usos, regalos, etc.)
-- Dependencies: auth_management.profiles
-- Created: 2025-10-28
-- Modified: 2025-10-28
-- =====================================================

SET search_path TO gamification_system, public;

DROP TABLE IF EXISTS gamification_system.inventory_transactions CASCADE;

CREATE TABLE IF NOT EXISTS gamification_system.inventory_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth_management.profiles(id) ON DELETE CASCADE,
    item_id UUID NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    quantity INTEGER NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT chk_transaction_type CHECK (
        transaction_type IN ('PURCHASE', 'USE', 'GIFT_SENT', 'GIFT_RECEIVED', 'EXPIRED', 'ADMIN_GRANT')
    ),
    CONSTRAINT chk_quantity_not_zero CHECK (quantity != 0)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_user
    ON gamification_system.inventory_transactions(user_id);

CREATE INDEX IF NOT EXISTS idx_inventory_transactions_item
    ON gamification_system.inventory_transactions(item_id);

CREATE INDEX IF NOT EXISTS idx_inventory_transactions_user_item
    ON gamification_system.inventory_transactions(user_id, item_id);

CREATE INDEX IF NOT EXISTS idx_inventory_transactions_type
    ON gamification_system.inventory_transactions(transaction_type);

CREATE INDEX IF NOT EXISTS idx_inventory_transactions_created
    ON gamification_system.inventory_transactions(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_inventory_transactions_metadata
    ON gamification_system.inventory_transactions USING GIN(metadata);

-- Comments
COMMENT ON TABLE gamification_system.inventory_transactions IS 'Historial de transacciones de items del inventario de usuarios (compras, usos, regalos, expiraciones)';
COMMENT ON COLUMN gamification_system.inventory_transactions.user_id IS 'Usuario que realiza la transacción';
COMMENT ON COLUMN gamification_system.inventory_transactions.item_id IS 'ID del item involucrado en la transacción';
COMMENT ON COLUMN gamification_system.inventory_transactions.transaction_type IS 'Tipo: PURCHASE, USE, GIFT_SENT, GIFT_RECEIVED, EXPIRED, ADMIN_GRANT';
COMMENT ON COLUMN gamification_system.inventory_transactions.quantity IS 'Cantidad de items (positivo para añadir, negativo para restar)';
COMMENT ON COLUMN gamification_system.inventory_transactions.metadata IS 'Información adicional en formato JSON (precio, destinatario, motivo, etc.)';
COMMENT ON COLUMN gamification_system.inventory_transactions.created_at IS 'Fecha y hora de la transacción';

-- Permissions
ALTER TABLE gamification_system.inventory_transactions OWNER TO postgres;
GRANT ALL ON TABLE gamification_system.inventory_transactions TO gamilit_user;
