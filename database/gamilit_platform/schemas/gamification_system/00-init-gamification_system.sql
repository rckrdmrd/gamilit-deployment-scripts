-- =====================================================
-- Gamification System Schema - Initialization Script
-- =====================================================
-- Description: Inicializa todo el schema gamification_system
-- Date: 2025-10-28
-- =====================================================

\echo '=================================================='
\echo 'Initializing gamification_system schema...'
\echo '=================================================='

-- ============================================
-- TABLES
-- ============================================
\echo 'Creating gamification_system tables...'
\i tables/01-user_stats.sql
\i tables/02-user_ranks.sql
\i tables/03-achievements.sql
\i tables/04-user_achievements.sql
\i tables/05-ml_coins_transactions.sql
\i tables/06-missions.sql
\i tables/07-comodines_inventory.sql
\i tables/08-notifications.sql
\i tables/09-leaderboard_metadata.sql
\i tables/10-achievement_categories.sql
\i tables/11-active_boosts.sql
\i tables/12-inventory_transactions.sql

-- ============================================
-- FUNCTIONS
-- ============================================
\echo 'Creating gamification_system functions...'
\i functions/01-award_ml_coins.sql
\i functions/02-calculate_level_from_xp.sql
\i functions/03-calculate_xp_for_next_level.sql
\i functions/04-get_user_rank_requirements.sql
\i functions/05-spend_ml_coins.sql
\i functions/06-update_missions_updated_at.sql
\i functions/07-update_notifications_updated_at.sql
\i functions/08-recalculate_level_on_xp_change.sql

-- ============================================
-- TRIGGERS
-- ============================================
\echo 'Creating gamification_system triggers...'
\i triggers/12-missions_updated_at.sql
\i triggers/13-notifications_updated_at.sql
\i triggers/14-trg_recalculate_level_on_xp_change.sql

-- ============================================
-- INDEXES
-- ============================================
\echo 'Creating gamification_system indexes...'
\i indexes/01-user_stats.sql
\i indexes/02-user_ranks.sql
\i indexes/03-achievements.sql
\i indexes/04-user_achievements.sql
\i indexes/05-ml_coins_transactions.sql
\i indexes/06-missions.sql
\i indexes/07-comodines_inventory.sql
\i indexes/08-notifications.sql

-- ============================================
-- VIEWS
-- ============================================
\echo 'Creating gamification_system materialized views...'
\i views/01-leaderboard_coins.sql
\i views/02-leaderboard_global.sql
\i views/03-leaderboard_streaks.sql
\i views/04-leaderboard_xp.sql

-- ============================================
-- RLS POLICIES
-- ============================================
\echo 'Enabling RLS and creating policies...'
\i rls-policies/01-enable-rls.sql
\i rls-policies/02-policies.sql
\i rls-policies/03-grants.sql

\echo 'gamification_system schema initialized successfully!'
