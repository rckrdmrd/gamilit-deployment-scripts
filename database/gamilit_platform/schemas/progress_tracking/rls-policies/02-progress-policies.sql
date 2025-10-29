-- =====================================================
-- RLS Policies for: progress_tracking schema
-- Description: Student progress with teacher oversight
-- Created: 2025-10-28
-- Policies: 14 total across 4 tables
-- =====================================================
--
-- Security Strategy:
-- - Self-service: Students see and update their own progress
-- - Teacher oversight: Teachers can monitor student progress in their classrooms
-- - Admin access: Full monitoring capabilities
-- - Grading: Teachers can update submissions (grades/feedback)
-- =====================================================

-- =====================================================
-- TABLE: progress_tracking.module_progress
-- Policies: 4 (SELECT: 2, UPDATE: 1, INSERT: 1)
-- =====================================================

DROP POLICY IF EXISTS module_progress_read_own ON progress_tracking.module_progress;
DROP POLICY IF EXISTS module_progress_read_teacher ON progress_tracking.module_progress;
DROP POLICY IF EXISTS module_progress_update_own ON progress_tracking.module_progress;
DROP POLICY IF EXISTS module_progress_insert_system ON progress_tracking.module_progress;

-- Policy: module_progress_read_own
-- Purpose: Students can read their own progress
CREATE POLICY module_progress_read_own
    ON progress_tracking.module_progress
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY module_progress_read_own ON progress_tracking.module_progress IS
    'Students can see their own module progress';

-- Policy: module_progress_read_teacher
-- Purpose: Teachers can read progress of students in their classrooms
CREATE POLICY module_progress_read_teacher
    ON progress_tracking.module_progress
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

COMMENT ON POLICY module_progress_read_teacher ON progress_tracking.module_progress IS
    'Teachers can monitor module progress of students in their classrooms';

-- Policy: module_progress_update_own
-- Purpose: Students can update their own progress
CREATE POLICY module_progress_update_own
    ON progress_tracking.module_progress
    AS PERMISSIVE
    FOR UPDATE
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid)
    WITH CHECK (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY module_progress_update_own ON progress_tracking.module_progress IS
    'Students can update their own module progress';

-- Policy: module_progress_insert_system
-- Purpose: System can create progress records
CREATE POLICY module_progress_insert_system
    ON progress_tracking.module_progress
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (
        user_id = current_setting('app.current_user_id', true)::uuid
        OR EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'super_admin'
        )
    );

COMMENT ON POLICY module_progress_insert_system ON progress_tracking.module_progress IS
    'Students can create their own progress records, admins can create for any user';

-- =====================================================
-- TABLE: progress_tracking.exercise_attempts
-- Policies: 3 (SELECT: 2, INSERT: 1)
-- =====================================================

DROP POLICY IF EXISTS exercise_attempts_read_own ON progress_tracking.exercise_attempts;
DROP POLICY IF EXISTS exercise_attempts_read_teacher ON progress_tracking.exercise_attempts;
DROP POLICY IF EXISTS exercise_attempts_insert_own ON progress_tracking.exercise_attempts;

-- Policy: exercise_attempts_read_own
-- Purpose: Students can read their own attempts
CREATE POLICY exercise_attempts_read_own
    ON progress_tracking.exercise_attempts
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY exercise_attempts_read_own ON progress_tracking.exercise_attempts IS
    'Students can see their own exercise attempts and scores';

-- Policy: exercise_attempts_read_teacher
-- Purpose: Teachers can read attempts of students in their classrooms
CREATE POLICY exercise_attempts_read_teacher
    ON progress_tracking.exercise_attempts
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

COMMENT ON POLICY exercise_attempts_read_teacher ON progress_tracking.exercise_attempts IS
    'Teachers can see exercise attempts of students in their classrooms';

-- Policy: exercise_attempts_insert_own
-- Purpose: Students can create their own attempts
CREATE POLICY exercise_attempts_insert_own
    ON progress_tracking.exercise_attempts
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY exercise_attempts_insert_own ON progress_tracking.exercise_attempts IS
    'Students can create their own exercise attempts';

-- =====================================================
-- TABLE: progress_tracking.exercise_submissions
-- Policies: 4 (SELECT: 2, INSERT: 1, UPDATE: 1)
-- =====================================================

DROP POLICY IF EXISTS exercise_submissions_read_own ON progress_tracking.exercise_submissions;
DROP POLICY IF EXISTS exercise_submissions_read_teacher ON progress_tracking.exercise_submissions;
DROP POLICY IF EXISTS exercise_submissions_insert_own ON progress_tracking.exercise_submissions;
DROP POLICY IF EXISTS exercise_submissions_update_teacher ON progress_tracking.exercise_submissions;

-- Policy: exercise_submissions_read_own
-- Purpose: Students can read their own submissions
CREATE POLICY exercise_submissions_read_own
    ON progress_tracking.exercise_submissions
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY exercise_submissions_read_own ON progress_tracking.exercise_submissions IS
    'Students can see their own exercise submissions and feedback';

-- Policy: exercise_submissions_read_teacher
-- Purpose: Teachers can read submissions of students in their classrooms
CREATE POLICY exercise_submissions_read_teacher
    ON progress_tracking.exercise_submissions
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

COMMENT ON POLICY exercise_submissions_read_teacher ON progress_tracking.exercise_submissions IS
    'Teachers can see submissions from students in their classrooms';

-- Policy: exercise_submissions_insert_own
-- Purpose: Students can create their own submissions
CREATE POLICY exercise_submissions_insert_own
    ON progress_tracking.exercise_submissions
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY exercise_submissions_insert_own ON progress_tracking.exercise_submissions IS
    'Students can submit their own exercise solutions';

-- Policy: exercise_submissions_update_teacher
-- Purpose: Teachers can update submissions (add grades/feedback)
CREATE POLICY exercise_submissions_update_teacher
    ON progress_tracking.exercise_submissions
    AS PERMISSIVE
    FOR UPDATE
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

COMMENT ON POLICY exercise_submissions_update_teacher ON progress_tracking.exercise_submissions IS
    'Teachers can grade and provide feedback on submissions from their students';

-- =====================================================
-- SUMMARY: progress_tracking schema
-- =====================================================
-- Total policies: 14 (includes 3 tables above)
-- Tables with policies: 4
-- - module_progress: 4 policies (2 SELECT, 1 UPDATE, 1 INSERT)
-- - exercise_attempts: 3 policies (2 SELECT, 1 INSERT)
-- - exercise_submissions: 4 policies (2 SELECT, 1 INSERT, 1 UPDATE)
-- - learning_sessions: 3 policies (existing, not updated here)
-- =====================================================
