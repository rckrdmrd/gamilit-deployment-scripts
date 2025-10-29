-- =====================================================
-- REBUILD ALL MATERIALIZED VIEWS
-- =====================================================
-- Description: Drop and recreate all materialized views with their indexes
-- Purpose: Complete rebuild when schema changes or major issues occur
-- WARNING: This will temporarily make MVs unavailable during rebuild
-- Usage: Execute only when necessary (schema changes, corruption, major updates)
-- Execution Time: ~30-60 seconds total (depends on data volume)
-- Created: 2025-10-28
-- Modified: 2025-10-28
-- =====================================================

\echo ''
\echo '========================================='
\echo 'REBUILD ALL MATERIALIZED VIEWS'
\echo '========================================='
\echo ''
\echo 'WARNING: This will drop and recreate all MVs'
\echo 'MVs will be temporarily unavailable during rebuild'
\echo ''
\echo 'Press Ctrl+C within 5 seconds to cancel...'
\echo ''

-- Pause for 5 seconds (simulate delay)
SELECT pg_sleep(5);

\echo 'Starting rebuild process...'
\echo ''

-- =====================================================
-- MV 1: Global Leaderboard
-- =====================================================

\echo '[1/4] Rebuilding mv_global_leaderboard...'
\timing on

-- Drop existing MV
DROP MATERIALIZED VIEW IF EXISTS gamification_system.mv_global_leaderboard CASCADE;

-- Recreate MV
CREATE MATERIALIZED VIEW gamification_system.mv_global_leaderboard AS
SELECT
    ROW_NUMBER() OVER (ORDER BY us.total_xp DESC) as rank,
    p.id as user_id,
    p.full_name,
    p.avatar_url,
    us.total_xp,
    ur.current_rank,
    us.ml_coins,
    us.level,
    COUNT(DISTINCT ua.id) as achievements_count,
    us.modules_completed,
    us.exercises_completed,
    us.current_streak
FROM auth_management.profiles p
JOIN gamification_system.user_stats us ON p.id = us.user_id
LEFT JOIN gamification_system.user_ranks ur ON p.id = ur.user_id AND ur.is_current = true
LEFT JOIN gamification_system.user_achievements ua ON p.id = ua.user_id
WHERE p.role = 'student' AND p.status = 'active'
GROUP BY p.id, p.full_name, p.avatar_url, us.total_xp, ur.current_rank, us.ml_coins, us.level,
         us.modules_completed, us.exercises_completed, us.current_streak
ORDER BY us.total_xp DESC
WITH DATA;

-- Create indexes
CREATE UNIQUE INDEX idx_mv_global_leaderboard_rank
  ON gamification_system.mv_global_leaderboard(rank);
CREATE INDEX idx_mv_global_leaderboard_user
  ON gamification_system.mv_global_leaderboard(user_id);
CREATE INDEX idx_mv_global_leaderboard_xp
  ON gamification_system.mv_global_leaderboard(total_xp DESC);

-- Grant permissions
GRANT SELECT ON gamification_system.mv_global_leaderboard TO authenticated;

\timing off
\echo '  Status: OK (3 indexes created)'
\echo ''

-- =====================================================
-- MV 2: Classroom Leaderboard
-- =====================================================

\echo '[2/4] Rebuilding mv_classroom_leaderboard...'
\timing on

-- Drop existing MV
DROP MATERIALIZED VIEW IF EXISTS gamification_system.mv_classroom_leaderboard CASCADE;

-- Recreate MV
CREATE MATERIALIZED VIEW gamification_system.mv_classroom_leaderboard AS
SELECT
    cm.classroom_id,
    ROW_NUMBER() OVER (PARTITION BY cm.classroom_id ORDER BY us.total_xp DESC) as rank,
    p.id as user_id,
    p.full_name,
    p.avatar_url,
    us.total_xp,
    ur.current_rank,
    us.ml_coins,
    us.level,
    COUNT(DISTINCT ua.id) as achievements_count,
    us.modules_completed,
    us.exercises_completed,
    us.current_streak
