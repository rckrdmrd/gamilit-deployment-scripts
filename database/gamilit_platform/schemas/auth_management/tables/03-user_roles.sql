-- =====================================================
-- Table: auth_management.user_roles
-- Description: Asignaciones de roles a usuarios con permisos específicos
-- Dependencies: auth_management.profiles, auth_management.tenants
-- Created: 2025-10-27
-- =====================================================

SET search_path TO auth_management, public;

DROP TABLE IF EXISTS auth_management.user_roles CASCADE;

CREATE TABLE auth_management.user_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    role public.gamilit_role NOT NULL,
    permissions jsonb DEFAULT '{"read": true, "admin": false, "write": false, "analytics": false}'::jsonb,
    assigned_by uuid,
    assigned_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    expires_at timestamp with time zone,
    is_active boolean DEFAULT true,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),

    -- Primary Key
    CONSTRAINT user_roles_pkey PRIMARY KEY (id),

    -- Unique Constraints
    CONSTRAINT user_roles_user_id_tenant_id_role_key UNIQUE (user_id, tenant_id, role),

    -- Foreign Keys
    CONSTRAINT user_roles_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES auth_management.profiles(id),
    CONSTRAINT user_roles_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE,
    CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_roles_role ON auth_management.user_roles USING btree (role);
CREATE INDEX IF NOT EXISTS idx_user_roles_tenant_id ON auth_management.user_roles USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON auth_management.user_roles USING btree (user_id);

-- Triggers
CREATE TRIGGER trg_user_roles_updated_at
    BEFORE UPDATE ON auth_management.user_roles
    FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- Comments
COMMENT ON TABLE auth_management.user_roles IS 'Asignaciones de roles a usuarios con permisos específicos';
COMMENT ON COLUMN auth_management.user_roles.permissions IS 'Permisos específicos asociados a este rol';

-- Permissions
ALTER TABLE auth_management.user_roles OWNER TO postgres;
GRANT ALL ON TABLE auth_management.user_roles TO gamilit_user;
