-- =====================================================
-- GAMILIT Platform - Database Validation Script
-- =====================================================
-- Version: 2.0
-- Date: 2025-10-28
-- Description: Valida que todos los objetos se crearon correctamente
-- =====================================================

\echo ''
\echo '=================================================='
\echo 'DATABASE VALIDATION'
\echo '=================================================='
\echo ''

-- ============================================
-- 1. SCHEMAS
-- ============================================
\echo '1. Validating schemas...'
SELECT 
    'Schemas' AS object_type,
    COUNT(*) AS count,
    10 AS expected,
    CASE WHEN COUNT(*) >= 10 THEN 'PASS' ELSE 'FAIL' END AS status
FROM information_schema.schemata
WHERE schema_name IN (
    'auth',
    'auth_management',
    'gamification_system',
    'educational_content',
    'content_management',
    'progress_tracking',
    'social_features',
    'system_configuration',
    'audit_logging',
    'gamilit'
);

-- ============================================
-- 2. EXTENSIONS
-- ============================================
\echo ''
\echo '2. Validating extensions...'
SELECT 
    'Extensions' AS object_type,
    COUNT(*) AS count,
    4 AS expected,
    CASE WHEN COUNT(*) >= 4 THEN 'PASS' ELSE 'FAIL' END AS status
FROM pg_extension
WHERE extname IN (
    'uuid-ossp',
    'pgcrypto',
    'pg_trgm',
    'pg_stat_statements'
);

-- ============================================
-- 3. TABLES
-- ============================================
\echo ''
\echo '3. Validating tables...'
SELECT 
    'Tables' AS object_type,
    COUNT(*) AS count,
    35 AS expected,
    CASE WHEN COUNT(*) >= 35 THEN 'PASS' ELSE 'FAIL' END AS status
FROM information_schema.tables
WHERE table_schema IN (
    'auth',
    'auth_management',
    'gamification_system',
    'educational_content',
    'content_management',
    'progress_tracking',
    'social_features',
    'system_configuration',
    'audit_logging'
)
AND table_type = 'BASE TABLE';

-- Detalle por schema
\echo ''
\echo '   Tables by schema:'
SELECT 
    table_schema,
    COUNT(*) AS table_count
FROM information_schema.tables
WHERE table_schema IN (
    'auth',
    'auth_management',
    'gamification_system',
    'educational_content',
    'content_management',
    'progress_tracking',
    'social_features',
    'system_configuration',
    'audit_logging'
)
AND table_type = 'BASE TABLE'
GROUP BY table_schema
ORDER BY table_schema;

-- ============================================
-- 4. FUNCTIONS
-- ============================================
\echo ''
\echo '4. Validating functions...'
SELECT 
    'Functions' AS object_type,
    COUNT(*) AS count,
    30 AS expected,
    CASE WHEN COUNT(*) >= 25 THEN 'PASS' ELSE 'FAIL' END AS status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname IN (
    'auth_management',
    'gamification_system',
    'progress_tracking',
    'audit_logging',
    'gamilit'
)
AND p.prokind = 'f';

-- Detalle por schema
\echo ''
\echo '   Functions by schema:'
SELECT 
    n.nspname AS schema,
    COUNT(*) AS function_count
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname IN (
    'auth_management',
    'gamification_system',
    'progress_tracking',
    'audit_logging',
    'gamilit'
)
AND p.prokind = 'f'
GROUP BY n.nspname
ORDER BY n.nspname;

-- ============================================
-- 5. TRIGGERS
-- ============================================
\echo ''
\echo '5. Validating triggers...'
SELECT 
    'Triggers' AS object_type,
    COUNT(*) AS count,
    26 AS expected,
    CASE WHEN COUNT(*) >= 20 THEN 'PASS' ELSE 'FAIL' END AS status
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname IN (
    'auth_management',
    'gamification_system',
    'educational_content',
    'content_management',
    'progress_tracking',
    'social_features',
    'system_configuration'
)
AND NOT t.tgisinternal;

