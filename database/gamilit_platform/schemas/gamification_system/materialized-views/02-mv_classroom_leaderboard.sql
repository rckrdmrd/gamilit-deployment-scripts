-- =====================================================
-- Materialized View: gamification_system.mv_classroom_leaderboard
-- =====================================================
-- Description: Pre-computed classroom-specific leaderboard ranking students within each classroom by total XP
-- Purpose: Optimize performance of classroom leaderboard queries (CRITICAL feature - most frequently accessed)
-- Refresh Strategy: Every 30 minutes (recommended) - high refresh frequency due to critical importance
-- Dependencies:
--   - social_features.classroom_members
--   - auth_management.profiles
--   - gamification_system.user_stats
--   - gamification_system.user_ranks
--   - gamification_system.user_achievements
-- Performance Impact: Reduces classroom leaderboard query time from ~3s to <50ms
-- Created: 2025-10-28
-- Modified: 2025-10-28
-- =====================================================

-- Drop if exists (for updates)
DROP MATERIALIZED VIEW IF EXISTS gamification_system.mv_classroom_leaderboard CASCADE;

-- Create materialized view
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

-- =====================================================
-- Indexes on Materialized View
-- =====================================================

-- Primary unique index (UNIQUE required for CONCURRENT refresh)
CREATE UNIQUE INDEX idx_mv_classroom_leaderboard_unique
  ON gamification_system.mv_classroom_leaderboard(classroom_id, user_id);

-- Index for classroom rank queries (most common access pattern)
CREATE INDEX idx_mv_classroom_leaderboard_classroom
  ON gamification_system.mv_classroom_leaderboard(classroom_id, rank);

-- Index for user lookups across classrooms
CREATE INDEX idx_mv_classroom_leaderboard_user
  ON gamification_system.mv_classroom_leaderboard(user_id);

-- Index for XP-based queries within classroom
CREATE INDEX idx_mv_classroom_leaderboard_xp
  ON gamification_system.mv_classroom_leaderboard(classroom_id, total_xp DESC);

-- =====================================================
-- Permissions
-- =====================================================

-- Grant SELECT to authenticated users (students and teachers can view classroom leaderboards)
GRANT SELECT ON gamification_system.mv_classroom_leaderboard TO authenticated;

-- =====================================================
-- Initial Refresh
-- =====================================================

-- Perform initial concurrent refresh
REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_classroom_leaderboard;

-- =====================================================
-- Usage Examples
-- =====================================================
-- Get top 10 students in a specific classroom:
-- SELECT rank, user_id, full_name, total_xp, current_rank, level
-- FROM gamification_system.mv_classroom_leaderboard
-- WHERE classroom_id = 'classroom-uuid-here'
-- ORDER BY rank
-- LIMIT 10;
--
-- Get a specific user's rank in their classroom:
-- SELECT classroom_id, rank, total_xp, achievements_count
-- FROM gamification_system.mv_classroom_leaderboard
-- WHERE user_id = 'user-uuid-here';
--
-- Get all classrooms with their top student:
-- SELECT DISTINCT ON (classroom_id)
--   classroom_id, user_id, full_name, total_xp
-- FROM gamification_system.mv_classroom_leaderboard
-- WHERE rank = 1
-- ORDER BY classroom_id;
-- =====================================================
