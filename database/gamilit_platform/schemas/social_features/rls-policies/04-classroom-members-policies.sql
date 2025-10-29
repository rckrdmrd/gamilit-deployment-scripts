-- =====================================================
-- RLS Policies for: social_features.classroom_members
-- Description: Classroom membership management
-- Created: 2025-10-28
-- Policies: 3 (SELECT: 2, ALL: 1)
-- =====================================================
--
-- Security Strategy:
-- - Students: Can see members of their own classrooms
-- - Teachers: Can fully manage members of their classrooms
-- - Privacy: Students only see classmates, not other classrooms
-- =====================================================

DROP POLICY IF EXISTS classroom_members_read_student ON social_features.classroom_members;
DROP POLICY IF EXISTS classroom_members_read_teacher ON social_features.classroom_members;
DROP POLICY IF EXISTS classroom_members_manage_teacher ON social_features.classroom_members;
DROP POLICY IF EXISTS classroom_members_select_admin ON social_features.classroom_members;
DROP POLICY IF EXISTS classroom_members_select_own ON social_features.classroom_members;
DROP POLICY IF EXISTS classroom_members_select_teacher ON social_features.classroom_members;

-- Policy: classroom_members_read_student
-- Purpose: Students can read members of classrooms they belong to
CREATE POLICY classroom_members_read_student
    ON social_features.classroom_members
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        classroom_id IN (
            SELECT classroom_id
            FROM social_features.classroom_members
            WHERE student_id = current_setting('app.current_user_id', true)::uuid
        )
    );

COMMENT ON POLICY classroom_members_read_student ON social_features.classroom_members IS
    'Students can see classmates in their own classrooms';

-- Policy: classroom_members_read_teacher
-- Purpose: Teachers can read members of their classrooms
CREATE POLICY classroom_members_read_teacher
    ON social_features.classroom_members
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        classroom_id IN (
            SELECT id
            FROM social_features.classrooms
            WHERE teacher_id = current_setting('app.current_user_id', true)::uuid
        )
    );

COMMENT ON POLICY classroom_members_read_teacher ON social_features.classroom_members IS
    'Teachers can see all members of their classrooms';

-- Policy: classroom_members_manage_teacher
-- Purpose: Teachers can fully manage (INSERT/UPDATE/DELETE) members of their classrooms
CREATE POLICY classroom_members_manage_teacher
    ON social_features.classroom_members
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (
        classroom_id IN (
            SELECT id
            FROM social_features.classrooms
            WHERE teacher_id = current_setting('app.current_user_id', true)::uuid
        )
    );

COMMENT ON POLICY classroom_members_manage_teacher ON social_features.classroom_members IS
    'Teachers can fully manage membership of their classrooms (add/remove students)';
