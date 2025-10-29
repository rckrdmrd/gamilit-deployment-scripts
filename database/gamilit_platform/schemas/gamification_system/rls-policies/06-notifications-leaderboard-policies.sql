-- =====================================================
-- RLS Policies for: gamification_system.notifications & leaderboard_metadata
-- Description: Notifications and leaderboard configuration
-- Created: 2025-10-28
-- =====================================================
--
-- Security Strategy:
-- - Notifications: Private, users manage their own
-- - Leaderboard metadata: Public configuration data
-- =====================================================

-- =====================================================
-- TABLE: gamification_system.notifications
-- Policies: 3 (SELECT: 1, UPDATE: 1, INSERT: 1)
-- =====================================================

DROP POLICY IF EXISTS notifications_read_own ON gamification_system.notifications;
DROP POLICY IF EXISTS notifications_update_own ON gamification_system.notifications;
DROP POLICY IF EXISTS notifications_insert_system ON gamification_system.notifications;

-- Policy: notifications_read_own
-- Purpose: Users can read their own notifications
CREATE POLICY notifications_read_own
    ON gamification_system.notifications
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY notifications_read_own ON gamification_system.notifications IS
    'Users can see only their own notifications';

-- Policy: notifications_update_own
-- Purpose: Users can update their notifications (mark as read)
CREATE POLICY notifications_update_own
    ON gamification_system.notifications
    AS PERMISSIVE
    FOR UPDATE
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid)
    WITH CHECK (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY notifications_update_own ON gamification_system.notifications IS
    'Users can mark their own notifications as read';

-- Policy: notifications_insert_system
-- Purpose: System creates notifications
CREATE POLICY notifications_insert_system
    ON gamification_system.notifications
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'super_admin'
        )
    );

COMMENT ON POLICY notifications_insert_system ON gamification_system.notifications IS
    'Only system can create notifications (via SECURITY DEFINER functions)';

-- =====================================================
-- TABLE: gamification_system.leaderboard_metadata
-- Policies: 2 (SELECT: 1, ALL: 1)
-- =====================================================

DROP POLICY IF EXISTS leaderboard_metadata_read_all ON gamification_system.leaderboard_metadata;
DROP POLICY IF EXISTS leaderboard_metadata_manage_admin ON gamification_system.leaderboard_metadata;

-- Policy: leaderboard_metadata_read_all
-- Purpose: All users can read leaderboard metadata (public configuration)
CREATE POLICY leaderboard_metadata_read_all
    ON gamification_system.leaderboard_metadata
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (true);

COMMENT ON POLICY leaderboard_metadata_read_all ON gamification_system.leaderboard_metadata IS
    'Public metadata: All users can see leaderboard configuration';

-- Policy: leaderboard_metadata_manage_admin
-- Purpose: Admins can manage leaderboard metadata
CREATE POLICY leaderboard_metadata_manage_admin
    ON gamification_system.leaderboard_metadata
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'super_admin'
        )
    );

COMMENT ON POLICY leaderboard_metadata_manage_admin ON gamification_system.leaderboard_metadata IS
    'Admins can configure leaderboard settings and metadata';

-- =====================================================
-- SUMMARY: gamification_system schema
-- =====================================================
-- Total policies: 26
-- Tables with policies: 9
-- - ml_coins_transactions: 4 policies (3 SELECT, 1 INSERT)
-- - achievements: 2 policies (1 SELECT, 1 ALL)
-- - user_achievements: 3 policies (3 SELECT)
-- - comodines_inventory: 3 policies (1 SELECT, 1 UPDATE, 1 INSERT)
-- - user_stats: 4 policies (3 SELECT, 1 UPDATE)
-- - user_ranks: 2 policies (1 SELECT, 1 UPDATE)
-- - missions: 2 policies (1 SELECT, 1 ALL)
-- - notifications: 3 policies (1 SELECT, 1 UPDATE, 1 INSERT)
-- - leaderboard_metadata: 2 policies (1 SELECT, 1 ALL)
-- =====================================================
