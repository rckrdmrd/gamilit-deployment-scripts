-- =====================================================
-- RLS Policies for: gamification_system.achievements & user_achievements
-- Description: Achievement system with public catalog and social sharing
-- Created: 2025-10-28
-- =====================================================
--
-- Security Strategy:
-- - Public catalog: Active achievements are visible to all
-- - Secret achievements: Hidden until unlocked
-- - Social sharing: Users can see friends' achievements
-- - Teacher oversight: Teachers can see student achievements
-- =====================================================

-- =====================================================
-- TABLE: gamification_system.achievements
-- Policies: 2 (SELECT: 1, ALL: 1)
-- =====================================================

DROP POLICY IF EXISTS achievements_read_public ON gamification_system.achievements;
DROP POLICY IF EXISTS achievements_manage_admin ON gamification_system.achievements;

-- Policy: achievements_read_public
-- Purpose: All users can read active, non-secret achievements
CREATE POLICY achievements_read_public
    ON gamification_system.achievements
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (is_active = true AND is_secret = false);

COMMENT ON POLICY achievements_read_public ON gamification_system.achievements IS
    'Public catalog: All users can see active, non-secret achievements';

-- Policy: achievements_manage_admin
-- Purpose: Admins can fully manage all achievements
CREATE POLICY achievements_manage_admin
    ON gamification_system.achievements
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

COMMENT ON POLICY achievements_manage_admin ON gamification_system.achievements IS
    'Admins can create, update, and delete all achievements';

-- =====================================================
-- TABLE: gamification_system.user_achievements
-- Policies: 3 (SELECT: 3)
-- =====================================================

DROP POLICY IF EXISTS user_achievements_read_own ON gamification_system.user_achievements;
DROP POLICY IF EXISTS user_achievements_read_friends ON gamification_system.user_achievements;
DROP POLICY IF EXISTS user_achievements_read_teacher ON gamification_system.user_achievements;

-- Policy: user_achievements_read_own
-- Purpose: Users can read their own achievements
CREATE POLICY user_achievements_read_own
    ON gamification_system.user_achievements
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY user_achievements_read_own ON gamification_system.user_achievements IS
    'Users can see all their unlocked achievements';

-- Policy: user_achievements_read_friends
-- Purpose: Users can read achievements of their friends
CREATE POLICY user_achievements_read_friends
    ON gamification_system.user_achievements
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

COMMENT ON POLICY user_achievements_read_friends ON gamification_system.user_achievements IS
    'Social sharing: Users can see achievements of accepted friends';

-- Policy: user_achievements_read_teacher
-- Purpose: Teachers can read achievements of students in their classrooms
CREATE POLICY user_achievements_read_teacher
    ON gamification_system.user_achievements
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

COMMENT ON POLICY user_achievements_read_teacher ON gamification_system.user_achievements IS
    'Teachers can monitor achievements of students in their classrooms';
