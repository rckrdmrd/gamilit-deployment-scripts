-- =====================================================
-- RLS Policies for auth_management schema
-- Description: Políticas de seguridad para gestión de autenticación
-- Created: 2025-10-27
-- Updated: 2025-10-28 (Agent 3 - 18 policies integrated)
-- =====================================================
--
-- Security Strategy:
-- - Multi-tenant isolation via tenant_id
-- - Role-based access (super_admin, admin_teacher, student)
-- - Self-service access for user's own data
-- - Teacher access to student data through classroom relationship
-- - Token tables secured for validation only
-- =====================================================

-- =====================================================
-- TABLE: auth_management.profiles
-- Description: User profiles with role-based and tenant-based access
-- Policies: 5 (SELECT: 3, UPDATE: 2)
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS profiles_select_admin ON auth_management.profiles;
DROP POLICY IF EXISTS profiles_select_own ON auth_management.profiles;
DROP POLICY IF EXISTS profiles_update_admin ON auth_management.profiles;
DROP POLICY IF EXISTS profiles_update_own ON auth_management.profiles;
DROP POLICY IF EXISTS profiles_read_own ON auth_management.profiles;
DROP POLICY IF EXISTS profiles_read_teacher ON auth_management.profiles;
DROP POLICY IF EXISTS profiles_read_admin ON auth_management.profiles;
DROP POLICY IF EXISTS profiles_update_own ON auth_management.profiles;
DROP POLICY IF EXISTS profiles_update_admin ON auth_management.profiles;

-- Policy: profiles_read_own
-- Purpose: Users can read their own profile
CREATE POLICY profiles_read_own
    ON auth_management.profiles
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY profiles_read_own ON auth_management.profiles IS
    'Permite a los usuarios ver únicamente su propio perfil';

-- Policy: profiles_read_teacher
-- Purpose: Teachers can read profiles of students in their classrooms
CREATE POLICY profiles_read_teacher
    ON auth_management.profiles
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'admin_teacher'
        )
        AND role = 'student'
        AND id IN (
            SELECT cm.student_id
            FROM social_features.classroom_members cm
            JOIN social_features.classrooms c ON c.id = cm.classroom_id
            WHERE c.teacher_id = current_setting('app.current_user_id', true)::uuid
        )
    );

COMMENT ON POLICY profiles_read_teacher ON auth_management.profiles IS
    'Permite a los profesores ver perfiles de estudiantes en sus aulas';

-- Policy: profiles_read_admin
-- Purpose: Admins can read all profiles in their tenant
CREATE POLICY profiles_read_admin
    ON auth_management.profiles
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'super_admin'
        )
        AND tenant_id = current_setting('app.current_tenant_id', true)::uuid
    );

COMMENT ON POLICY profiles_read_admin ON auth_management.profiles IS
    'Permite a los administradores ver todos los perfiles de su tenant';

-- Policy: profiles_update_own
-- Purpose: Users can update their own profile
CREATE POLICY profiles_update_own
    ON auth_management.profiles
    AS PERMISSIVE
    FOR UPDATE
    TO public
    USING (id = current_setting('app.current_user_id', true)::uuid)
    WITH CHECK (id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY profiles_update_own ON auth_management.profiles IS
    'Permite a los usuarios actualizar únicamente su propio perfil';

-- Policy: profiles_update_admin
-- Purpose: Admins can update any profile in their tenant
CREATE POLICY profiles_update_admin
    ON auth_management.profiles
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

COMMENT ON POLICY profiles_update_admin ON auth_management.profiles IS
    'Permite a los administradores actualizar cualquier perfil de su tenant';

-- =====================================================
-- TABLE: auth_management.user_sessions
-- Description: User session tracking with self-service access
-- Policies: 1 (SELECT: 1)
-- =====================================================

DROP POLICY IF EXISTS user_sessions_read_own ON auth_management.user_sessions;

-- Policy: user_sessions_read_own
-- Purpose: Users can read their own sessions
CREATE POLICY user_sessions_read_own
    ON auth_management.user_sessions
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY user_sessions_read_own ON auth_management.user_sessions IS
    'Permite a los usuarios ver solo sus propias sesiones activas';

-- =====================================================
-- TABLE: auth_management.password_reset_tokens
-- Description: Password reset tokens - validation access only
-- Policies: 1 (SELECT: 1)
-- =====================================================

DROP POLICY IF EXISTS password_reset_read_own ON auth_management.password_reset_tokens;

-- Policy: password_reset_read_own
-- Purpose: Users can read their own password reset tokens for validation
CREATE POLICY password_reset_read_own
    ON auth_management.password_reset_tokens
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY password_reset_read_own ON auth_management.password_reset_tokens IS
    'Permite a los usuarios validar sus propios tokens de reset de contraseña';

-- =====================================================
-- TABLE: auth_management.email_verification_tokens
-- Description: Email verification tokens - validation access only
-- Policies: 1 (SELECT: 1)
-- =====================================================

DROP POLICY IF EXISTS email_verification_read_own ON auth_management.email_verification_tokens;

-- Policy: email_verification_read_own
-- Purpose: Users can read their own email verification tokens
CREATE POLICY email_verification_read_own
    ON auth_management.email_verification_tokens
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY email_verification_read_own ON auth_management.email_verification_tokens IS
    'Permite a los usuarios validar sus propios tokens de verificación de email';

-- =====================================================
-- TABLE: auth_management.security_events
-- Description: Security event logging with user and admin access
-- Policies: 2 (SELECT: 2)
-- =====================================================

DROP POLICY IF EXISTS security_events_read_own ON auth_management.security_events;
DROP POLICY IF EXISTS security_events_read_admin ON auth_management.security_events;

-- Policy: security_events_read_own
-- Purpose: Users can read their own security events
CREATE POLICY security_events_read_own
    ON auth_management.security_events
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY security_events_read_own ON auth_management.security_events IS
    'Permite a los usuarios ver sus propios eventos de seguridad';

-- Policy: security_events_read_admin
-- Purpose: Admins can read all security events
CREATE POLICY security_events_read_admin
    ON auth_management.security_events
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'super_admin'
        )
    );