FROM social_features.classroom_members cm
JOIN auth_management.profiles p ON cm.student_id = p.id
JOIN gamification_system.user_stats us ON p.id = us.user_id
LEFT JOIN gamification_system.user_ranks ur ON p.id = ur.user_id AND ur.is_current = true
LEFT JOIN gamification_system.user_achievements ua ON p.id = ua.user_id
WHERE p.role = 'student' AND p.status = 'active'
GROUP BY cm.classroom_id, p.id, p.full_name, p.avatar_url, us.total_xp, ur.current_rank, us.ml_coins, us.level,
         us.modules_completed, us.exercises_completed, us.current_streak
ORDER BY cm.classroom_id, us.total_xp DESC
WITH DATA;

-- Create indexes
CREATE UNIQUE INDEX idx_mv_classroom_leaderboard_unique
  ON gamification_system.mv_classroom_leaderboard(classroom_id, user_id);
CREATE INDEX idx_mv_classroom_leaderboard_classroom
  ON gamification_system.mv_classroom_leaderboard(classroom_id, rank);
CREATE INDEX idx_mv_classroom_leaderboard_user
  ON gamification_system.mv_classroom_leaderboard(user_id);
CREATE INDEX idx_mv_classroom_leaderboard_xp
  ON gamification_system.mv_classroom_leaderboard(classroom_id, total_xp DESC);

-- Grant permissions
GRANT SELECT ON gamification_system.mv_classroom_leaderboard TO authenticated;

\timing off
\echo '  Status: OK (4 indexes created)'
\echo ''

-- =====================================================
-- MV 3: Weekly Leaderboard
-- =====================================================

\echo '[3/4] Rebuilding mv_weekly_leaderboard...'
\timing on

-- Drop existing MV
DROP MATERIALIZED VIEW IF EXISTS gamification_system.mv_weekly_leaderboard CASCADE;

-- Recreate MV
CREATE MATERIALIZED VIEW gamification_system.mv_weekly_leaderboard AS
SELECT
    ROW_NUMBER() OVER (ORDER BY us.weekly_xp DESC) as rank,
    p.id as user_id,
    p.full_name,
    p.avatar_url,
    ur.current_rank,
    us.weekly_xp,
    us.weekly_exercises as activities_completed,
    us.level,
    us.ml_coins
FROM auth_management.profiles p
JOIN gamification_system.user_stats us ON p.id = us.user_id
LEFT JOIN gamification_system.user_ranks ur ON p.id = ur.user_id AND ur.is_current = true
WHERE p.role = 'student' AND p.status = 'active' AND us.weekly_xp > 0
ORDER BY us.weekly_xp DESC
WITH DATA;

-- Create indexes
CREATE UNIQUE INDEX idx_mv_weekly_leaderboard_rank
  ON gamification_system.mv_weekly_leaderboard(rank);
CREATE INDEX idx_mv_weekly_leaderboard_user
  ON gamification_system.mv_weekly_leaderboard(user_id);
CREATE INDEX idx_mv_weekly_leaderboard_xp
  ON gamification_system.mv_weekly_leaderboard(weekly_xp DESC);

-- Grant permissions
GRANT SELECT ON gamification_system.mv_weekly_leaderboard TO authenticated;

\timing off
\echo '  Status: OK (3 indexes created)'
\echo ''

-- =====================================================
-- MV 4: Mechanic Leaderboard
-- =====================================================

\echo '[4/4] Rebuilding mv_mechanic_leaderboard...'
\timing on

-- Drop existing MV
DROP MATERIALIZED VIEW IF EXISTS gamification_system.mv_mechanic_leaderboard CASCADE;

-- Recreate MV
CREATE MATERIALIZED VIEW gamification_system.mv_mechanic_leaderboard AS
SELECT
    m.mission_type as mechanic_id,
    m.mission_type as mechanic_name,
    ROW_NUMBER() OVER (PARTITION BY m.mission_type ORDER BY us.total_xp DESC) as rank,
    p.id as user_id,
    p.full_name,
    p.avatar_url,
    ur.current_rank,
    us.total_xp as user_xp,
    us.level,
    us.ml_coins,
    COUNT(DISTINCT sm.id) as missions_scheduled
