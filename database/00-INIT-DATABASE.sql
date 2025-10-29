-- =====================================================
-- GAMILIT Platform - Database Initialization Script
-- =====================================================
-- Version: 2.0
-- Date: 2025-10-28
-- PostgreSQL: 16+
-- Description: Script maestro para inicializar TODA la base de datos en orden correcto
-- =====================================================

-- Configuración de cliente
\set ON_ERROR_STOP on
\set ECHO all

\echo '=================================================='
\echo 'GAMILIT Platform - Database Initialization'
\echo 'Version: 2.0'
\echo 'Date: 2025-10-28'
\echo '=================================================='
\echo ''

-- ============================================
-- 1. CREATE DATABASE (ejecutar como superuser)
-- ============================================
\echo '1. Creating database...'
\i gamilit_platform/00-create-database.sql
\echo '   Database created successfully!'
\echo ''

-- CONECTAR A LA BASE DE DATOS
\c gamilit_platform

-- ============================================
-- 2. EXTENSIONS
-- ============================================
\echo '2. Installing extensions...'
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA public;
CREATE EXTENSION IF NOT EXISTS "pgcrypto" SCHEMA public;
CREATE EXTENSION IF NOT EXISTS "pg_trgm" SCHEMA public;
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" SCHEMA public;

\echo '   Extensions installed:'
\echo '   - uuid-ossp: UUID generation'
\echo '   - pgcrypto: Cryptographic functions'
\echo '   - pg_trgm: Trigram indexes for text search'
\echo '   - pg_stat_statements: Query performance tracking'
\echo ''

-- ============================================
-- 3. SCHEMAS
-- ============================================
\echo '3. Creating schemas...'
\i gamilit_platform/01-create-schemas.sql
\echo '   Schemas created successfully!'
\echo ''

-- ============================================
-- 4. ENUMS
-- ============================================
\echo '4. Creating enums...'
\i gamilit_platform/02-create-enums.sql
\echo '   Enums created successfully!'
\echo ''

-- ============================================
-- 5. TABLES (in dependency order)
-- ============================================
\echo '5. Creating tables...'
\echo ''

-- 5.1 Auth Management (base tables)
\echo '   5.1 Auth Management tables...'
\i gamilit_platform/schemas/auth_management/tables/01-tenants.sql
\i gamilit_platform/schemas/auth_management/tables/02-profiles.sql
\i gamilit_platform/schemas/auth_management/tables/03-user_roles.sql
\i gamilit_platform/schemas/auth_management/tables/04-memberships.sql
\i gamilit_platform/schemas/auth_management/tables/05-auth_attempts.sql
\i gamilit_platform/schemas/auth_management/tables/06-user_sessions.sql
\i gamilit_platform/schemas/auth_management/tables/07-email_verification_tokens.sql
\i gamilit_platform/schemas/auth_management/tables/08-password_reset_tokens.sql
\i gamilit_platform/schemas/auth_management/tables/09-security_events.sql

-- 5.2 Auth Schema (Supabase compatibility)
\echo '   5.2 Auth schema tables...'
\i gamilit_platform/schemas/auth/tables/01-users.sql

-- 5.3 Gamification System
\echo '   5.3 Gamification System tables...'
\i gamilit_platform/schemas/gamification_system/tables/01-user_stats.sql
\i gamilit_platform/schemas/gamification_system/tables/02-user_ranks.sql
\i gamilit_platform/schemas/gamification_system/tables/03-achievements.sql
\i gamilit_platform/schemas/gamification_system/tables/04-user_achievements.sql
\i gamilit_platform/schemas/gamification_system/tables/05-ml_coins_transactions.sql
\i gamilit_platform/schemas/gamification_system/tables/06-missions.sql
\i gamilit_platform/schemas/gamification_system/tables/07-comodines_inventory.sql
\i gamilit_platform/schemas/gamification_system/tables/08-notifications.sql
\i gamilit_platform/schemas/gamification_system/tables/09-leaderboard_metadata.sql

