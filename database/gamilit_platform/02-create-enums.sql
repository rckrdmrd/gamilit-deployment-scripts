-- =====================================================
-- Enums and Custom Types for gamilit_platform
-- Description: Tipos enumerados centralizados del sistema
-- Created: 2025-10-28
-- =====================================================

-- ============================================
-- PUBLIC ENUMS (Used across multiple schemas)
-- ============================================

-- System roles
CREATE TYPE public.gamilit_role AS ENUM (
    'student',
    'admin_teacher',
    'super_admin'
);

COMMENT ON TYPE public.gamilit_role IS 'Roles del sistema: estudiante, profesor administrador y super administrador';

-- Maya ranks for gamification
CREATE TYPE public.maya_rank AS ENUM (
    'NACOM',
    'BATAB',
    'HOLCATTE',
    'GUERRERO',
    'MERCENARIO'
);

COMMENT ON TYPE public.maya_rank IS 'Rangos jerárquicos mayas: NACOM (máximo), BATAB, HOLCATTE, GUERRERO, MERCENARIO (inicial)';

-- User status
CREATE TYPE public.user_status AS ENUM (
    'active',
    'inactive',
    'suspended',
    'deleted'
);

COMMENT ON TYPE public.user_status IS 'Estados posibles de un usuario en el sistema';

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
