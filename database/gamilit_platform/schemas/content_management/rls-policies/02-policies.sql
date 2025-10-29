-- =====================================================
-- RLS Policies for content_management schema
-- Description: Políticas de seguridad para contenido Marie Curie
-- Created: 2025-10-27
-- =====================================================

-- =====================================================
-- TABLE: content_management.marie_curie_content
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS marie_content_all_admin ON content_management.marie_curie_content;
DROP POLICY IF EXISTS marie_content_select_all ON content_management.marie_curie_content;

-- Policy: marie_content_all_admin
-- Description: Los administradores tienen acceso completo al contenido Marie Curie
CREATE POLICY marie_content_all_admin
    ON content_management.marie_curie_content
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (gamilit.is_admin());

COMMENT ON POLICY marie_content_all_admin ON content_management.marie_curie_content IS
    'Permite a los administradores gestión completa del contenido Marie Curie';

-- Policy: marie_content_select_all
-- Description: Todos los usuarios pueden ver contenido publicado
CREATE POLICY marie_content_select_all
    ON content_management.marie_curie_content
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (status = 'published'::content_status);

COMMENT ON POLICY marie_content_select_all ON content_management.marie_curie_content IS
    'Permite a todos los usuarios ver el contenido Marie Curie publicado';

-- =====================================================
-- TABLE: content_management.content_templates
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS content_templates_all_admin ON content_management.content_templates;
DROP POLICY IF EXISTS content_templates_select_all ON content_management.content_templates;

-- Policy: content_templates_all_admin
-- Description: Los administradores tienen acceso completo a las plantillas de contenido
CREATE POLICY content_templates_all_admin
    ON content_management.content_templates
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (gamilit.is_admin() OR gamilit.is_super_admin());

COMMENT ON POLICY content_templates_all_admin ON content_management.content_templates IS
    'Permite a los administradores gestión completa de las plantillas de contenido';

-- Policy: content_templates_select_all
-- Description: Todos los usuarios autenticados pueden ver plantillas activas
CREATE POLICY content_templates_select_all
    ON content_management.content_templates
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.get_current_user_id() IS NOT NULL);

COMMENT ON POLICY content_templates_select_all ON content_management.content_templates IS
    'Permite a los usuarios autenticados ver las plantillas de contenido disponibles';

-- =====================================================
-- TABLE: content_management.media_files
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS media_files_all_admin ON content_management.media_files;
DROP POLICY IF EXISTS media_files_select_all ON content_management.media_files;
DROP POLICY IF EXISTS media_files_insert_teacher ON content_management.media_files;

-- Policy: media_files_all_admin
-- Description: Los administradores tienen acceso completo a los archivos multimedia
CREATE POLICY media_files_all_admin
    ON content_management.media_files
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (gamilit.is_admin() OR gamilit.is_super_admin());

COMMENT ON POLICY media_files_all_admin ON content_management.media_files IS
    'Permite a los administradores gestión completa de los archivos multimedia';

-- Policy: media_files_select_all
-- Description: Todos los usuarios autenticados pueden ver archivos multimedia
CREATE POLICY media_files_select_all
    ON content_management.media_files
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.get_current_user_id() IS NOT NULL);

COMMENT ON POLICY media_files_select_all ON content_management.media_files IS
    'Permite a los usuarios autenticados acceder a los archivos multimedia';

-- Policy: media_files_insert_teacher
-- Description: Los profesores pueden subir archivos multimedia
CREATE POLICY media_files_insert_teacher
    ON content_management.media_files
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (
        gamilit.get_current_user_role() = 'admin_teacher'::gamilit_role
        OR gamilit.is_admin()
        OR gamilit.is_super_admin()
    );

COMMENT ON POLICY media_files_insert_teacher ON content_management.media_files IS
    'Permite a los profesores y administradores subir archivos multimedia';