-- 5.4 Educational Content
\echo '   5.4 Educational Content tables...'
\i gamilit_platform/schemas/educational_content/tables/01-courses.sql
\i gamilit_platform/schemas/educational_content/tables/02-modules.sql
\i gamilit_platform/schemas/educational_content/tables/03-assessment_rubrics.sql

-- 5.5 Content Management
\echo '   5.5 Content Management tables...'
\i gamilit_platform/schemas/content_management/tables/01-content_library.sql
\i gamilit_platform/schemas/content_management/tables/02-exercises.sql
\i gamilit_platform/schemas/content_management/tables/03-questions.sql

-- 5.6 Progress Tracking
\echo '   5.6 Progress Tracking tables...'
\i gamilit_platform/schemas/progress_tracking/tables/01-module_progress.sql
\i gamilit_platform/schemas/progress_tracking/tables/02-learning_sessions.sql
\i gamilit_platform/schemas/progress_tracking/tables/03-exercise_attempts.sql
\i gamilit_platform/schemas/progress_tracking/tables/04-exercise_submissions.sql

-- 5.7 Social Features
\echo '   5.7 Social Features tables...'
\i gamilit_platform/schemas/social_features/tables/01-classrooms.sql
\i gamilit_platform/schemas/social_features/tables/02-classroom_members.sql

-- 5.8 System Configuration
\echo '   5.8 System Configuration tables...'
\i gamilit_platform/schemas/system_configuration/tables/01-system_settings.sql
\i gamilit_platform/schemas/system_configuration/tables/02-feature_flags.sql

-- 5.9 Audit Logging
\echo '   5.9 Audit Logging tables...'
\i gamilit_platform/schemas/audit_logging/tables/01-audit_logs.sql
\i gamilit_platform/schemas/audit_logging/tables/02-performance_metrics.sql
\i gamilit_platform/schemas/audit_logging/tables/03-system_alerts.sql
\i gamilit_platform/schemas/audit_logging/tables/04-system_logs.sql
\i gamilit_platform/schemas/audit_logging/tables/05-user_activity_logs.sql

\echo '   All tables created successfully!'
\echo ''

-- ============================================
-- 6. FUNCTIONS
-- ============================================
\echo '6. Creating functions...'
\echo ''

-- 6.1 Gamilit Schema Functions (core auth functions)
\echo '   6.1 Core auth functions...'
\i gamilit_platform/schemas/gamilit/functions/01-audit_profile_changes.sql
\i gamilit_platform/schemas/gamilit/functions/02-get_current_user_id.sql
\i gamilit_platform/schemas/gamilit/functions/03-get_current_user_role.sql
\i gamilit_platform/schemas/gamilit/functions/04-initialize_user_stats.sql
\i gamilit_platform/schemas/gamilit/functions/05-is_admin.sql
\i gamilit_platform/schemas/gamilit/functions/06-is_super_admin.sql
\i gamilit_platform/schemas/gamilit/functions/06-now_mexico.sql
\i gamilit_platform/schemas/gamilit/functions/07-update_classroom_member_count.sql
\i gamilit_platform/schemas/gamilit/functions/08-update_updated_at.sql
\i gamilit_platform/schemas/gamilit/functions/09-update_updated_at_column.sql
\i gamilit_platform/schemas/gamilit/functions/10-update_user_stats_on_exercise_complete.sql

