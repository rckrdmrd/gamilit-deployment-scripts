-- =====================================================
-- Materialized View: gamification_system.mv_weekly_leaderboard
-- =====================================================
-- Description: Pre-computed weekly leaderboard ranking students by XP earned this week
-- Purpose: Optimize performance of weekly leaderboard queries, showing current week's top performers
-- Refresh Strategy:
--   - Regular refresh: Every hour
--   - Weekly reset: Every Monday at 00:00 (via pg_cron or application logic)
-- Dependencies:
--   - auth_management.profiles
--   - gamification_system.user_stats (weekly_xp, weekly_exercises columns)
--   - gamification_system.user_ranks
-- Performance Impact: Reduces weekly leaderboard query time from ~1.5s to <50ms
-- Created: 2025-10-28
-- Modified: 2025-10-28
-- =====================================================

-- Drop if exists (for updates)
DROP MATERIALIZED VIEW IF EXISTS gamification_system.mv_weekly_leaderboard CASCADE;

-- Create materialized view
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

-- =====================================================
-- Indexes on Materialized View
-- =====================================================

-- Primary index on rank (UNIQUE required for CONCURRENT refresh)
CREATE UNIQUE INDEX idx_mv_weekly_leaderboard_rank
  ON gamification_system.mv_weekly_leaderboard(rank);

-- Index for user lookups
CREATE INDEX idx_mv_weekly_leaderboard_user
  ON gamification_system.mv_weekly_leaderboard(user_id);

-- Index for weekly XP-based queries
CREATE INDEX idx_mv_weekly_leaderboard_xp
  ON gamification_system.mv_weekly_leaderboard(weekly_xp DESC);

-- =====================================================
-- Permissions
-- =====================================================

-- Grant SELECT to authenticated users (students and teachers can view weekly leaderboard)
GRANT SELECT ON gamification_system.mv_weekly_leaderboard TO authenticated;

-- =====================================================
-- Initial Refresh
-- =====================================================

-- Perform initial concurrent refresh
REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_weekly_leaderboard;

-- =====================================================
-- Usage Examples
-- =====================================================
-- Get top 10 students for current week:
-- SELECT rank, user_id, full_name, weekly_xp, activities_completed
-- FROM gamification_system.mv_weekly_leaderboard
-- ORDER BY rank
-- LIMIT 10;
--
-- Get a specific user's weekly rank:
-- SELECT rank, weekly_xp, activities_completed
-- FROM gamification_system.mv_weekly_leaderboard
-- WHERE user_id = 'user-uuid-here';
--
-- Get all students with weekly activity:
-- SELECT COUNT(*) as active_students_this_week
-- FROM gamification_system.mv_weekly_leaderboard;
-- =====================================================
-- IMPORTANT NOTE: Weekly Stats Reset
-- =====================================================
-- The weekly_xp and weekly_exercises columns in user_stats must be reset
-- every Monday at 00:00. This should be handled by:
-- 1. Application-level cron job, OR
-- 2. Database trigger, OR
-- 3. pg_cron scheduled job
--
-- After resetting weekly stats, this MV should be refreshed immediately.
-- =====================================================
