-- =====================================================
-- Table: gamification_system.achievement_categories
-- Description: Categorías para clasificar logros del sistema de gamificación
-- Dependencies: Ninguna (tabla independiente)
-- Created: 2025-10-28
-- Modified: 2025-10-28
-- =====================================================

SET search_path TO gamification_system, public;

DROP TABLE IF EXISTS gamification_system.achievement_categories CASCADE;

CREATE TABLE IF NOT EXISTS gamification_system.achievement_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_url VARCHAR(500),
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT chk_achievement_categories_name CHECK (LENGTH(TRIM(name)) > 0),
    CONSTRAINT chk_achievement_categories_display_order CHECK (display_order >= 0)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_achievement_categories_active
    ON gamification_system.achievement_categories(is_active)
    WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_achievement_categories_display_order
    ON gamification_system.achievement_categories(display_order);

CREATE INDEX IF NOT EXISTS idx_achievement_categories_name
    ON gamification_system.achievement_categories(name);

-- Trigger para updated_at
CREATE TRIGGER trg_achievement_categories_updated_at
    BEFORE UPDATE ON gamification_system.achievement_categories
    FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- Comments
COMMENT ON TABLE gamification_system.achievement_categories IS 'Categorías para organizar y clasificar los logros del sistema de gamificación';
COMMENT ON COLUMN gamification_system.achievement_categories.name IS 'Nombre único de la categoría (ej: educational, social, missions, special, collection)';
COMMENT ON COLUMN gamification_system.achievement_categories.description IS 'Descripción de la categoría de logros';
COMMENT ON COLUMN gamification_system.achievement_categories.icon_url IS 'URL del icono representativo de la categoría';
COMMENT ON COLUMN gamification_system.achievement_categories.display_order IS 'Orden de visualización de la categoría (menor = primero)';
COMMENT ON COLUMN gamification_system.achievement_categories.is_active IS 'Indica si la categoría está activa y visible';

-- Permissions
ALTER TABLE gamification_system.achievement_categories OWNER TO gamilit_user;
GRANT ALL ON TABLE gamification_system.achievement_categories TO gamilit_user;
GRANT SELECT ON TABLE gamification_system.achievement_categories TO PUBLIC;
