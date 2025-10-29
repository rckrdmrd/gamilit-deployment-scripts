-- =====================================================
-- Enums and Custom Types for gamilit_platform
-- Description: Tipos enumerados centralizados del sistema
-- Created: 2025-10-28
-- =====================================================

-- ============================================
-- AUTH MANAGEMENT ENUMS
-- ============================================

-- User theme preference
CREATE TYPE auth_management.theme_type AS ENUM (
    'light',
    'dark',
    'auto'
);

COMMENT ON TYPE auth_management.theme_type IS 'Preferencias de tema de interfaz del usuario';

-- User language preference
CREATE TYPE auth_management.language_type AS ENUM (
    'es',
    'en'
);

COMMENT ON TYPE auth_management.language_type IS 'Idiomas soportados por la plataforma';

-- ============================================
-- GAMIFICATION SYSTEM ENUMS
-- ============================================

-- Boost types
CREATE TYPE gamification_system.boost_type AS ENUM (
    'XP',
    'COINS',
    'LUCK',
    'DROP_RATE'
);

COMMENT ON TYPE gamification_system.boost_type IS 'Tipos de potenciadores temporales';

-- Inventory transaction types
CREATE TYPE gamification_system.inventory_transaction_type AS ENUM (
    'PURCHASE',
    'USE',
    'REWARD',
    'EXPIRE',
    'ADMIN_GRANT'
);

COMMENT ON TYPE gamification_system.inventory_transaction_type IS 'Tipos de transacciones de inventario';

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
\echo 'All enums created successfully!';
