-- =====================================================
-- RLS Policies: auth_management.tenants
-- Description: Row Level Security para multi-tenancy
-- Priority: CRITICAL - Multi-tenancy requirement
-- Created: 2025-10-27
-- =====================================================

-- Enable RLS
ALTER TABLE auth_management.tenants ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- SELECT Policies
-- =====================================================

-- Policy: Usuarios pueden ver solo su propio tenant
CREATE POLICY "Users can view own tenant"
ON auth_management.tenants
FOR SELECT
TO authenticated
USING (
    id = (
        SELECT tenant_id
        FROM auth_management.profiles
        WHERE id = gamilit.get_current_user_id()
    )
);

-- Policy: Super admins pueden ver todos los tenants
CREATE POLICY "Super admins can view all tenants"
ON auth_management.tenants
FOR SELECT
TO authenticated
USING (gamilit.is_super_admin());

-- =====================================================
-- INSERT Policies
-- =====================================================

-- Policy: Solo super admins pueden crear tenants
CREATE POLICY "Only super admins can insert tenants"
ON auth_management.tenants
FOR INSERT
TO authenticated
WITH CHECK (gamilit.is_super_admin());

-- =====================================================
-- UPDATE Policies
-- =====================================================

-- Policy: Admins pueden actualizar su propio tenant
CREATE POLICY "Admins can update own tenant"
ON auth_management.tenants
FOR UPDATE
TO authenticated
USING (
    gamilit.is_admin()
    AND id = (
        SELECT tenant_id
        FROM auth_management.profiles
        WHERE id = gamilit.get_current_user_id()
    )
)
WITH CHECK (
    gamilit.is_admin()
    AND id = (
        SELECT tenant_id
        FROM auth_management.profiles
        WHERE id = gamilit.get_current_user_id()
    )
);

-- Policy: Super admins pueden actualizar cualquier tenant
CREATE POLICY "Super admins can update any tenant"
ON auth_management.tenants
FOR UPDATE
TO authenticated
USING (gamilit.is_super_admin())
WITH CHECK (gamilit.is_super_admin());

-- =====================================================
-- DELETE Policies
-- =====================================================

-- Policy: Solo super admins pueden eliminar tenants
CREATE POLICY "Only super admins can delete tenants"
ON auth_management.tenants
FOR DELETE
TO authenticated
USING (gamilit.is_super_admin());

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON POLICY "Users can view own tenant" ON auth_management.tenants IS 'Permite a usuarios ver solo su propio tenant';
COMMENT ON POLICY "Super admins can view all tenants" ON auth_management.tenants IS 'Permite a super admins ver todos los tenants';
COMMENT ON POLICY "Only super admins can insert tenants" ON auth_management.tenants IS 'Solo super admins pueden crear nuevos tenants';
COMMENT ON POLICY "Admins can update own tenant" ON auth_management.tenants IS 'Permite a admins actualizar su propio tenant';
COMMENT ON POLICY "Super admins can update any tenant" ON auth_management.tenants IS 'Permite a super admins actualizar cualquier tenant';
COMMENT ON POLICY "Only super admins can delete tenants" ON auth_management.tenants IS 'Solo super admins pueden eliminar tenants';