FROM gamification_system.missions m
CROSS JOIN auth_management.profiles p
JOIN gamification_system.user_stats us ON p.id = us.user_id
LEFT JOIN gamification_system.user_ranks ur ON p.id = ur.user_id AND ur.is_current = true
LEFT JOIN progress_tracking.scheduled_missions sm ON m.id = sm.mission_id
WHERE p.role = 'student' AND p.status = 'active'
GROUP BY m.mission_type, p.id, p.full_name, p.avatar_url, ur.current_rank, us.total_xp, us.level, us.ml_coins
HAVING us.total_xp > 0
ORDER BY m.mission_type, us.total_xp DESC
WITH DATA;

-- Create indexes
CREATE UNIQUE INDEX idx_mv_mechanic_leaderboard_unique
  ON gamification_system.mv_mechanic_leaderboard(mechanic_id, user_id);
CREATE INDEX idx_mv_mechanic_leaderboard_mechanic
  ON gamification_system.mv_mechanic_leaderboard(mechanic_id, rank);
CREATE INDEX idx_mv_mechanic_leaderboard_user
  ON gamification_system.mv_mechanic_leaderboard(user_id);
CREATE INDEX idx_mv_mechanic_leaderboard_xp
  ON gamification_system.mv_mechanic_leaderboard(mechanic_id, user_xp DESC);

-- Grant permissions
GRANT SELECT ON gamification_system.mv_mechanic_leaderboard TO authenticated;

\timing off
\echo '  Status: OK (4 indexes created)'
\echo ''

-- =====================================================
-- Rebuild Summary
-- =====================================================

\echo '========================================='
\echo 'REBUILD COMPLETE'
\echo '========================================='
\echo ''
\echo 'All 4 materialized views have been rebuilt successfully:'
\echo '  - mv_global_leaderboard (3 indexes)'
\echo '  - mv_classroom_leaderboard (4 indexes)'
\echo '  - mv_weekly_leaderboard (3 indexes)'
\echo '  - mv_mechanic_leaderboard (4 indexes)'
\echo ''
\echo 'Total: 4 MVs, 14 indexes'
\echo ''

-- Verify row counts
\echo 'Row counts after rebuild:'
\echo ''

SELECT 'mv_global_leaderboard' as materialized_view,
       COUNT(*) as row_count
FROM gamification_system.mv_global_leaderboard
UNION ALL
SELECT 'mv_classroom_leaderboard' as materialized_view,
       COUNT(*) as row_count
FROM gamification_system.mv_classroom_leaderboard
UNION ALL
SELECT 'mv_weekly_leaderboard' as materialized_view,
       COUNT(*) as row_count
FROM gamification_system.mv_weekly_leaderboard
UNION ALL
SELECT 'mv_mechanic_leaderboard' as materialized_view,
       COUNT(*) as row_count
FROM gamification_system.mv_mechanic_leaderboard
ORDER BY materialized_view;

\echo ''
\echo 'Materialized views are now ready to use.'
\echo ''
\echo 'IMPORTANT: If using pg_cron, verify scheduled jobs:'
\echo '  SELECT * FROM cron.job WHERE jobname LIKE ''%leaderboard%'';'
\echo ''
\echo '========================================='
\echo ''

-- =====================================================
-- USAGE NOTES
-- =====================================================
-- Execute this script with:
--   psql -U your_user -d your_database -f rebuild-all-mvs.sql
--
-- Or from psql prompt:
--   \i rebuild-all-mvs.sql
--
-- When to use this script:
--   - After schema changes to base tables
--   - After adding/removing columns to MVs
--   - When MV becomes corrupted
--   - When indexes need to be rebuilt
--   - During major database maintenance
--
-- CAUTION:
--   - MVs will be unavailable during rebuild (30-60 seconds)
--   - Queries will fail during this time
--   - Consider running during low-traffic periods
--   - After rebuild, pg_cron jobs will continue automatically
-- =====================================================
