-- =====================================================
-- CHECK MATERIALIZED VIEWS FRESHNESS
-- =====================================================
-- Description: Verify when materialized views were last refreshed and their current status
-- Purpose: Monitor data staleness and ensure refresh jobs are running properly
-- Usage: Execute this script to check MV freshness and health
-- Created: 2025-10-28
-- Modified: 2025-10-28
-- =====================================================

\echo ''
\echo '========================================='
\echo 'MATERIALIZED VIEWS FRESHNESS CHECK'
\echo '========================================='
\echo ''

-- =====================================================
-- PART 1: Basic MV Statistics
-- =====================================================

\echo 'Part 1: Basic Statistics'
\echo '------------------------'
\echo ''

SELECT
    schemaname,
    matviewname as mv_name,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||matviewname)) as total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||matviewname)) as data_size,
    pg_size_pretty(pg_indexes_size(schemaname||'.'||matviewname)) as indexes_size,
    ispopulated as is_populated,
    CASE
        WHEN ispopulated THEN 'Ready'
        ELSE 'Not Populated'
    END as status
FROM pg_matviews
WHERE schemaname = 'gamification_system'
  AND matviewname LIKE 'mv_%leaderboard'
ORDER BY matviewname;

\echo ''

-- =====================================================
-- PART 2: Row Counts and Data Distribution
-- =====================================================

\echo 'Part 2: Row Counts'
\echo '------------------'
\echo ''

-- Global Leaderboard
SELECT
    'mv_global_leaderboard' as mv_name,
    COUNT(*) as total_rows,
    MIN(total_xp) as min_xp,
    MAX(total_xp) as max_xp,
    AVG(total_xp)::numeric(10,2) as avg_xp,
    COUNT(DISTINCT user_id) as unique_users
FROM gamification_system.mv_global_leaderboard

UNION ALL

-- Classroom Leaderboard
SELECT
    'mv_classroom_leaderboard' as mv_name,
    COUNT(*) as total_rows,
    MIN(total_xp) as min_xp,
    MAX(total_xp) as max_xp,
    AVG(total_xp)::numeric(10,2) as avg_xp,
    COUNT(DISTINCT user_id) as unique_users
FROM gamification_system.mv_classroom_leaderboard

UNION ALL

-- Weekly Leaderboard
SELECT
    'mv_weekly_leaderboard' as mv_name,
    COUNT(*) as total_rows,
    MIN(weekly_xp) as min_xp,
    MAX(weekly_xp) as max_xp,
    AVG(weekly_xp)::numeric(10,2) as avg_xp,
    COUNT(DISTINCT user_id) as unique_users
FROM gamification_system.mv_weekly_leaderboard

UNION ALL

-- Mechanic Leaderboard
SELECT
    'mv_mechanic_leaderboard' as mv_name,
    COUNT(*) as total_rows,
    MIN(user_xp) as min_xp,
    MAX(user_xp) as max_xp,
    AVG(user_xp)::numeric(10,2) as avg_xp,
    COUNT(DISTINCT user_id) as unique_users
FROM gamification_system.mv_mechanic_leaderboard

ORDER BY mv_name;

\echo ''

-- =====================================================
-- PART 3: Classroom Distribution (for mv_classroom_leaderboard)
-- =====================================================

\echo 'Part 3: Classroom Distribution'
\echo '-------------------------------'
\echo ''

SELECT
    classroom_id,
    COUNT(*) as students_in_classroom,
    MIN(total_xp) as min_xp,
    MAX(total_xp) as max_xp,
    AVG(total_xp)::numeric(10,2) as avg_xp
FROM gamification_system.mv_classroom_leaderboard
GROUP BY classroom_id
ORDER BY students_in_classroom DESC
LIMIT 10;

\echo ''
\echo '(Showing top 10 classrooms by student count)'
\echo ''

-- =====================================================
-- PART 4: Mechanic Distribution (for mv_mechanic_leaderboard)
-- =====================================================

\echo 'Part 4: Mechanic Distribution'
\echo '-----------------------------'
\echo ''

SELECT
    mechanic_id,
    mechanic_name,
    COUNT(*) as students_in_mechanic,
    MIN(user_xp) as min_xp,
    MAX(user_xp) as max_xp,
    AVG(user_xp)::numeric(10,2) as avg_xp
