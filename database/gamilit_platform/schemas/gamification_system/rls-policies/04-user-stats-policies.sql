-- =====================================================
-- RLS Policies for: gamification_system.user_stats & user_ranks
-- Description: User statistics and rankings with social visibility
-- Created: 2025-10-28
-- =====================================================
--
-- Security Strategy:
-- - Stats visibility: Own + friends + teachers
-- - Rankings public: Leaderboards visible to all
-- - System updates: Only admins can update stats (via SECURITY DEFINER)
-- =====================================================

-- =====================================================
-- TABLE: gamification_system.user_stats
-- Policies: 4 (SELECT: 3, UPDATE: 1)
-- =====================================================

DROP POLICY IF EXISTS user_stats_read_own ON gamification_system.user_stats;
DROP POLICY IF EXISTS user_stats_read_friends ON gamification_system.user_stats;
DROP POLICY IF EXISTS user_stats_read_teacher ON gamification_system.user_stats;
DROP POLICY IF EXISTS user_stats_update_system ON gamification_system.user_stats;

-- Policy: user_stats_read_own
-- Purpose: Users can read their own statistics
CREATE POLICY user_stats_read_own
    ON gamification_system.user_stats
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY user_stats_read_own ON gamification_system.user_stats IS
    'Users can see their own detailed statistics';

-- Policy: user_stats_read_friends
-- Purpose: Users can read statistics of their friends
CREATE POLICY user_stats_read_friends
    ON gamification_system.user_stats
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        user_id IN (
            SELECT friend_id
            FROM social_features.friendships
            WHERE user_id = current_setting('app.current_user_id', true)::uuid
                AND status = 'accepted'
            UNION
            SELECT user_id
            FROM social_features.friendships
            WHERE friend_id = current_setting('app.current_user_id', true)::uuid
                AND status = 'accepted'
        )
    );

COMMENT ON POLICY user_stats_read_friends ON gamification_system.user_stats IS
    'Social comparison: Users can see stats of accepted friends';

-- Policy: user_stats_read_teacher
-- Purpose: Teachers can read statistics of students in their classrooms
CREATE POLICY user_stats_read_teacher
    ON gamification_system.user_stats
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'admin_teacher'
        )
        AND user_id IN (
            SELECT cm.student_id
            FROM social_features.classroom_members cm
            JOIN social_features.classrooms c ON c.id = cm.classroom_id
            WHERE c.teacher_id = current_setting('app.current_user_id', true)::uuid
        )
    );

COMMENT ON POLICY user_stats_read_teacher ON gamification_system.user_stats IS
    'Teachers can monitor statistics of students in their classrooms';

-- Policy: user_stats_update_system
-- Purpose: Only system (admin) can update statistics
-- Note: This should be done via SECURITY DEFINER functions triggered by game events
CREATE POLICY user_stats_update_system
    ON gamification_system.user_stats
    AS PERMISSIVE
    FOR UPDATE
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'super_admin'
        )
    );

COMMENT ON POLICY user_stats_update_system ON gamification_system.user_stats IS
    'Only system (via SECURITY DEFINER functions) can update user statistics';

-- =====================================================
-- TABLE: gamification_system.user_ranks
-- Policies: 2 (SELECT: 1, UPDATE: 1)
-- =====================================================

DROP POLICY IF EXISTS user_ranks_read_all ON gamification_system.user_ranks;
DROP POLICY IF EXISTS user_ranks_update_system ON gamification_system.user_ranks;

-- Policy: user_ranks_read_all
-- Purpose: All users can read rankings (public leaderboards)
CREATE POLICY user_ranks_read_all
    ON gamification_system.user_ranks
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (true);

COMMENT ON POLICY user_ranks_read_all ON gamification_system.user_ranks IS
    'Public leaderboards: All users can see rankings';

-- Policy: user_ranks_update_system
-- Purpose: Only system can update ranks
CREATE POLICY user_ranks_update_system
    ON gamification_system.user_ranks
    AS PERMISSIVE
    FOR UPDATE
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'super_admin'
        )
    );

COMMENT ON POLICY user_ranks_update_system ON gamification_system.user_ranks IS
    'Only system can update ranking positions (automated process)';
