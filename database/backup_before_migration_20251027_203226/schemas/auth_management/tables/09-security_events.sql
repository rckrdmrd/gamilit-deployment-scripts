-- =====================================================
-- Table: auth_management.security_events
-- Description: Log de auditoría para eventos relacionados con seguridad
-- Dependencies: auth.users (opcional, puede ser NULL)
-- Created: 2025-10-27
-- =====================================================

SET search_path TO auth_management, public;

DROP TABLE IF EXISTS auth_management.security_events CASCADE;

CREATE TABLE auth_management.security_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event_type character varying(100) NOT NULL,
    severity character varying(50) NOT NULL,
    description text,
    ip_address inet,
    user_agent text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,

    -- Primary Key
    CONSTRAINT security_events_pkey PRIMARY KEY (id),

    -- Check Constraints
    CONSTRAINT security_events_severity_check CHECK (((severity)::text = ANY ((ARRAY['low'::character varying, 'medium'::character varying, 'high'::character varying, 'critical'::character varying])::text[]))),

    -- Foreign Keys
    CONSTRAINT security_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_security_events_created ON auth_management.security_events USING btree (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_security_events_severity ON auth_management.security_events USING btree (severity);
CREATE INDEX IF NOT EXISTS idx_security_events_type ON auth_management.security_events USING btree (event_type);
CREATE INDEX IF NOT EXISTS idx_security_events_user ON auth_management.security_events USING btree (user_id);

-- Comments
COMMENT ON TABLE auth_management.security_events IS 'Audit log for security-related events';
COMMENT ON COLUMN auth_management.security_events.event_type IS 'Type of security event (e.g., login_attempt, password_change)';
COMMENT ON COLUMN auth_management.security_events.severity IS 'Severity level: low, medium, high, critical';
COMMENT ON COLUMN auth_management.security_events.metadata IS 'Additional event data in JSON format';

-- Permissions
ALTER TABLE auth_management.security_events OWNER TO postgres;
GRANT ALL ON TABLE auth_management.security_events TO glit_user;
