-- =====================================================
-- RLS Policies for social_features schema
-- Description: Políticas de seguridad para características sociales
-- Created: 2025-10-27
-- =====================================================

-- =====================================================
-- TABLE: social_features.classroom_members
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS classroom_members_manage_teacher ON social_features.classroom_members;
DROP POLICY IF EXISTS classroom_members_select_admin ON social_features.classroom_members;
DROP POLICY IF EXISTS classroom_members_select_own ON social_features.classroom_members;
DROP POLICY IF EXISTS classroom_members_select_teacher ON social_features.classroom_members;

-- Policy: classroom_members_manage_teacher
-- Description: Los profesores pueden gestionar miembros de sus aulas
CREATE POLICY classroom_members_manage_teacher
    ON social_features.classroom_members
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (
        EXISTS (
            SELECT 1
            FROM social_features.classrooms c
            WHERE c.id = classroom_members.classroom_id
            AND c.teacher_id = gamilit.get_current_user_id()
        )
    );

COMMENT ON POLICY classroom_members_manage_teacher ON social_features.classroom_members IS
    'Permite a los profesores gestionar completamente los miembros de sus propias aulas';

-- Policy: classroom_members_select_admin
-- Description: Los administradores pueden ver todos los miembros de aulas
CREATE POLICY classroom_members_select_admin
    ON social_features.classroom_members
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.is_admin());

COMMENT ON POLICY classroom_members_select_admin ON social_features.classroom_members IS
    'Permite a los administradores ver todos los miembros de todas las aulas';

-- Policy: classroom_members_select_own
-- Description: Los estudiantes pueden ver información de sus propias membresías
CREATE POLICY classroom_members_select_own
    ON social_features.classroom_members
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (student_id = gamilit.get_current_user_id());

COMMENT ON POLICY classroom_members_select_own ON social_features.classroom_members IS
    'Permite a los estudiantes ver sus propias membresías en aulas';

-- Policy: classroom_members_select_teacher
-- Description: Los profesores pueden ver miembros de sus aulas
CREATE POLICY classroom_members_select_teacher
    ON social_features.classroom_members
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        EXISTS (
            SELECT 1
            FROM social_features.classrooms c
            WHERE c.id = classroom_members.classroom_id
            AND c.teacher_id = gamilit.get_current_user_id()
        )
    );

COMMENT ON POLICY classroom_members_select_teacher ON social_features.classroom_members IS
    'Permite a los profesores ver los miembros de sus propias aulas';

-- =====================================================
-- TABLE: social_features.classrooms
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS classrooms_manage_teacher ON social_features.classrooms;
DROP POLICY IF EXISTS classrooms_select_admin ON social_features.classrooms;
DROP POLICY IF EXISTS classrooms_select_student ON social_features.classrooms;
DROP POLICY IF EXISTS classrooms_select_teacher ON social_features.classrooms;

-- Policy: classrooms_manage_teacher
-- Description: Los profesores pueden gestionar sus propias aulas
CREATE POLICY classrooms_manage_teacher
    ON social_features.classrooms
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (teacher_id = gamilit.get_current_user_id());

COMMENT ON POLICY classrooms_manage_teacher ON social_features.classrooms IS
    'Permite a los profesores gestionar completamente sus propias aulas';

-- Policy: classrooms_select_admin
-- Description: Los administradores pueden ver todas las aulas
CREATE POLICY classrooms_select_admin
    ON social_features.classrooms
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.is_admin());

COMMENT ON POLICY classrooms_select_admin ON social_features.classrooms IS
    'Permite a los administradores ver todas las aulas del sistema';

-- Policy: classrooms_select_student
-- Description: Los estudiantes pueden ver aulas en las que están inscritos activamente
CREATE POLICY classrooms_select_student
    ON social_features.classrooms
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        EXISTS (
            SELECT 1
            FROM social_features.classroom_members cm
            WHERE cm.classroom_id = classrooms.id
            AND cm.student_id = gamilit.get_current_user_id()
            AND cm.status = 'active'::text
        )
    );

COMMENT ON POLICY classrooms_select_student ON social_features.classrooms IS
    'Permite a los estudiantes ver las aulas en las que están activamente inscritos';

-- Policy: classrooms_select_teacher
-- Description: Los profesores pueden ver sus propias aulas
CREATE POLICY classrooms_select_teacher
    ON social_features.classrooms
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (teacher_id = gamilit.get_current_user_id());

COMMENT ON POLICY classrooms_select_teacher ON social_features.classrooms IS
    'Permite a los profesores ver sus propias aulas';

-- =====================================================
-- TABLE: social_features.teams
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS teams_manage_admin ON social_features.teams;
DROP POLICY IF EXISTS teams_select_admin ON social_features.teams;
DROP POLICY IF EXISTS teams_select_member ON social_features.teams;
DROP POLICY IF EXISTS teams_update_member ON social_features.teams;

-- Policy: teams_manage_admin
-- Description: Los administradores pueden gestionar todos los equipos
CREATE POLICY teams_manage_admin
    ON social_features.teams
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (gamilit.is_admin() OR gamilit.is_super_admin());

COMMENT ON POLICY teams_manage_admin ON social_features.teams IS
    'Permite a los administradores gestión completa de todos los equipos';

-- Policy: teams_select_admin
-- Description: Los administradores pueden ver todos los equipos
CREATE POLICY teams_select_admin
    ON social_features.teams
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.is_admin() OR gamilit.is_super_admin());

COMMENT ON POLICY teams_select_admin ON social_features.teams IS
    'Permite a los administradores ver todos los equipos del sistema';

-- Policy: teams_select_member
-- Description: Los miembros pueden ver información de sus propios equipos
CREATE POLICY teams_select_member
    ON social_features.teams
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        EXISTS (
            SELECT 1
            FROM social_features.team_members tm
            WHERE tm.team_id = teams.id
            AND tm.user_id = gamilit.get_current_user_id()
            AND tm.status = 'active'::text
        )
    );

COMMENT ON POLICY teams_select_member ON social_features.teams IS
    'Permite a los miembros activos ver información de sus equipos';

-- Policy: teams_update_member
-- Description: Los líderes de equipo pueden actualizar información del equipo
CREATE POLICY teams_update_member
    ON social_features.teams
    AS PERMISSIVE
    FOR UPDATE
    TO public
    USING (
        EXISTS (
            SELECT 1
            FROM social_features.team_members tm
            WHERE tm.team_id = teams.id
            AND tm.user_id = gamilit.get_current_user_id()
            AND tm.role = 'leader'::text
            AND tm.status = 'active'::text
        )
    );

COMMENT ON POLICY teams_update_member ON social_features.teams IS
    'Permite a los líderes activos actualizar información de sus equipos';
