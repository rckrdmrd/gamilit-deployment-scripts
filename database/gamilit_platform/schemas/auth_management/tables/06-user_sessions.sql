-- =====================================================
-- Table: auth_management.user_sessions
-- Description: Sesiones activas de usuarios con información de dispositivo y ubicación
-- Dependencies: auth_management.profiles, auth_management.tenants
-- Created: 2025-10-27
-- =====================================================

SET search_path TO auth_management, public;

DROP TABLE IF EXISTS auth_management.user_sessions CASCADE;

CREATE TABLE auth_management.user_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid,
    session_token text NOT NULL,
    refresh_token text,
    user_agent text,
    ip_address inet,
    device_type text,
    browser text,
    os text,
    country text,
    city text,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    last_activity_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    expires_at timestamp with time zone NOT NULL,
    is_active boolean DEFAULT true,
    metadata jsonb DEFAULT '{}'::jsonb,

    -- Primary Key
    CONSTRAINT user_sessions_pkey PRIMARY KEY (id),

    -- Unique Constraints
    CONSTRAINT user_sessions_session_token_key UNIQUE (session_token),

    -- Check Constraints
    CONSTRAINT user_sessions_device_type_check CHECK ((device_type = ANY (ARRAY['desktop'::text, 'mobile'::text, 'tablet'::text, 'unknown'::text]))),

    -- Foreign Keys
    CONSTRAINT user_sessions_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE,
    CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_sessions_active_recent ON auth_management.user_sessions USING btree (user_id, last_activity_at DESC) WHERE (is_active = true);
CREATE INDEX IF NOT EXISTS idx_user_sessions_active ON auth_management.user_sessions USING btree (is_active) WHERE (is_active = true);
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires ON auth_management.user_sessions USING btree (expires_at);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON auth_management.user_sessions USING btree (session_token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON auth_management.user_sessions USING btree (user_id);

-- Comments
COMMENT ON TABLE auth_management.user_sessions IS 'Sesiones activas de usuarios con información de dispositivo y ubicación';
COMMENT ON COLUMN auth_management.user_sessions.session_token IS 'JWT token único para la sesión';
COMMENT ON COLUMN auth_management.user_sessions.expires_at IS 'Fecha de expiración de la sesión';

-- Permissions
ALTER TABLE auth_management.user_sessions OWNER TO gamilit_user;
GRANT ALL ON TABLE auth_management.user_sessions TO gamilit_user;
