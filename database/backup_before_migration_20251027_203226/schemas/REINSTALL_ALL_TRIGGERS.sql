-- =====================================================
-- Script: Reinstalación Completa de Triggers
-- Base de datos: glit_platform
-- Total de triggers: 30
-- Fecha: 2025-10-27
-- =====================================================
-- IMPORTANTE: Este script reinstala todos los triggers
-- de la base de datos en el orden correcto.
-- =====================================================

\echo '=========================================='
\echo 'Reinstalando Triggers de glit_platform'
\echo 'Total: 30 triggers'
\echo '=========================================='
\echo ''

-- =====================================================
-- Schema: audit_logging (1 trigger)
-- =====================================================
\echo 'Schema: audit_logging (1 trigger)'
\i audit_logging/triggers/01-trg_system_alerts_updated_at.sql
\echo ''

-- =====================================================
-- Schema: auth_management (6 triggers)
-- =====================================================
\echo 'Schema: auth_management (6 triggers)'
\i auth_management/triggers/02-trg_memberships_updated_at.sql
\i auth_management/triggers/03-trg_audit_profile_changes.sql
\i auth_management/triggers/04-trg_initialize_user_stats.sql
\i auth_management/triggers/05-trg_profiles_updated_at.sql
\i auth_management/triggers/06-trg_tenants_updated_at.sql
\i auth_management/triggers/07-trg_user_roles_updated_at.sql
\echo ''

-- =====================================================
-- Schema: content_management (3 triggers)
-- =====================================================
\echo 'Schema: content_management (3 triggers)'
\i content_management/triggers/08-trg_content_templates_updated_at.sql
\i content_management/triggers/09-trg_marie_curie_content_updated_at.sql
\i content_management/triggers/10-trg_media_files_updated_at.sql
\echo ''

-- =====================================================
-- Schema: educational_content (4 triggers)
-- =====================================================
\echo 'Schema: educational_content (4 triggers)'
\i educational_content/triggers/11-trg_assessment_rubrics_updated_at.sql
\i educational_content/triggers/12-trg_exercises_updated_at.sql
\i educational_content/triggers/13-trg_media_resources_updated_at.sql
\i educational_content/triggers/14-trg_modules_updated_at.sql
\echo ''

-- =====================================================
-- Schema: gamification_system (6 triggers)
-- =====================================================
\echo 'Schema: gamification_system (6 triggers)'
\i gamification_system/triggers/15-trg_achievements_updated_at.sql
\i gamification_system/triggers/16-trg_comodines_inventory_updated_at.sql
\i gamification_system/triggers/17-missions_updated_at.sql
\i gamification_system/triggers/18-notifications_updated_at.sql
\i gamification_system/triggers/19-trg_user_ranks_updated_at.sql
\i gamification_system/triggers/20-trg_user_stats_updated_at.sql
\echo ''

-- =====================================================
-- Schema: progress_tracking (3 triggers)
-- =====================================================
\echo 'Schema: progress_tracking (3 triggers)'
\i progress_tracking/triggers/21-trg_update_user_stats_on_exercise.sql
\i progress_tracking/triggers/22-exercise_submissions_updated_at.sql
\i progress_tracking/triggers/23-trg_module_progress_updated_at.sql
\echo ''

-- =====================================================
-- Schema: social_features (5 triggers)
-- =====================================================
\echo 'Schema: social_features (5 triggers)'
\i social_features/triggers/24-trg_classroom_members_updated_at.sql
\i social_features/triggers/25-trg_update_classroom_count.sql
\i social_features/triggers/26-trg_classrooms_updated_at.sql
\i social_features/triggers/27-trg_schools_updated_at.sql
\i social_features/triggers/28-trg_teams_updated_at.sql
\echo ''

-- =====================================================
-- Schema: system_configuration (2 triggers)
-- =====================================================
\echo 'Schema: system_configuration (2 triggers)'
\i system_configuration/triggers/29-trg_feature_flags_updated_at.sql
\i system_configuration/triggers/30-trg_system_settings_updated_at.sql
\echo ''

\echo '=========================================='
\echo 'Reinstalación Completada'
\echo '=========================================='

-- Verificar triggers instalados
\echo ''
\echo 'Verificando triggers instalados:'
SELECT 
    n.nspname as schema,
    COUNT(*) as trigger_count
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE NOT t.tgisinternal
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
GROUP BY n.nspname
ORDER BY n.nspname;

\echo ''
\echo 'Total de triggers:'
SELECT COUNT(*) as total_triggers
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE NOT t.tgisinternal
  AND n.nspname NOT IN ('pg_catalog', 'information_schema');