-- Detalle por schema
\echo ''
\echo '   Triggers by schema:'
SELECT 
    n.nspname AS schema,
    COUNT(*) AS trigger_count
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname IN (
    'auth_management',
    'gamification_system',
    'educational_content',
    'content_management',
    'progress_tracking',
    'social_features',
    'system_configuration'
)
AND NOT t.tgisinternal
GROUP BY n.nspname
ORDER BY n.nspname;

-- ============================================
-- 6. INDEXES
-- ============================================
\echo ''
\echo '6. Validating indexes...'
SELECT 
    'Indexes' AS object_type,
    COUNT(*) AS count,
    100 AS expected,
    CASE WHEN COUNT(*) >= 50 THEN 'PASS' ELSE 'FAIL' END AS status
FROM pg_indexes
WHERE schemaname IN (
    'auth_management',
    'gamification_system',
    'educational_content',
    'content_management',
    'progress_tracking',
    'social_features',
    'system_configuration',
    'audit_logging'
);

-- ============================================
-- 7. RLS POLICIES
-- ============================================
\echo ''
\echo '7. Validating RLS policies...'
SELECT 
    'RLS Policies' AS object_type,
    COUNT(*) AS count,
    60 AS expected,
    CASE WHEN COUNT(*) >= 40 THEN 'PASS' ELSE 'FAIL' END AS status
FROM pg_policies
WHERE schemaname IN (
    'auth_management',
    'gamification_system',
    'educational_content',
    'content_management',
    'progress_tracking',
    'social_features',
    'system_configuration'
);

-- Verificar que RLS está habilitado
\echo ''
\echo '   RLS enabled on tables:'
SELECT 
    schemaname,
    tablename,
    CASE WHEN rowsecurity THEN 'YES' ELSE 'NO' END AS rls_enabled
FROM pg_tables
WHERE schemaname IN (
    'auth_management',
    'gamification_system',
    'educational_content',
    'content_management',
    'progress_tracking',
    'social_features',
    'system_configuration'
)
ORDER BY schemaname, tablename;

-- ============================================
-- 8. MATERIALIZED VIEWS
-- ============================================
\echo ''
\echo '8. Validating materialized views...'
SELECT 
    'Materialized Views' AS object_type,
    COUNT(*) AS count,
    4 AS expected,
    CASE WHEN COUNT(*) = 4 THEN 'PASS' ELSE 'FAIL' END AS status
FROM pg_matviews
WHERE schemaname = 'gamification_system';

-- Listar materialized views
\echo ''
\echo '   Materialized views:'
SELECT 
    schemaname,
    matviewname,
    hasindexes
FROM pg_matviews
WHERE schemaname = 'gamification_system'
ORDER BY matviewname;

-- ============================================
-- 9. ENUMS
-- ============================================
\echo ''
\echo '9. Validating enums...'
SELECT 
    'Enums' AS object_type,
    COUNT(*) AS count,
    4 AS expected,
    CASE WHEN COUNT(*) >= 2 THEN 'PASS' ELSE 'FAIL' END AS status
FROM pg_type t
JOIN pg_namespace n ON t.typnamespace = n.oid
WHERE t.typtype = 'e'
AND n.nspname IN (
    'auth_management',
    'gamification_system',
    'progress_tracking'
);

-- ============================================
-- 10. FOREIGN KEYS
-- ============================================
\echo ''
\echo '10. Validating foreign keys...'
SELECT 
    'Foreign Keys' AS object_type,
    COUNT(*) AS count,
    40 AS expected,
    CASE WHEN COUNT(*) >= 30 THEN 'PASS' ELSE 'FAIL' END AS status
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY'
AND table_schema IN (
    'auth_management',
    'gamification_system',
    'educational_content',
    'content_management',
    'progress_tracking',
    'social_features',
    'system_configuration',
    'audit_logging'
);

-- ============================================
-- 11. CRITICAL FUNCTIONS
-- ============================================
\echo ''
\echo '11. Validating critical functions...'

-- get_current_user_id
SELECT 
    'get_current_user_id' AS function_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'gamilit'
        AND p.proname = 'get_current_user_id'
    ) THEN 'PASS' ELSE 'FAIL' END AS status;

