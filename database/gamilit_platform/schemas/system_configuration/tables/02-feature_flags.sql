-- =====================================================
-- Table: system_configuration.feature_flags
-- Description: Feature flags para activación gradual de funcionalidades
-- Created: 2025-10-27
-- =====================================================

SET search_path TO system_configuration, public;

DROP TABLE IF EXISTS system_configuration.feature_flags CASCADE;

CREATE TABLE system_configuration.feature_flags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    feature_name text NOT NULL,
    feature_key text NOT NULL,
    description text,
    is_enabled boolean DEFAULT false,
    rollout_percentage integer DEFAULT 0,
    target_users uuid[],
    target_roles public.gamilit_role[],
    target_conditions jsonb DEFAULT '{}'::jsonb,
    starts_at timestamp with time zone,
    ends_at timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_by uuid,
    updated_by uuid,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT feature_flags_rollout_percentage_check CHECK (((rollout_percentage >= 0) AND (rollout_percentage <= 100)))
);

ALTER TABLE system_configuration.feature_flags OWNER TO gamilit_user;

-- =====================================================
-- Primary Key
-- =====================================================

ALTER TABLE ONLY system_configuration.feature_flags
    ADD CONSTRAINT feature_flags_pkey PRIMARY KEY (id);

-- =====================================================
-- Unique Constraints
-- =====================================================

ALTER TABLE ONLY system_configuration.feature_flags
    ADD CONSTRAINT feature_flags_feature_key_key UNIQUE (feature_key);

-- =====================================================
-- Indexes
-- =====================================================

CREATE INDEX idx_feature_flags_active ON system_configuration.feature_flags USING btree (starts_at, ends_at) WHERE (is_enabled = true);

CREATE INDEX idx_feature_flags_enabled ON system_configuration.feature_flags USING btree (is_enabled) WHERE (is_enabled = true);

CREATE INDEX idx_feature_flags_key ON system_configuration.feature_flags USING btree (feature_key);

-- =====================================================
-- Triggers
-- =====================================================

CREATE TRIGGER trg_feature_flags_updated_at BEFORE UPDATE ON system_configuration.feature_flags FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- =====================================================
-- Foreign Keys
-- =====================================================

ALTER TABLE ONLY system_configuration.feature_flags
    ADD CONSTRAINT feature_flags_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth_management.profiles(id);

ALTER TABLE ONLY system_configuration.feature_flags
    ADD CONSTRAINT feature_flags_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;

ALTER TABLE ONLY system_configuration.feature_flags
    ADD CONSTRAINT feature_flags_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth_management.profiles(id);

-- =====================================================
-- Row Level Security
-- =====================================================

ALTER TABLE system_configuration.feature_flags ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- Grants
-- =====================================================

GRANT ALL ON TABLE system_configuration.feature_flags TO gamilit_user;

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON TABLE system_configuration.feature_flags IS 'Feature flags para activación gradual de funcionalidades';

COMMENT ON COLUMN system_configuration.feature_flags.rollout_percentage IS 'Porcentaje de usuarios con acceso a la feature (0-100)';

COMMENT ON COLUMN system_configuration.feature_flags.target_roles IS 'Roles específicos con acceso a la feature';
