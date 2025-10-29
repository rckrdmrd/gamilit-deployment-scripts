-- =====================================================
-- RLS Policies for auth_management schema
-- Description: Políticas de seguridad para perfiles de usuario
-- Created: 2025-10-27
-- =====================================================

-- =====================================================
-- TABLE: auth_management.profiles
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS profiles_select_admin ON auth_management.profiles;
DROP POLICY IF EXISTS profiles_select_own ON auth_management.profiles;
DROP POLICY IF EXISTS profiles_update_admin ON auth_management.profiles;
DROP POLICY IF EXISTS profiles_update_own ON auth_management.profiles;

-- Policy: profiles_select_admin
-- Description: Los administradores pueden ver todos los perfiles
CREATE POLICY profiles_select_admin
    ON auth_management.profiles
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.is_admin());

COMMENT ON POLICY profiles_select_admin ON auth_management.profiles IS
    'Permite a los administradores ver todos los perfiles de usuario';

-- Policy: profiles_select_own
-- Description: Los usuarios pueden ver su propio perfil
CREATE POLICY profiles_select_own
    ON auth_management.profiles
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (id = gamilit.get_current_user_id());

COMMENT ON POLICY profiles_select_own ON auth_management.profiles IS
    'Permite a los usuarios ver únicamente su propio perfil';

-- Policy: profiles_update_admin
-- Description: Los administradores pueden actualizar cualquier perfil
CREATE POLICY profiles_update_admin
    ON auth_management.profiles
    AS PERMISSIVE
    FOR UPDATE
    TO public
    USING (gamilit.is_admin());

COMMENT ON POLICY profiles_update_admin ON auth_management.profiles IS
    'Permite a los administradores actualizar cualquier perfil de usuario';

-- Policy: profiles_update_own
-- Description: Los usuarios pueden actualizar su propio perfil
CREATE POLICY profiles_update_own
    ON auth_management.profiles
    AS PERMISSIVE
    FOR UPDATE
    TO public
    USING (id = gamilit.get_current_user_id());

COMMENT ON POLICY profiles_update_own ON auth_management.profiles IS
    'Permite a los usuarios actualizar únicamente su propio perfil';
