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
