-- =====================================================
-- RLS Policies for educational_content schema
-- Description: Políticas de seguridad para contenido educativo
-- Created: 2025-10-27
-- =====================================================

-- =====================================================
-- TABLE: educational_content.exercises
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS exercises_all_admin ON educational_content.exercises;
DROP POLICY IF EXISTS exercises_select_active ON educational_content.exercises;
DROP POLICY IF EXISTS exercises_select_admin ON educational_content.exercises;

-- Policy: exercises_all_admin
-- Description: Los administradores tienen acceso completo a ejercicios
CREATE POLICY exercises_all_admin
    ON educational_content.exercises
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (gamilit.is_admin());

COMMENT ON POLICY exercises_all_admin ON educational_content.exercises IS
    'Permite a los administradores gestión completa de ejercicios';

-- Policy: exercises_select_active
-- Description: Los usuarios pueden ver ejercicios activos
CREATE POLICY exercises_select_active
    ON educational_content.exercises
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (is_active = true);

COMMENT ON POLICY exercises_select_active ON educational_content.exercises IS
    'Permite a todos los usuarios ver ejercicios activos';

-- Policy: exercises_select_admin
-- Description: Los administradores pueden ver todos los ejercicios
CREATE POLICY exercises_select_admin
    ON educational_content.exercises
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.is_admin());

COMMENT ON POLICY exercises_select_admin ON educational_content.exercises IS
    'Permite a los administradores ver todos los ejercicios, activos o inactivos';

-- =====================================================
-- TABLE: educational_content.modules
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS modules_all_admin ON educational_content.modules;
DROP POLICY IF EXISTS modules_select_admin ON educational_content.modules;
DROP POLICY IF EXISTS modules_select_published ON educational_content.modules;

-- Policy: modules_all_admin
-- Description: Los administradores tienen acceso completo a módulos
CREATE POLICY modules_all_admin
    ON educational_content.modules
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (gamilit.is_admin());

COMMENT ON POLICY modules_all_admin ON educational_content.modules IS
    'Permite a los administradores gestión completa de módulos educativos';

-- Policy: modules_select_admin
-- Description: Los administradores pueden ver todos los módulos
CREATE POLICY modules_select_admin
    ON educational_content.modules
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.is_admin());

COMMENT ON POLICY modules_select_admin ON educational_content.modules IS
    'Permite a los administradores ver todos los módulos educativos';

-- Policy: modules_select_published
-- Description: Los usuarios pueden ver módulos publicados y activos
CREATE POLICY modules_select_published
    ON educational_content.modules
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING ((is_published = true) AND (status = 'published'::content_status));

COMMENT ON POLICY modules_select_published ON educational_content.modules IS
    'Permite a todos los usuarios ver módulos publicados y activos';

-- =====================================================
-- TABLE: educational_content.assessment_rubrics
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS assessment_rubrics_all_admin ON educational_content.assessment_rubrics;
DROP POLICY IF EXISTS assessment_rubrics_select_all ON educational_content.assessment_rubrics;

-- Policy: assessment_rubrics_all_admin
-- Description: Los administradores tienen acceso completo a las rúbricas de evaluación
CREATE POLICY assessment_rubrics_all_admin
    ON educational_content.assessment_rubrics
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (gamilit.is_admin() OR gamilit.is_super_admin());

COMMENT ON POLICY assessment_rubrics_all_admin ON educational_content.assessment_rubrics IS
    'Permite a los administradores gestión completa de las rúbricas de evaluación';

-- Policy: assessment_rubrics_select_all
-- Description: Todos los usuarios autenticados pueden ver las rúbricas de evaluación
CREATE POLICY assessment_rubrics_select_all
    ON educational_content.assessment_rubrics
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.get_current_user_id() IS NOT NULL);

COMMENT ON POLICY assessment_rubrics_select_all ON educational_content.assessment_rubrics IS
    'Permite a los usuarios autenticados ver las rúbricas de evaluación';

-- =====================================================
-- TABLE: educational_content.media_resources
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS media_resources_all_admin ON educational_content.media_resources;
DROP POLICY IF EXISTS media_resources_select_all ON educational_content.media_resources;

-- Policy: media_resources_all_admin
-- Description: Los administradores tienen acceso completo a los recursos multimedia
CREATE POLICY media_resources_all_admin
    ON educational_content.media_resources
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (gamilit.is_admin() OR gamilit.is_super_admin());

COMMENT ON POLICY media_resources_all_admin ON educational_content.media_resources IS
    'Permite a los administradores gestión completa de los recursos multimedia';

-- Policy: media_resources_select_all
-- Description: Todos los usuarios autenticados pueden ver los recursos multimedia
CREATE POLICY media_resources_select_all
    ON educational_content.media_resources
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.get_current_user_id() IS NOT NULL);

COMMENT ON POLICY media_resources_select_all ON educational_content.media_resources IS
    'Permite a los usuarios autenticados acceder a los recursos multimedia educativos';