-- 6.2 Auth Management Functions
\echo '   6.2 Auth management functions...'
\i gamilit_platform/schemas/auth_management/functions/01-handle_new_user.sql
\i gamilit_platform/schemas/auth_management/functions/02-cleanup_expired_sessions.sql
\i gamilit_platform/schemas/auth_management/functions/03-update_auth_attempts_updated_at.sql
\i gamilit_platform/schemas/auth_management/functions/04-update_email_verification_tokens_updated_at.sql
\i gamilit_platform/schemas/auth_management/functions/05-update_memberships_updated_at.sql
\i gamilit_platform/schemas/auth_management/functions/06-update_password_reset_tokens_updated_at.sql
\i gamilit_platform/schemas/auth_management/functions/07-update_profiles_updated_at.sql
\i gamilit_platform/schemas/auth_management/functions/08-update_security_events_updated_at.sql
\i gamilit_platform/schemas/auth_management/functions/09-update_tenants_updated_at.sql
\i gamilit_platform/schemas/auth_management/functions/10-update_user_roles_updated_at.sql
\i gamilit_platform/schemas/auth_management/functions/11-update_user_sessions_updated_at.sql

-- 6.3 Gamification System Functions
\echo '   6.3 Gamification functions...'
\i gamilit_platform/schemas/gamification_system/functions/01-award_ml_coins.sql
\i gamilit_platform/schemas/gamification_system/functions/02-calculate_level_from_xp.sql
\i gamilit_platform/schemas/gamification_system/functions/03-calculate_xp_for_next_level.sql
\i gamilit_platform/schemas/gamification_system/functions/04-get_user_rank_requirements.sql
\i gamilit_platform/schemas/gamification_system/functions/05-spend_ml_coins.sql
\i gamilit_platform/schemas/gamification_system/functions/06-update_missions_updated_at.sql
\i gamilit_platform/schemas/gamification_system/functions/07-update_notifications_updated_at.sql
\i gamilit_platform/schemas/gamification_system/functions/08-recalculate_level_on_xp_change.sql

-- 6.4 Progress Tracking Functions
\echo '   6.4 Progress tracking functions...'
\i gamilit_platform/schemas/progress_tracking/functions/01-calculate_module_progress.sql
\i gamilit_platform/schemas/progress_tracking/functions/02-get_user_progress_summary.sql
\i gamilit_platform/schemas/progress_tracking/functions/03-update_exercise_submissions_updated_at.sql

-- 6.5 Audit Logging Functions
\echo '   6.5 Audit logging functions...'
\i gamilit_platform/schemas/audit_logging/functions/01-log_user_activity.sql
\i gamilit_platform/schemas/audit_logging/functions/02-cleanup_old_logs.sql

\echo '   All functions created successfully!'
\echo ''

-- ============================================
-- 7. TRIGGERS
-- ============================================
\echo '7. Creating triggers...'
\echo ''

\echo '   7.1 Auth Management triggers...'
\i gamilit_platform/schemas/auth_management/triggers/01-tenants_updated_at.sql
\i gamilit_platform/schemas/auth_management/triggers/02-profiles_updated_at.sql
\i gamilit_platform/schemas/auth_management/triggers/03-user_roles_updated_at.sql
\i gamilit_platform/schemas/auth_management/triggers/04-user_sessions_updated_at.sql
\i gamilit_platform/schemas/auth_management/triggers/05-memberships_updated_at.sql
\i gamilit_platform/schemas/auth_management/triggers/06-email_verification_tokens_updated_at.sql
\i gamilit_platform/schemas/auth_management/triggers/07-password_reset_tokens_updated_at.sql
\i gamilit_platform/schemas/auth_management/triggers/08-auth_attempts_updated_at.sql
\i gamilit_platform/schemas/auth_management/triggers/09-security_events_updated_at.sql
\i gamilit_platform/schemas/auth_management/triggers/10-trg_new_user_initialize.sql
\i gamilit_platform/schemas/auth_management/triggers/11-trg_profile_changes_audit.sql

\echo '   7.2 Gamification System triggers...'
\i gamilit_platform/schemas/gamification_system/triggers/12-missions_updated_at.sql
\i gamilit_platform/schemas/gamification_system/triggers/13-notifications_updated_at.sql
\i gamilit_platform/schemas/gamification_system/triggers/14-trg_recalculate_level_on_xp_change.sql

