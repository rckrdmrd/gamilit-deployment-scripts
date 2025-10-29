-- =====================================================
-- Table: auth_management.memberships
-- Description: Relaciones usuario-tenant con permisos y restricciones
-- Dependencies: auth_management.profiles, auth_management.tenants
-- Created: 2025-10-27
-- =====================================================

SET search_path TO auth_management, public;

DROP TABLE IF EXISTS auth_management.memberships CASCADE;

CREATE TABLE auth_management.memberships (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    role text DEFAULT 'member'::text,
    status text DEFAULT 'active'::text,
    joined_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    expires_at timestamp with time zone,
    last_access_at timestamp with time zone,
    permissions jsonb DEFAULT '{"can_invite": false, "access_level": "standard", "can_manage_users": false}'::jsonb,
    restrictions jsonb DEFAULT '{}'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),

    -- Primary Key
    CONSTRAINT memberships_pkey PRIMARY KEY (id),

    -- Unique Constraints
    CONSTRAINT memberships_user_id_tenant_id_key UNIQUE (user_id, tenant_id),

    -- Check Constraints
    CONSTRAINT memberships_role_check CHECK ((role = ANY (ARRAY['owner'::text, 'admin'::text, 'member'::text, 'guest'::text]))),
    CONSTRAINT memberships_status_check CHECK ((status = ANY (ARRAY['active'::text, 'suspended'::text, 'pending'::text, 'expired'::text]))),

    -- Foreign Keys
    CONSTRAINT memberships_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE,
    CONSTRAINT memberships_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_memberships_status ON auth_management.memberships USING btree (status);
CREATE INDEX IF NOT EXISTS idx_memberships_tenant_id ON auth_management.memberships USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_memberships_user_id ON auth_management.memberships USING btree (user_id);

-- Triggers
CREATE TRIGGER trg_memberships_updated_at
    BEFORE UPDATE ON auth_management.memberships
    FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- Comments
COMMENT ON TABLE auth_management.memberships IS 'Relaciones usuario-tenant con permisos y restricciones';
COMMENT ON COLUMN auth_management.memberships.role IS 'Rol dentro del tenant: owner, admin, member, guest';
COMMENT ON COLUMN auth_management.memberships.status IS 'Estado de la membresía: active, suspended, pending, expired';

-- Permissions
ALTER TABLE auth_management.memberships OWNER TO gamilit_user;
GRANT ALL ON TABLE auth_management.memberships TO gamilit_user;
