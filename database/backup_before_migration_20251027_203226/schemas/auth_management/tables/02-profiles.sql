-- =====================================================
-- Table: auth_management.profiles
-- Description: Perfiles de usuario con información básica, rol y configuraciones
-- Dependencies: auth_management.tenants, auth.users
-- Created: 2025-10-27
-- =====================================================

SET search_path TO auth_management, public;

DROP TABLE IF EXISTS auth_management.profiles CASCADE;

CREATE TABLE auth_management.profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    display_name text,
    full_name text,
    email text NOT NULL,
    avatar_url text,
    phone text,
    date_of_birth date,
    grade_level text,
    student_id text,
    role public.gamilit_role DEFAULT 'student'::public.gamilit_role NOT NULL,
    status public.user_status DEFAULT 'active'::public.user_status NOT NULL,
    email_verified boolean DEFAULT false,
    phone_verified boolean DEFAULT false,
    preferences jsonb DEFAULT '{"theme": "detective", "language": "es", "timezone": "America/Mexico_City", "sound_enabled": true, "notifications_enabled": true}'::jsonb,
    last_sign_in_at timestamp with time zone,
    last_activity_at timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    user_id uuid,

    -- Primary Key
    CONSTRAINT profiles_pkey PRIMARY KEY (id),

    -- Unique Constraints
    CONSTRAINT profiles_email_key UNIQUE (email),

    -- Check Constraints
    CONSTRAINT profiles_email_check CHECK ((email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text)),

    -- Foreign Keys
    CONSTRAINT profiles_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE,
    CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_profiles_email ON auth_management.profiles USING btree (email);
CREATE INDEX IF NOT EXISTS idx_profiles_email_status ON auth_management.profiles USING btree (email, status) WHERE (status = 'active'::public.user_status);
CREATE INDEX IF NOT EXISTS idx_profiles_last_activity ON auth_management.profiles USING btree (last_activity_at DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_preferences_gin ON auth_management.profiles USING gin (preferences);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON auth_management.profiles USING btree (role);
CREATE INDEX IF NOT EXISTS idx_profiles_status ON auth_management.profiles USING btree (status);
CREATE INDEX IF NOT EXISTS idx_profiles_tenant_id ON auth_management.profiles USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_profiles_tenant_role_status ON auth_management.profiles USING btree (tenant_id, role, status);
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON auth_management.profiles USING btree (user_id);

-- Triggers
CREATE TRIGGER trg_audit_profile_changes
    AFTER UPDATE ON auth_management.profiles
    FOR EACH ROW EXECUTE FUNCTION gamilit.audit_profile_changes();

CREATE TRIGGER trg_initialize_user_stats
    AFTER INSERT ON auth_management.profiles
    FOR EACH ROW EXECUTE FUNCTION gamilit.initialize_user_stats();

CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON auth_management.profiles
    FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- Row Level Security Policies
CREATE POLICY profiles_select_admin ON auth_management.profiles
    FOR SELECT USING (gamilit.is_admin());

CREATE POLICY profiles_select_own ON auth_management.profiles
    FOR SELECT USING ((id = gamilit.get_current_user_id()));

CREATE POLICY profiles_update_admin ON auth_management.profiles
    FOR UPDATE USING (gamilit.is_admin());

CREATE POLICY profiles_update_own ON auth_management.profiles
    FOR UPDATE USING ((id = gamilit.get_current_user_id()));

-- Comments
COMMENT ON TABLE auth_management.profiles IS 'Perfiles de usuario con información básica, rol y configuraciones';
COMMENT ON COLUMN auth_management.profiles.grade_level IS 'Grado escolar del estudiante (ej: "6", "7", "8")';
COMMENT ON COLUMN auth_management.profiles.role IS 'Rol del usuario: student, admin_teacher, super_admin';

-- Permissions
ALTER TABLE auth_management.profiles OWNER TO postgres;
GRANT ALL ON TABLE auth_management.profiles TO glit_user;
