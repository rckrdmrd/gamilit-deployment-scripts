-- =====================================================
-- RLS Policies for: social_features.classrooms
-- Description: Classrooms with role-based access (student/teacher/admin)
-- Created: 2025-10-28
-- Policies: 5 (SELECT: 3, INSERT: 1, UPDATE: 1)
-- =====================================================
--
-- Security Strategy:
-- - Students: Can only see classrooms they are members of
-- - Teachers: Can see and manage their own classrooms
-- - Admins: Can see all classrooms in the tenant
-- =====================================================

DROP POLICY IF EXISTS classrooms_read_student ON social_features.classrooms;
DROP POLICY IF EXISTS classrooms_read_teacher ON social_features.classrooms;
DROP POLICY IF EXISTS classrooms_read_admin ON social_features.classrooms;
DROP POLICY IF EXISTS classrooms_insert_teacher ON social_features.classrooms;
DROP POLICY IF EXISTS classrooms_update_teacher ON social_features.classrooms;
DROP POLICY IF EXISTS classrooms_manage_teacher ON social_features.classrooms;
DROP POLICY IF EXISTS classrooms_select_admin ON social_features.classrooms;
DROP POLICY IF EXISTS classrooms_select_student ON social_features.classrooms;
DROP POLICY IF EXISTS classrooms_select_teacher ON social_features.classrooms;

-- Policy: classrooms_read_student
-- Purpose: Students can read classrooms they are members of
CREATE POLICY classrooms_read_student
    ON social_features.classrooms
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        id IN (
            SELECT classroom_id
            FROM social_features.classroom_members
            WHERE student_id = current_setting('app.current_user_id', true)::uuid
        )
    );

COMMENT ON POLICY classrooms_read_student ON social_features.classrooms IS
    'Students can only see classrooms they are enrolled in';

-- Policy: classrooms_read_teacher
-- Purpose: Teachers can read their own classrooms
CREATE POLICY classrooms_read_teacher
    ON social_features.classrooms
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (teacher_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY classrooms_read_teacher ON social_features.classrooms IS
    'Teachers can see their own classrooms';

-- Policy: classrooms_read_admin
-- Purpose: Admins can read all classrooms in the tenant
CREATE POLICY classrooms_read_admin
    ON social_features.classrooms
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'super_admin'
        )
    );

COMMENT ON POLICY classrooms_read_admin ON social_features.classrooms IS
    'Admins can see all classrooms in the system';

-- Policy: classrooms_insert_teacher
-- Purpose: Teachers can create their own classrooms
CREATE POLICY classrooms_insert_teacher
    ON social_features.classrooms
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (
        teacher_id = current_setting('app.current_user_id', true)::uuid
        AND EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'admin_teacher'
        )
    );

COMMENT ON POLICY classrooms_insert_teacher ON social_features.classrooms IS
    'Teachers can create classrooms assigned to themselves';

-- Policy: classrooms_update_teacher
-- Purpose: Teachers can update their own classrooms
CREATE POLICY classrooms_update_teacher
    ON social_features.classrooms
    AS PERMISSIVE
    FOR UPDATE
    TO public
    USING (teacher_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY classrooms_update_teacher ON social_features.classrooms IS
    'Teachers can update their own classrooms';