-- get_current_user_role
SELECT 
    'get_current_user_role' AS function_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'gamilit'
        AND p.proname = 'get_current_user_role'
    ) THEN 'PASS' ELSE 'FAIL' END AS status;

-- calculate_level_from_xp
SELECT 
    'calculate_level_from_xp' AS function_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'gamification_system'
        AND p.proname = 'calculate_level_from_xp'
    ) THEN 'PASS' ELSE 'FAIL' END AS status;

-- ============================================
-- 12. SEED DATA
-- ============================================
\echo ''
\echo '12. Validating seed data...'

-- System settings
SELECT 
    'system_settings' AS table_name,
    COUNT(*) AS count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM system_configuration.system_settings;

-- Feature flags
SELECT 
    'feature_flags' AS table_name,
    COUNT(*) AS count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM system_configuration.feature_flags;

-- Achievements
SELECT 
    'achievements' AS table_name,
    COUNT(*) AS count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM gamification_system.achievements;

-- Achievement categories (NEW)
SELECT 
    'achievement_categories' AS table_name,
    COUNT(*) AS count,
    CASE WHEN COUNT(*) >= 5 THEN 'PASS' ELSE 'FAIL' END AS status
FROM gamification_system.achievement_categories;

-- ============================================
-- SUMMARY
-- ============================================
\echo ''
\echo '=================================================='
\echo 'VALIDATION SUMMARY'
\echo '=================================================='
\echo ''

-- Crear tabla temporal con resultados
CREATE TEMP TABLE validation_results AS
SELECT 'Schemas' AS component, 
       (SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name IN ('auth','auth_management','gamification_system','educational_content','content_management','progress_tracking','social_features','system_configuration','audit_logging','gamilit')) AS count,
       10 AS expected
UNION ALL
SELECT 'Tables',
       (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema IN ('auth','auth_management','gamification_system','educational_content','content_management','progress_tracking','social_features','system_configuration','audit_logging') AND table_type = 'BASE TABLE'),
       35
UNION ALL
SELECT 'Functions',
       (SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname IN ('auth_management','gamification_system','progress_tracking','audit_logging','gamilit') AND p.prokind = 'f'),
       30
UNION ALL
SELECT 'Triggers',
       (SELECT COUNT(*) FROM pg_trigger t JOIN pg_class c ON t.tgrelid = c.oid JOIN pg_namespace n ON c.relnamespace = n.oid WHERE n.nspname IN ('auth_management','gamification_system','educational_content','content_management','progress_tracking','social_features','system_configuration') AND NOT t.tgisinternal),
       26
UNION ALL
SELECT 'Indexes',
       (SELECT COUNT(*) FROM pg_indexes WHERE schemaname IN ('auth_management','gamification_system','educational_content','content_management','progress_tracking','social_features','system_configuration','audit_logging')),
       100
UNION ALL
SELECT 'RLS Policies',
       (SELECT COUNT(*) FROM pg_policies WHERE schemaname IN ('auth_management','gamification_system','educational_content','content_management','progress_tracking','social_features','system_configuration')),
       60
UNION ALL
SELECT 'Materialized Views',
       (SELECT COUNT(*) FROM pg_matviews WHERE schemaname = 'gamification_system'),
       4;

SELECT 
    component,
    count AS actual,
    expected,
    CASE 
        WHEN count >= expected THEN 'PASS'
        WHEN count >= expected * 0.8 THEN 'WARNING'
        ELSE 'FAIL'
    END AS status,
    ROUND((count::NUMERIC / expected::NUMERIC) * 100, 2) || '%' AS completion
FROM validation_results
ORDER BY 
    CASE component
        WHEN 'Schemas' THEN 1
        WHEN 'Tables' THEN 2
        WHEN 'Functions' THEN 3
        WHEN 'Triggers' THEN 4
        WHEN 'Indexes' THEN 5
        WHEN 'RLS Policies' THEN 6
        WHEN 'Materialized Views' THEN 7
    END;

\echo ''
\echo '=================================================='
\echo 'VALIDATION COMPLETED'
\echo '=================================================='
