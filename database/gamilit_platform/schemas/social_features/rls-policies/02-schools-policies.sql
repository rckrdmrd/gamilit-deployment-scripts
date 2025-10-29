-- =====================================================
-- RLS Policies for: social_features.schools
-- Description: Schools with multi-tenant isolation
-- Created: 2025-10-28
-- Policies: 3 (SELECT: 1, INSERT: 1, UPDATE: 1)
-- =====================================================
--
-- Security Strategy:
-- - Tenant isolation: Users only see schools in their tenant
-- - Admin-only management: Only super_admins can create/update schools
-- - Public read within tenant: All authenticated users can read schools in their tenant
-- =====================================================

DROP POLICY IF EXISTS schools_read_tenant ON social_features.schools;
DROP POLICY IF EXISTS schools_insert_admin ON social_features.schools;
DROP POLICY IF EXISTS schools_update_admin ON social_features.schools;

-- Policy: schools_read_tenant
-- Purpose: All users can read schools in their tenant (multi-tenant critical)
CREATE POLICY schools_read_tenant
    ON social_features.schools
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (tenant_id = current_setting('app.current_tenant_id', true)::uuid);

COMMENT ON POLICY schools_read_tenant ON social_features.schools IS
    'Multi-tenant isolation: Users can only see schools in their own tenant';

-- Policy: schools_insert_admin
-- Purpose: Only admins can create schools
CREATE POLICY schools_insert_admin
    ON social_features.schools
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'super_admin'
        )
        AND tenant_id = current_setting('app.current_tenant_id', true)::uuid
    );

COMMENT ON POLICY schools_insert_admin ON social_features.schools IS
    'Only super_admins can create new schools in their tenant';

-- Policy: schools_update_admin
-- Purpose: Only admins can update schools
CREATE POLICY schools_update_admin
    ON social_features.schools
    AS PERMISSIVE
    FOR UPDATE
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'super_admin'
        )
        AND tenant_id = current_setting('app.current_tenant_id', true)::uuid
    );

COMMENT ON POLICY schools_update_admin ON social_features.schools IS
    'Only super_admins can update schools in their tenant';
