-- =====================================================
-- RLS Policies for system_configuration schema
-- Description: Políticas de seguridad para configuración del sistema
-- Created: 2025-10-28
-- =====================================================

-- =====================================================
-- TABLE: system_configuration.system_settings
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS system_settings_all_admin ON system_configuration.system_settings;
DROP POLICY IF EXISTS system_settings_select_all ON system_configuration.system_settings;

-- Policy: system_settings_all_admin
-- Description: Los administradores tienen acceso completo a la configuración del sistema
CREATE POLICY system_settings_all_admin
    ON system_configuration.system_settings
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (gamilit.is_admin() OR gamilit.is_super_admin());

COMMENT ON POLICY system_settings_all_admin ON system_configuration.system_settings IS
    'Permite a los administradores gestión completa de las configuraciones del sistema';

-- Policy: system_settings_select_all
-- Description: Todos los usuarios autenticados pueden leer configuraciones del sistema
CREATE POLICY system_settings_select_all
    ON system_configuration.system_settings
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.get_current_user_id() IS NOT NULL);

COMMENT ON POLICY system_settings_select_all ON system_configuration.system_settings IS
    'Permite a los usuarios autenticados leer las configuraciones del sistema';

-- =====================================================
-- TABLE: system_configuration.feature_flags
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS feature_flags_all_admin ON system_configuration.feature_flags;
DROP POLICY IF EXISTS feature_flags_select_all ON system_configuration.feature_flags;

-- Policy: feature_flags_all_admin
-- Description: Los administradores tienen acceso completo a las banderas de características
CREATE POLICY feature_flags_all_admin
    ON system_configuration.feature_flags
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (gamilit.is_admin() OR gamilit.is_super_admin());

COMMENT ON POLICY feature_flags_all_admin ON system_configuration.feature_flags IS
    'Permite a los administradores gestión completa de las banderas de características';

-- Policy: feature_flags_select_all
-- Description: Todos los usuarios autenticados pueden leer banderas de características
CREATE POLICY feature_flags_select_all
    ON system_configuration.feature_flags
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.get_current_user_id() IS NOT NULL);

COMMENT ON POLICY feature_flags_select_all ON system_configuration.feature_flags IS
    'Permite a los usuarios autenticados verificar el estado de las banderas de características';