FROM gamification_system.mv_mechanic_leaderboard
GROUP BY mechanic_id, mechanic_name
ORDER BY students_in_mechanic DESC;

\echo ''

-- =====================================================
-- PART 5: Index Health
-- =====================================================

\echo 'Part 5: Index Health'
\echo '--------------------'
\echo ''

SELECT
    schemaname,
    tablename as mv_name,
    indexname,
    pg_size_pretty(pg_relation_size(schemaname||'.'||indexname)) as index_size,
    idx_scan as times_used,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
WHERE schemaname = 'gamification_system'
  AND tablename LIKE 'mv_%leaderboard'
ORDER BY tablename, indexname;

\echo ''

-- =====================================================
-- PART 6: pg_cron Job Status (if available)
-- =====================================================

\echo 'Part 6: Scheduled Jobs Status'
\echo '------------------------------'
\echo ''

DO $$
BEGIN
    -- Check if pg_cron is installed
    IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'pg_cron' AND installed_version IS NOT NULL) THEN
        -- Show scheduled jobs
        RAISE NOTICE 'pg_cron is installed - showing scheduled jobs:';
        PERFORM 1; -- Placeholder, actual query below
    ELSE
        RAISE NOTICE 'pg_cron is NOT installed - automated refresh not configured';
        RAISE NOTICE 'MVs must be refreshed manually or via application-level cron';
    END IF;
END $$;

-- Show scheduled jobs (only if pg_cron exists)
SELECT
    jobid,
    jobname,
    schedule,
    active,
    database,
    username
FROM cron.job
WHERE jobname LIKE '%leaderboard%'
ORDER BY jobid;

\echo ''

-- =====================================================
-- PART 7: Recent Job Runs (if pg_cron available)
-- =====================================================

\echo 'Part 7: Recent Refresh History'
\echo '-------------------------------'
\echo ''

-- Show last 5 runs per job
SELECT
    j.jobname,
    jr.status,
    jr.start_time,
    jr.end_time,
    (jr.end_time - jr.start_time) as duration,
    jr.return_message
FROM cron.job_run_details jr
JOIN cron.job j ON jr.jobid = j.jobid
WHERE j.jobname LIKE '%leaderboard%'
ORDER BY jr.start_time DESC
LIMIT 20;

\echo ''

-- =====================================================
-- PART 8: Freshness Recommendations
-- =====================================================

\echo '========================================='
\echo 'FRESHNESS RECOMMENDATIONS'
\echo '========================================='
\echo ''
\echo 'Expected Refresh Frequencies:'
\echo '  - mv_global_leaderboard:    Every 60 minutes'
\echo '  - mv_classroom_leaderboard: Every 30 minutes (CRITICAL)'
\echo '  - mv_weekly_leaderboard:    Every 60 minutes'
\echo '  - mv_mechanic_leaderboard:  Every 120 minutes'
\echo ''
\echo 'Action Items:'
\echo '  1. Verify all MVs show is_populated = true'
\echo '  2. Check that row counts match expected data volume'
\echo '  3. Ensure pg_cron jobs are active (if using pg_cron)'
\echo '  4. Monitor that recent refreshes completed successfully'
\echo '  5. If any MV is stale, run: refresh-all-mvs.sql'
\echo ''
\echo 'For manual refresh:'
\echo '  psql -f refresh-all-mvs.sql'
\echo ''
\echo '========================================='
\echo ''

-- =====================================================
-- USAGE NOTES
-- =====================================================
-- Execute this script with:
--   psql -U your_user -d your_database -f check-mv-freshness.sql
--
-- Or from psql prompt:
--   \i check-mv-freshness.sql
--
-- This script provides:
--   - MV size and population status
--   - Row counts and data distribution
--   - Index usage statistics
--   - pg_cron job status (if installed)
--   - Recent refresh history (if pg_cron installed)
--   - Recommendations for data freshness
--
-- Run this script regularly to:
--   - Monitor MV health
--   - Detect stale data
--   - Verify refresh jobs are working
--   - Troubleshoot performance issues
-- =====================================================