\echo '   7.3 Social Features triggers...'
\i gamilit_platform/schemas/social_features/triggers/15-trg_classroom_members_updated_at.sql
\i gamilit_platform/schemas/social_features/triggers/16-trg_classrooms_updated_at.sql
\i gamilit_platform/schemas/social_features/triggers/17-trg_update_classroom_count.sql

\echo '   7.4 System Configuration triggers...'
\i gamilit_platform/schemas/system_configuration/triggers/18-trg_feature_flags_updated_at.sql
\i gamilit_platform/schemas/system_configuration/triggers/19-trg_system_settings_updated_at.sql

\echo '   7.5 Content Management triggers...'
\i gamilit_platform/schemas/content_management/triggers/20-trg_exercises_updated_at.sql

\echo '   7.6 Progress Tracking triggers...'
\i gamilit_platform/schemas/progress_tracking/triggers/21-trg_update_user_stats_on_exercise.sql
\i gamilit_platform/schemas/progress_tracking/triggers/22-exercise_submissions_updated_at.sql
\i gamilit_platform/schemas/progress_tracking/triggers/23-trg_module_progress_updated_at.sql

\echo '   7.7 Educational Content triggers...'
\i gamilit_platform/schemas/educational_content/triggers/24-trg_assessment_rubrics_updated_at.sql
\i gamilit_platform/schemas/educational_content/triggers/25-trg_courses_updated_at.sql
\i gamilit_platform/schemas/educational_content/triggers/26-trg_modules_updated_at.sql

\echo '   All triggers created successfully!'
\echo ''

-- ============================================
-- 8. INDEXES
-- ============================================
\echo '8. Creating indexes...'
\echo ''

\echo '   8.1 Auth Management indexes...'
\i gamilit_platform/schemas/auth_management/indexes/01-tenants.sql
\i gamilit_platform/schemas/auth_management/indexes/02-profiles.sql
\i gamilit_platform/schemas/auth_management/indexes/03-user_roles.sql
\i gamilit_platform/schemas/auth_management/indexes/04-memberships.sql
\i gamilit_platform/schemas/auth_management/indexes/05-user_sessions.sql
\i gamilit_platform/schemas/auth_management/indexes/06-auth_attempts.sql
\i gamilit_platform/schemas/auth_management/indexes/07-email_verification_tokens.sql
\i gamilit_platform/schemas/auth_management/indexes/08-password_reset_tokens.sql
\i gamilit_platform/schemas/auth_management/indexes/09-security_events.sql

\echo '   8.2 Gamification System indexes...'
\i gamilit_platform/schemas/gamification_system/indexes/01-user_stats.sql
\i gamilit_platform/schemas/gamification_system/indexes/02-user_ranks.sql
\i gamilit_platform/schemas/gamification_system/indexes/03-achievements.sql
\i gamilit_platform/schemas/gamification_system/indexes/04-user_achievements.sql
\i gamilit_platform/schemas/gamification_system/indexes/05-ml_coins_transactions.sql
\i gamilit_platform/schemas/gamification_system/indexes/06-missions.sql
\i gamilit_platform/schemas/gamification_system/indexes/07-comodines_inventory.sql
\i gamilit_platform/schemas/gamification_system/indexes/08-notifications.sql

\echo '   8.3 Progress Tracking indexes...'
\i gamilit_platform/schemas/progress_tracking/indexes/01-idx_module_progress_analytics_gin.sql

\echo '   8.4 Content Management indexes...'
\i gamilit_platform/schemas/content_management/indexes/01-content_library.sql
\i gamilit_platform/schemas/content_management/indexes/02-exercises.sql
\i gamilit_platform/schemas/content_management/indexes/03-questions.sql

\echo '   All indexes created successfully!'
\echo ''

-- ============================================
-- 9. VIEWS (Regular and Materialized)
-- ============================================
\echo '9. Creating views...'
\echo ''

\echo '   9.1 Progress Tracking views...'
\i gamilit_platform/schemas/progress_tracking/views/01-user_progress_summary.sql

