-- =====================================================
-- Table: system_configuration.system_settings
-- Description: Configuración global de la plataforma
-- Created: 2025-10-27
-- =====================================================

SET search_path TO system_configuration, public;

DROP TABLE IF EXISTS system_configuration.system_settings CASCADE;

CREATE TABLE system_configuration.system_settings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    setting_key text NOT NULL,
    setting_category text,
    setting_subcategory text,
    setting_value text NOT NULL,
    value_type text DEFAULT 'string'::text,
    default_value text,
    display_name text,
    description text,
    help_text text,
    is_public boolean DEFAULT false,
    is_readonly boolean DEFAULT false,
    is_system boolean DEFAULT false,
    requires_restart boolean DEFAULT false,
    validation_rules jsonb DEFAULT '{}'::jsonb,
    allowed_values text[],
    min_value numeric,
    max_value numeric,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_by uuid,
    updated_by uuid,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT system_settings_setting_category_check CHECK ((setting_category = ANY (ARRAY['general'::text, 'gamification'::text, 'security'::text, 'email'::text, 'storage'::text, 'analytics'::text, 'integrations'::text]))),
    CONSTRAINT system_settings_value_type_check CHECK ((value_type = ANY (ARRAY['string'::text, 'number'::text, 'boolean'::text, 'json'::text, 'array'::text])))
);

ALTER TABLE system_configuration.system_settings OWNER TO postgres;

-- =====================================================
-- Primary Key
-- =====================================================

ALTER TABLE ONLY system_configuration.system_settings
    ADD CONSTRAINT system_settings_pkey PRIMARY KEY (id);

-- =====================================================
-- Unique Constraints
-- =====================================================

ALTER TABLE ONLY system_configuration.system_settings
    ADD CONSTRAINT system_settings_setting_key_key UNIQUE (setting_key);

-- =====================================================
-- Indexes
-- =====================================================

CREATE INDEX idx_settings_category ON system_configuration.system_settings USING btree (setting_category);

CREATE INDEX idx_settings_key ON system_configuration.system_settings USING btree (setting_key);

CREATE INDEX idx_settings_public ON system_configuration.system_settings USING btree (is_public) WHERE (is_public = true);

-- =====================================================
-- Triggers
-- =====================================================

CREATE TRIGGER trg_system_settings_updated_at BEFORE UPDATE ON system_configuration.system_settings FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- =====================================================
-- Foreign Keys
-- =====================================================

ALTER TABLE ONLY system_configuration.system_settings
    ADD CONSTRAINT system_settings_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth_management.profiles(id);

ALTER TABLE ONLY system_configuration.system_settings
    ADD CONSTRAINT system_settings_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;

ALTER TABLE ONLY system_configuration.system_settings
    ADD CONSTRAINT system_settings_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth_management.profiles(id);

-- =====================================================
-- Row Level Security
-- =====================================================

ALTER TABLE system_configuration.system_settings ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- Grants
-- =====================================================

GRANT ALL ON TABLE system_configuration.system_settings TO gamilit_user;

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON TABLE system_configuration.system_settings IS 'Configuración global de la plataforma';

COMMENT ON COLUMN system_configuration.system_settings.setting_key IS 'Clave única del setting (ej: "ml_coins_welcome_bonus")';

COMMENT ON COLUMN system_configuration.system_settings.is_system IS 'Si es true, no puede ser modificado por usuarios';
