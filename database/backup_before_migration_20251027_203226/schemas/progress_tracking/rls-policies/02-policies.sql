-- =====================================================
-- RLS Policies for progress_tracking schema
-- Description: Políticas de seguridad para seguimiento de progreso
-- Created: 2025-10-27
-- =====================================================

-- =====================================================
-- TABLE: progress_tracking.exercise_attempts
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS exercise_attempts_insert_own ON progress_tracking.exercise_attempts;
DROP POLICY IF EXISTS exercise_attempts_select_admin ON progress_tracking.exercise_attempts;
DROP POLICY IF EXISTS exercise_attempts_select_own ON progress_tracking.exercise_attempts;
DROP POLICY IF EXISTS exercise_attempts_select_teacher ON progress_tracking.exercise_attempts;

-- Policy: exercise_attempts_insert_own
-- Description: Los usuarios pueden insertar sus propios intentos de ejercicio
CREATE POLICY exercise_attempts_insert_own
    ON progress_tracking.exercise_attempts
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (user_id = gamilit.get_current_user_id());

COMMENT ON POLICY exercise_attempts_insert_own ON progress_tracking.exercise_attempts IS
    'Permite a los usuarios registrar sus propios intentos de ejercicios';

-- Policy: exercise_attempts_select_admin
-- Description: Los administradores pueden ver todos los intentos
CREATE POLICY exercise_attempts_select_admin
    ON progress_tracking.exercise_attempts
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.is_admin());

COMMENT ON POLICY exercise_attempts_select_admin ON progress_tracking.exercise_attempts IS
    'Permite a los administradores ver todos los intentos de ejercicios';

-- Policy: exercise_attempts_select_own
-- Description: Los usuarios pueden ver sus propios intentos
CREATE POLICY exercise_attempts_select_own
    ON progress_tracking.exercise_attempts
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = gamilit.get_current_user_id());

COMMENT ON POLICY exercise_attempts_select_own ON progress_tracking.exercise_attempts IS
    'Permite a los usuarios ver únicamente sus propios intentos de ejercicios';

-- Policy: exercise_attempts_select_teacher
-- Description: Los profesores pueden ver intentos de sus estudiantes
CREATE POLICY exercise_attempts_select_teacher
    ON progress_tracking.exercise_attempts
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        (gamilit.get_current_user_role() = 'admin_teacher'::gamilit_role)
        AND (EXISTS (
            SELECT 1
            FROM social_features.classroom_members cm
            JOIN social_features.classrooms c ON c.id = cm.classroom_id
            WHERE c.teacher_id = gamilit.get_current_user_id()
            AND cm.student_id = exercise_attempts.user_id
        ))
    );

COMMENT ON POLICY exercise_attempts_select_teacher ON progress_tracking.exercise_attempts IS
    'Permite a los profesores ver los intentos de ejercicios de sus estudiantes';

-- =====================================================
-- TABLE: progress_tracking.module_progress
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS module_progress_insert_own ON progress_tracking.module_progress;
DROP POLICY IF EXISTS module_progress_select_admin ON progress_tracking.module_progress;
DROP POLICY IF EXISTS module_progress_select_own ON progress_tracking.module_progress;
DROP POLICY IF EXISTS module_progress_select_teacher ON progress_tracking.module_progress;
DROP POLICY IF EXISTS module_progress_update_own ON progress_tracking.module_progress;

-- Policy: module_progress_insert_own
-- Description: Los usuarios pueden insertar su propio progreso de módulos
CREATE POLICY module_progress_insert_own
    ON progress_tracking.module_progress
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (user_id = gamilit.get_current_user_id());

COMMENT ON POLICY module_progress_insert_own ON progress_tracking.module_progress IS
    'Permite a los usuarios registrar su propio progreso en módulos';

-- Policy: module_progress_select_admin
-- Description: Los administradores pueden ver todo el progreso de módulos
CREATE POLICY module_progress_select_admin
    ON progress_tracking.module_progress
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.is_admin());

COMMENT ON POLICY module_progress_select_admin ON progress_tracking.module_progress IS
    'Permite a los administradores ver el progreso de todos los usuarios en módulos';

-- Policy: module_progress_select_own
-- Description: Los usuarios pueden ver su propio progreso
CREATE POLICY module_progress_select_own
    ON progress_tracking.module_progress
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = gamilit.get_current_user_id());

COMMENT ON POLICY module_progress_select_own ON progress_tracking.module_progress IS
    'Permite a los usuarios ver únicamente su propio progreso en módulos';

-- Policy: module_progress_select_teacher
-- Description: Los profesores pueden ver el progreso de sus estudiantes activos
CREATE POLICY module_progress_select_teacher
    ON progress_tracking.module_progress
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        (gamilit.get_current_user_role() = 'admin_teacher'::gamilit_role)
        AND (EXISTS (
            SELECT 1
            FROM social_features.classroom_members cm
            JOIN social_features.classrooms c ON c.id = cm.classroom_id
            WHERE c.teacher_id = gamilit.get_current_user_id()
            AND cm.student_id = module_progress.user_id
            AND cm.status = 'active'::text
        ))
    );

COMMENT ON POLICY module_progress_select_teacher ON progress_tracking.module_progress IS
    'Permite a los profesores ver el progreso de sus estudiantes activos en módulos';

-- Policy: module_progress_update_own
-- Description: Los usuarios pueden actualizar su propio progreso
CREATE POLICY module_progress_update_own
    ON progress_tracking.module_progress
    AS PERMISSIVE
    FOR UPDATE
    TO public
    USING (user_id = gamilit.get_current_user_id());

COMMENT ON POLICY module_progress_update_own ON progress_tracking.module_progress IS
    'Permite a los usuarios actualizar su propio progreso en módulos';
