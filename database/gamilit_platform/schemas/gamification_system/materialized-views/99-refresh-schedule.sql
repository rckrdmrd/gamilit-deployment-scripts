-- =====================================================
-- MATERIALIZED VIEWS REFRESH SCHEDULE
-- =====================================================
-- Description: Automatic refresh configuration for all materialized views using pg_cron
-- Purpose: Maintain data freshness in materialized views without manual intervention
-- Requirements: pg_cron extension must be installed
-- Installation: CREATE EXTENSION IF NOT EXISTS pg_cron;
-- System Requirements:
--   - PostgreSQL 12+
--   - pg_cron extension (apt: postgresql-<version>-cron)
--   - Superuser privileges to install extension
-- Created: 2025-10-28
-- Modified: 2025-10-28
-- =====================================================

-- =====================================================
-- STEP 1: Install pg_cron Extension
-- =====================================================
-- NOTE: This requires superuser privileges
-- If you don't have superuser access, ask your DBA to run this command

CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Verify installation
SELECT * FROM pg_available_extensions WHERE name = 'pg_cron';

-- =====================================================
-- STEP 2: Schedule Refresh Jobs
-- =====================================================

-- =====================================================
-- Job 1: Global Leaderboard
-- =====================================================
-- Refresh: Every hour at minute 0
-- Frequency: High (hourly) - global leaderboard is frequently accessed
-- Impact: ~2-5 seconds per refresh

SELECT cron.schedule(
    'refresh-global-leaderboard',
    '0 * * * *',
    $$REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_global_leaderboard$$
);

-- =====================================================
-- Job 2: Classroom Leaderboard (CRITICAL)
-- =====================================================
-- Refresh: Every 30 minutes
-- Frequency: Very High (30min) - MOST CRITICAL feature, highest traffic
-- Impact: ~3-7 seconds per refresh

SELECT cron.schedule(
    'refresh-classroom-leaderboard',
    '*/30 * * * *',
    $$REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_classroom_leaderboard$$
);

-- =====================================================
-- Job 3: Weekly Leaderboard - Regular Refresh
-- =====================================================
-- Refresh: Every hour at minute 0
-- Frequency: High (hourly) - weekly stats change frequently during active hours
-- Impact: ~1-3 seconds per refresh

SELECT cron.schedule(
    'refresh-weekly-leaderboard',
    '0 * * * *',
    $$REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_weekly_leaderboard$$
);

-- =====================================================
-- Job 4: Weekly Leaderboard - Monday Reset
-- =====================================================
-- Refresh: Every Monday at 00:00 (after weekly stats reset)
-- Purpose: Full refresh after weekly_xp reset in user_stats
-- NOTE: Ensure weekly stats are reset BEFORE this job runs

SELECT cron.schedule(
    'reset-weekly-leaderboard-monday',
    '0 0 * * 1',
    $$REFRESH MATERIALIZED VIEW gamification_system.mv_weekly_leaderboard$$
);

-- =====================================================
-- Job 5: Mechanic Leaderboard
-- =====================================================
-- Refresh: Every 2 hours at minute 0
-- Frequency: Medium (2 hours) - mechanic rankings change less frequently
-- Impact: ~4-8 seconds per refresh

SELECT cron.schedule(
    'refresh-mechanic-leaderboard',
    '0 */2 * * *',
    $$REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_mechanic_leaderboard$$
);

-- =====================================================
-- STEP 3: Verify Scheduled Jobs
-- =====================================================

-- View all scheduled leaderboard jobs
SELECT
    jobid,
    schedule,
    command,
    nodename,
    nodeport,
    database,
    username,
    active,
    jobname
FROM cron.job
WHERE jobname LIKE '%leaderboard%'
ORDER BY jobid;

-- =====================================================
-- STEP 4: Monitor Job Execution
-- =====================================================

-- View recent job runs and their status
SELECT
    jobid,
    runid,
    job_pid,
    database,
    username,
    command,
    status,
    return_message,
    start_time,
    end_time,
    (end_time - start_time) as duration
FROM cron.job_run_details
WHERE jobid IN (
    SELECT jobid
    FROM cron.job
    WHERE jobname LIKE '%leaderboard%'
)
ORDER BY start_time DESC
LIMIT 20;

-- =====================================================
-- MAINTENANCE COMMANDS
-- =====================================================

-- Unschedule a specific job (if needed)
-- SELECT cron.unschedule('refresh-global-leaderboard');

-- Unschedule all leaderboard jobs (if needed)
-- SELECT cron.unschedule(jobid)
-- FROM cron.job
-- WHERE jobname LIKE '%leaderboard%';

-- Update job schedule (example: change to every 15 minutes)
-- SELECT cron.schedule(
--     'refresh-classroom-leaderboard',
--     '*/15 * * * *',
--     $$REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_classroom_leaderboard$$
-- );

-- =====================================================
-- REFRESH SCHEDULE SUMMARY
-- =====================================================
--
-- Job Name                              | Schedule      | Frequency    | Cron Expression
-- --------------------------------------|---------------|--------------|----------------
-- refresh-global-leaderboard            | Hourly        | 60 min       | 0 * * * *
-- refresh-classroom-leaderboard         | Half-hourly   | 30 min       | */30 * * * *
-- refresh-weekly-leaderboard            | Hourly        | 60 min       | 0 * * * *
-- reset-weekly-leaderboard-monday       | Weekly        | 168 hours    | 0 0 * * 1
-- refresh-mechanic-leaderboard          | Every 2 hours | 120 min      | 0 */2 * * *
--
-- TOTAL REFRESHES PER DAY:
-- - Global: 24 refreshes/day
-- - Classroom: 48 refreshes/day (CRITICAL - highest frequency)
-- - Weekly: 24 refreshes/day + 1 full reset/week
-- - Mechanic: 12 refreshes/day
-- TOTAL: 108 refresh operations per day
-- =====================================================

-- =====================================================
-- ALTERNATIVE: Manual Refresh (if pg_cron not available)
-- =====================================================
-- If pg_cron cannot be installed, use these commands for manual refresh:
--
-- REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_global_leaderboard;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_classroom_leaderboard;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_weekly_leaderboard;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY gamification_system.mv_mechanic_leaderboard;
--
-- Or implement application-level cron jobs to run these commands periodically.
-- =====================================================
