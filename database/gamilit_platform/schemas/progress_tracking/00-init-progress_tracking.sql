-- =====================================================
-- Progress Tracking Schema - Initialization Script
-- =====================================================
-- Description: Inicializa todo el schema progress_tracking
-- Date: 2025-10-28
-- =====================================================

\echo '=================================================='
\echo 'Initializing progress_tracking schema...'
\echo '=================================================='

-- ============================================
-- TABLES
-- ============================================
\echo 'Creating progress_tracking tables...'
\i tables/01-module_progress.sql
\i tables/02-learning_sessions.sql
\i tables/03-exercise_attempts.sql
\i tables/04-exercise_submissions.sql
\i tables/05-scheduled_missions.sql

-- ============================================
-- FUNCTIONS
-- ============================================
\echo 'Creating progress_tracking functions...'
\i functions/01-calculate_module_progress.sql
\i functions/02-get_user_progress_summary.sql
\i functions/03-update_exercise_submissions_updated_at.sql

-- ============================================
-- TRIGGERS
-- ============================================
\echo 'Creating progress_tracking triggers...'
\i triggers/21-trg_update_user_stats_on_exercise.sql
\i triggers/22-exercise_submissions_updated_at.sql
\i triggers/23-trg_module_progress_updated_at.sql

-- ============================================
-- INDEXES
-- ============================================
\echo 'Creating progress_tracking indexes...'
\i indexes/01-idx_module_progress_analytics_gin.sql

-- ============================================
-- VIEWS
-- ============================================
\echo 'Creating progress_tracking views...'
\i views/01-user_progress_summary.sql

-- ============================================
-- RLS POLICIES
-- ============================================
\echo 'Enabling RLS and creating policies...'
\i rls-policies/01-enable-rls.sql
\i rls-policies/02-policies.sql
\i rls-policies/03-grants.sql

\echo 'progress_tracking schema initialized successfully!'
