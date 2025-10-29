-- =====================================================
-- Table: auth_management.tenants
-- Description: Tenants para soporte multi-tenancy - aislamiento de datos por organización
-- Dependencies: None (tabla padre)
-- Created: 2025-10-27
-- =====================================================

SET search_path TO auth_management, public;

DROP TABLE IF EXISTS auth_management.tenants CASCADE;

CREATE TABLE auth_management.tenants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    domain text,
    logo_url text,
    subscription_tier text DEFAULT 'free'::text,
    max_users integer DEFAULT 100,
    max_storage_gb integer DEFAULT 5,
    is_active boolean DEFAULT true,
    trial_ends_at timestamp with time zone,
    settings jsonb DEFAULT '{"theme": "detective", "features": {"analytics_enabled": true, "gamification_enabled": true, "social_features_enabled": true}, "language": "es", "timezone": "America/Mexico_City"}'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),

    -- Primary Key
    CONSTRAINT tenants_pkey PRIMARY KEY (id),

    -- Unique Constraints
    CONSTRAINT tenants_slug_key UNIQUE (slug),

    -- Check Constraints
    CONSTRAINT tenants_max_storage_gb_check CHECK ((max_storage_gb > 0)),
    CONSTRAINT tenants_max_users_check CHECK ((max_users > 0)),
    CONSTRAINT tenants_subscription_tier_check CHECK ((subscription_tier = ANY (ARRAY['free'::text, 'basic'::text, 'professional'::text, 'enterprise'::text])))
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_tenants_settings_gin ON auth_management.tenants USING gin (settings);

-- Triggers
CREATE TRIGGER trg_tenants_updated_at
    BEFORE UPDATE ON auth_management.tenants
    FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- Comments
COMMENT ON TABLE auth_management.tenants IS 'Tenants para soporte multi-tenancy - aislamiento de datos por organización';
COMMENT ON COLUMN auth_management.tenants.slug IS 'URL-friendly identifier único para el tenant';
COMMENT ON COLUMN auth_management.tenants.subscription_tier IS 'Nivel de suscripción: free, basic, professional, enterprise';

-- Permissions
ALTER TABLE auth_management.tenants OWNER TO postgres;
GRANT ALL ON TABLE auth_management.tenants TO glit_user;