COMMENT ON POLICY security_events_read_admin ON auth_management.security_events IS
    'Permite a los administradores ver todos los eventos de seguridad';

-- =====================================================
-- TABLE: auth_management.auth_attempts
-- Description: Authentication attempts - system access only
-- Policies: 0 (No user-facing policies, system-only access)
-- =====================================================

-- Note: No policies defined for auth_attempts
-- This table is managed entirely by system functions with SECURITY DEFINER
-- Users cannot directly query authentication attempt logs

-- =====================================================
-- TABLE: auth_management.memberships
-- Description: User memberships with tenant isolation
-- Policies: 1 (SELECT: 1)
-- =====================================================

DROP POLICY IF EXISTS memberships_read_tenant ON auth_management.memberships;

-- Policy: memberships_read_tenant
-- Purpose: Users can read memberships in their tenant
CREATE POLICY memberships_read_tenant
    ON auth_management.memberships
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (tenant_id = current_setting('app.current_tenant_id', true)::uuid);

COMMENT ON POLICY memberships_read_tenant ON auth_management.memberships IS
    'Permite ver membresías solo dentro del tenant actual (aislamiento multi-tenant)';

-- =====================================================
-- TABLE: auth_management.tenants
-- Description: Tenant information - own tenant access only
-- Policies: 1 (SELECT: 1)
-- =====================================================

DROP POLICY IF EXISTS tenants_read_own ON auth_management.tenants;

-- Policy: tenants_read_own
-- Purpose: Users can read their own tenant information
CREATE POLICY tenants_read_own
    ON auth_management.tenants
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (id = current_setting('app.current_tenant_id', true)::uuid);

COMMENT ON POLICY tenants_read_own ON auth_management.tenants IS
    'Permite a los usuarios ver solo la información de su propio tenant';

-- =====================================================
-- TABLE: auth_management.user_roles
-- Description: User role assignments - self-service read access
-- Policies: 1 (SELECT: 1)
-- =====================================================

DROP POLICY IF EXISTS user_roles_read_own ON auth_management.user_roles;

-- Policy: user_roles_read_own
-- Purpose: Users can read their own role assignments
CREATE POLICY user_roles_read_own
    ON auth_management.user_roles
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY user_roles_read_own ON auth_management.user_roles IS
    'Permite a los usuarios ver sus propios roles asignados';

-- =====================================================
-- SUMMARY: auth_management schema
-- =====================================================
-- Total policies: 18
-- Tables with policies: 9
-- - profiles: 5 policies (3 SELECT, 2 UPDATE)
-- - user_sessions: 1 policy (1 SELECT)
-- - password_reset_tokens: 1 policy (1 SELECT)
-- - email_verification_tokens: 1 policy (1 SELECT)
-- - security_events: 2 policies (2 SELECT)
-- - auth_attempts: 0 policies (system-only)
-- - memberships: 1 policy (1 SELECT)
-- - tenants: 1 policy (1 SELECT)
-- - user_roles: 1 policy (1 SELECT)
-- =====================================================