\echo '   9.2 Gamification System materialized views...'
\i gamilit_platform/schemas/gamification_system/views/01-leaderboard_coins.sql
\i gamilit_platform/schemas/gamification_system/views/02-leaderboard_global.sql
\i gamilit_platform/schemas/gamification_system/views/03-leaderboard_streaks.sql
\i gamilit_platform/schemas/gamification_system/views/04-leaderboard_xp.sql

\echo '   All views created successfully!'
\echo ''

-- ============================================
-- 10. RLS POLICIES
-- ============================================
\echo '10. Enabling RLS and creating policies...'
\echo ''

\echo '   10.1 Auth Management RLS...'
\i gamilit_platform/schemas/auth_management/rls-policies/01-enable-rls.sql
\i gamilit_platform/schemas/auth_management/rls-policies/02-policies.sql

\echo '   10.2 Gamification System RLS...'
\i gamilit_platform/schemas/gamification_system/rls-policies/01-enable-rls.sql
\i gamilit_platform/schemas/gamification_system/rls-policies/02-policies.sql

\echo '   10.3 Educational Content RLS...'
\i gamilit_platform/schemas/educational_content/rls-policies/01-enable-rls.sql
\i gamilit_platform/schemas/educational_content/rls-policies/02-policies.sql

\echo '   10.4 Content Management RLS...'
\i gamilit_platform/schemas/content_management/rls-policies/01-enable-rls.sql
\i gamilit_platform/schemas/content_management/rls-policies/02-policies.sql

\echo '   10.5 Progress Tracking RLS...'
\i gamilit_platform/schemas/progress_tracking/rls-policies/01-enable-rls.sql
\i gamilit_platform/schemas/progress_tracking/rls-policies/02-policies.sql

\echo '   10.6 Social Features RLS...'
\i gamilit_platform/schemas/social_features/rls-policies/01-enable-rls.sql
\i gamilit_platform/schemas/social_features/rls-policies/02-policies.sql

\echo '   10.7 System Configuration RLS...'
\i gamilit_platform/schemas/system_configuration/rls-policies/01-enable-rls.sql
\i gamilit_platform/schemas/system_configuration/rls-policies/02-policies.sql

\echo '   RLS enabled and policies created successfully!'
\echo ''

-- ============================================
-- 11. GRANTS
-- ============================================
\echo '11. Setting up permissions...'
\echo ''

\i gamilit_platform/schemas/auth_management/rls-policies/03-grants.sql
\i gamilit_platform/schemas/gamification_system/rls-policies/03-grants.sql
\i gamilit_platform/schemas/educational_content/rls-policies/03-grants.sql
\i gamilit_platform/schemas/content_management/rls-policies/03-grants.sql
\i gamilit_platform/schemas/progress_tracking/rls-policies/03-grants.sql
\i gamilit_platform/schemas/social_features/rls-policies/03-grants.sql
\i gamilit_platform/schemas/system_configuration/rls-policies/03-grants.sql

\echo '   Permissions granted successfully!'
\echo ''

-- ============================================
-- 12. SEED DATA
-- ============================================
\echo '12. Inserting seed data...'
\echo ''

\i gamilit_platform/seed-data/educational_content/01-seed-modules.sql
\i gamilit_platform/seed-data/educational_content/02-seed-assessment_rubrics.sql
\i gamilit_platform/seed-data/gamification_system/01-seed-achievements.sql
\i gamilit_platform/seed-data/gamification_system/02-seed-leaderboard_metadata.sql
\i gamilit_platform/seed-data/system_configuration/01-seed-system_settings.sql
\i gamilit_platform/seed-data/system_configuration/02-seed-feature_flags.sql

\echo '   Seed data inserted successfully!'
\echo ''

-- ============================================
-- FINAL VALIDATION
-- ============================================
\echo '=================================================='
\echo 'Database initialization completed successfully!'
\echo ''
\echo 'Running validation...'
\i 99-VALIDATE-DATABASE.sql
\echo '=================================================='
