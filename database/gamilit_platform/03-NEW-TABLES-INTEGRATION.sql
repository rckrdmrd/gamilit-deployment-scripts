-- =====================================================
-- GAMILIT PLATFORM - NEW TABLES INTEGRATION
-- =====================================================
-- Descripción: Integración de 5 tablas nuevas al sistema
-- Fecha: 2025-10-28
-- Version: 1.0
-- Tiempo estimado: 5 minutos
-- =====================================================
--
-- TABLAS INTEGRADAS:
-- 1. gamification_system.achievement_categories
-- 2. gamification_system.active_boosts
-- 3. gamification_system.inventory_transactions
-- 4. auth_management.user_preferences
-- 5. progress_tracking.scheduled_missions
--
-- =====================================================

\echo 'INICIANDO INTEGRACIÓN DE NUEVAS TABLAS'

BEGIN;

-- =====================================================
-- ORDEN DE INSTALACIÓN (Respetar dependencias)
-- =====================================================

\echo 'Instalando tablas independientes...'

-- TABLA 1: achievement_categories (sin dependencias)
\i schemas/gamification_system/tables/10-achievement_categories.sql

\echo 'Instalando tablas con dependencias...'

-- TABLA 2: active_boosts (depende de auth_management.profiles)
\i schemas/gamification_system/tables/11-active_boosts.sql

-- TABLA 3: inventory_transactions (depende de auth_management.profiles)
\i schemas/gamification_system/tables/12-inventory_transactions.sql

-- TABLA 4: user_preferences (depende de auth_management.profiles)
\i schemas/auth_management/tables/10-user_preferences.sql

-- TABLA 5: scheduled_missions (depende de auth_management.profiles)
\i schemas/progress_tracking/tables/05-scheduled_missions.sql

\echo 'Instalando índices...'

-- ÍNDICES: gamification_system
\i schemas/gamification_system/indexes/02-achievement_categories_indexes.sql
\i schemas/gamification_system/indexes/03-active_boosts_indexes.sql
\i schemas/gamification_system/indexes/04-inventory_transactions_indexes.sql

-- ÍNDICES: auth_management
\i schemas/auth_management/indexes/02-user_preferences_indexes.sql

-- ÍNDICES: progress_tracking
\i schemas/progress_tracking/indexes/01-scheduled_missions_indexes.sql

COMMIT;

\echo 'VALIDANDO INSTALACIÓN...'

-- Verificar que las tablas fueron creadas
SELECT
    schemaname,
    tablename,
    tableowner
FROM pg_tables
WHERE tablename IN (
    'achievement_categories',
    'active_boosts',
    'inventory_transactions',
    'user_preferences',
    'scheduled_missions'
)
ORDER BY schemaname, tablename;

-- Verificar índices creados
SELECT
    schemaname,
    tablename,
    COUNT(*) as index_count
FROM pg_indexes
WHERE tablename IN (
    'achievement_categories',
    'active_boosts',
    'inventory_transactions',
    'user_preferences',
    'scheduled_missions'
)
GROUP BY schemaname, tablename
ORDER BY schemaname, tablename;

\echo 'INTEGRACIÓN COMPLETADA EXITOSAMENTE'
