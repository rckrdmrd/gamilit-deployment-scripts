-- =====================================================
-- MANUAL REFRESH: All Materialized Views
-- =====================================================
-- Description: Manually refresh all leaderboard materialized views
-- Purpose: On-demand refresh when needed (e.g., after bulk data updates, troubleshooting)
-- Usage: Execute this script when you need to force-refresh all MVs
-- Execution Time: ~10-20 seconds total (depends on data volume)
-- Created: 2025-10-28
-- Modified: 2025-10-28
-- =====================================================

\echo ''
\echo '========================================='
\echo 'MANUAL REFRESH: All Materialized Views'
\echo '========================================='
\echo ''

-- =====================================================
-- MV 1: Global Leaderboard
-- =====================================================

\echo '[1/4] Refreshing mv_global_leaderboard...'
\timing on
REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_global_leaderboard;
\timing off
\echo '  Status: OK'
\echo ''

-- =====================================================
-- MV 2: Classroom Leaderboard (CRITICAL)
-- =====================================================

\echo '[2/4] Refreshing mv_classroom_leaderboard...'
\timing on
REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_classroom_leaderboard;
\timing off
\echo '  Status: OK'
\echo ''

-- =====================================================
-- MV 3: Weekly Leaderboard
-- =====================================================

\echo '[3/4] Refreshing mv_weekly_leaderboard...'
\timing on
REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_weekly_leaderboard;
\timing off
\echo '  Status: OK'
\echo ''

-- =====================================================
-- MV 4: Mechanic Leaderboard
-- =====================================================

\echo '[4/4] Refreshing mv_mechanic_leaderboard...'
\timing on
REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_mechanic_leaderboard;
\timing off
\echo '  Status: OK'
\echo ''

-- =====================================================
-- Refresh Summary
-- =====================================================

\echo '========================================='
\echo 'REFRESH COMPLETE'
\echo '========================================='
\echo ''
\echo 'All 4 materialized views have been refreshed successfully:'
\echo '  - mv_global_leaderboard'
\echo '  - mv_classroom_leaderboard'
\echo '  - mv_weekly_leaderboard'
\echo '  - mv_mechanic_leaderboard'
\echo ''
\echo 'Data is now up-to-date with the current state of base tables.'
\echo ''

-- =====================================================
-- Verify Row Counts
-- =====================================================

\echo 'Row counts after refresh:'
\echo ''

SELECT 'mv_global_leaderboard' as materialized_view,
       COUNT(*) as row_count,
       MIN(rank) as min_rank,
       MAX(rank) as max_rank
FROM gamification_system.mv_global_leaderboard
UNION ALL
SELECT 'mv_classroom_leaderboard' as materialized_view,
       COUNT(*) as row_count,
       MIN(rank) as min_rank,
       MAX(rank) as max_rank
FROM gamification_system.mv_classroom_leaderboard
UNION ALL
SELECT 'mv_weekly_leaderboard' as materialized_view,
       COUNT(*) as row_count,
       MIN(rank) as min_rank,
       MAX(rank) as max_rank
FROM gamification_system.mv_weekly_leaderboard
UNION ALL
SELECT 'mv_mechanic_leaderboard' as materialized_view,
       COUNT(*) as row_count,
       MIN(rank) as min_rank,
       MAX(rank) as max_rank
FROM gamification_system.mv_mechanic_leaderboard
ORDER BY materialized_view;

\echo ''
\echo '========================================='

-- =====================================================
-- USAGE NOTES
-- =====================================================
-- Execute this script with:
--   psql -U your_user -d your_database -f refresh-all-mvs.sql
--
-- Or from psql prompt:
--   \i refresh-all-mvs.sql
--
-- CONCURRENT refresh allows:
--   - MVs remain readable during refresh
--   - No table locks
--   - Requires UNIQUE index on MV
--
-- When to use this script:
--   - After bulk data imports
--   - After significant data updates
--   - When testing MV performance
--   - When troubleshooting stale data issues
--   - Before critical demonstrations or events
-- =====================================================
