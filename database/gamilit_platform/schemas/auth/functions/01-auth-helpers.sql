-- =====================================================
-- Auth Helper Functions for RLS Policies
-- Created: 2025-10-28
-- Description: Helper functions to retrieve current user context
--              Used by RLS policies across all schemas
-- =====================================================
--
-- These functions provide a consistent interface for RLS policies
-- to access current user authentication context via application
-- settings (app.current_user_id, app.current_tenant_id, etc.)
--
-- Note: These settings must be set by the application layer
-- before executing queries on behalf of a user.
-- =====================================================

-- =====================================================
-- Function: get_current_user_id
-- Returns: UUID of the currently authenticated user
-- Usage: Used in RLS USING clauses to identify user's own data
-- =====================================================

CREATE OR REPLACE FUNCTION auth.get_current_user_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT current_setting('app.current_user_id', true)::uuid;
$$;

COMMENT ON FUNCTION auth.get_current_user_id IS
    'Returns the UUID of the currently authenticated user from session context';

-- =====================================================
-- Function: get_current_tenant_id
-- Returns: UUID of the current tenant
-- Usage: Used in RLS USING clauses for multi-tenant isolation
-- =====================================================

CREATE OR REPLACE FUNCTION auth.get_current_tenant_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT current_setting('app.current_tenant_id', true)::uuid;
$$;

COMMENT ON FUNCTION auth.get_current_tenant_id IS
    'Returns the UUID of the current tenant for multi-tenant isolation';

-- =====================================================
-- Function: get_current_user_role
-- Returns: Role of the currently authenticated user
-- Usage: Used in RLS USING clauses for role-based access control
-- =====================================================

CREATE OR REPLACE FUNCTION auth.get_current_user_role()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT current_setting('app.current_user_role', true);
$$;

COMMENT ON FUNCTION auth.get_current_user_role IS
    'Returns the role of the currently authenticated user (super_admin, admin_teacher, student)';

-- =====================================================
-- Function: is_admin
-- Returns: TRUE if current user is a super_admin
-- Usage: Simplified admin check for RLS policies
-- =====================================================

CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT EXISTS (
        SELECT 1 FROM auth_management.user_roles
        WHERE user_id = current_setting('app.current_user_id', true)::uuid
            AND role = 'super_admin'
    );
$$;

COMMENT ON FUNCTION auth.is_admin IS
    'Returns TRUE if the current user has super_admin role';

-- =====================================================
-- Function: is_teacher
-- Returns: TRUE if current user is an admin_teacher
-- Usage: Simplified teacher check for RLS policies
-- =====================================================

CREATE OR REPLACE FUNCTION auth.is_teacher()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT EXISTS (
        SELECT 1 FROM auth_management.user_roles
        WHERE user_id = current_setting('app.current_user_id', true)::uuid
            AND role = 'admin_teacher'
    );
$$;

COMMENT ON FUNCTION auth.is_teacher IS
    'Returns TRUE if the current user has admin_teacher role';

-- =====================================================
-- Function: is_student
-- Returns: TRUE if current user is a student
-- Usage: Simplified student check for RLS policies
-- =====================================================

CREATE OR REPLACE FUNCTION auth.is_student()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT EXISTS (
        SELECT 1 FROM auth_management.user_roles
        WHERE user_id = current_setting('app.current_user_id', true)::uuid
            AND role = 'student'
    );
$$;

COMMENT ON FUNCTION auth.is_student IS
    'Returns TRUE if the current user has student role';

-- =====================================================
-- Function: uid (alias for get_current_user_id)
-- Returns: UUID of the currently authenticated user
-- Usage: Short alias for convenience in RLS policies
-- =====================================================

CREATE OR REPLACE FUNCTION auth.uid()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT current_setting('app.current_user_id', true)::uuid;
$$;

COMMENT ON FUNCTION auth.uid IS
    'Alias for get_current_user_id() - returns current user UUID';

-- =====================================================
-- Usage Examples:
-- =====================================================
--
-- Setting context in application (before queries):
--   SET LOCAL app.current_user_id = 'user-uuid-here';
--   SET LOCAL app.current_tenant_id = 'tenant-uuid-here';
--   SET LOCAL app.current_user_role = 'student';
--
-- Using in RLS policies:
--   USING (user_id = auth.uid())
--   USING (tenant_id = auth.get_current_tenant_id())
--   USING (auth.is_admin())
--   USING (auth.is_teacher() AND ...)
-- =====================================================
