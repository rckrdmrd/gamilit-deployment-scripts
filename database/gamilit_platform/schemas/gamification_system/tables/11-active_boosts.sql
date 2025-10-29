-- =====================================================
-- Table: gamification_system.active_boosts
-- Description: Bonificadores temporales activos para usuarios (XP, COINS, LUCK, DROP_RATE)
-- Dependencies: auth_management.profiles
-- Created: 2025-10-28
-- Modified: 2025-10-28
-- =====================================================

SET search_path TO gamification_system, public;

DROP TABLE IF EXISTS gamification_system.active_boosts CASCADE;

CREATE TABLE IF NOT EXISTS gamification_system.active_boosts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth_management.profiles(id) ON DELETE CASCADE,
    boost_type VARCHAR(50) NOT NULL,
    multiplier NUMERIC(4,2) NOT NULL DEFAULT 1.0,
    source VARCHAR(100),
    activated_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN DEFAULT true,

    -- Constraints
    CONSTRAINT chk_multiplier_positive CHECK (multiplier > 1.0),
    CONSTRAINT chk_boost_type CHECK (boost_type IN ('XP', 'COINS', 'LUCK', 'DROP_RATE')),
    CONSTRAINT chk_boost_dates CHECK (expires_at > activated_at)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_active_boosts_user
    ON gamification_system.active_boosts(user_id);

CREATE INDEX IF NOT EXISTS idx_active_boosts_expires
    ON gamification_system.active_boosts(expires_at)
    WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_active_boosts_type
    ON gamification_system.active_boosts(boost_type)
    WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_active_boosts_user_type
    ON gamification_system.active_boosts(user_id, boost_type, is_active);

CREATE INDEX IF NOT EXISTS idx_active_boosts_active
    ON gamification_system.active_boosts(is_active, expires_at)
    WHERE is_active = true;

-- Trigger para updated_at (si se agrega columna updated_at en el futuro)
-- CREATE TRIGGER trg_active_boosts_updated_at
--     BEFORE UPDATE ON gamification_system.active_boosts
--     FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- Comments
COMMENT ON TABLE gamification_system.active_boosts IS 'Bonificadores temporales activos que multiplican XP, monedas, suerte o drop rate para usuarios';
COMMENT ON COLUMN gamification_system.active_boosts.user_id IS 'Usuario que tiene el boost activo';
COMMENT ON COLUMN gamification_system.active_boosts.boost_type IS 'Tipo de bonificador: XP, COINS, LUCK, DROP_RATE';
COMMENT ON COLUMN gamification_system.active_boosts.multiplier IS 'Multiplicador del boost (debe ser mayor a 1.0, ej: 1.5 = +50%)';
COMMENT ON COLUMN gamification_system.active_boosts.source IS 'Origen del boost (ej: PREMIUM, EVENT, ITEM, ACHIEVEMENT)';
COMMENT ON COLUMN gamification_system.active_boosts.activated_at IS 'Fecha y hora en que se activó el boost';
COMMENT ON COLUMN gamification_system.active_boosts.expires_at IS 'Fecha y hora de expiración del boost';
COMMENT ON COLUMN gamification_system.active_boosts.is_active IS 'Indica si el boost está activo o ya expiró';

-- Permissions
ALTER TABLE gamification_system.active_boosts OWNER TO gamilit_user;
GRANT ALL ON TABLE gamification_system.active_boosts TO gamilit_user;
