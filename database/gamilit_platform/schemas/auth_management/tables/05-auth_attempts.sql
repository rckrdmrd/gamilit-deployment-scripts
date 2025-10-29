-- =====================================================
-- Table: auth_management.auth_attempts
-- Description: Registro de intentos de autenticación para seguridad y auditoría
-- Dependencies: None (tabla de auditoría independiente)
-- Created: 2025-10-27
-- =====================================================

SET search_path TO auth_management, public;

DROP TABLE IF EXISTS auth_management.auth_attempts CASCADE;

CREATE TABLE auth_management.auth_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    ip_address inet NOT NULL,
    user_agent text,
    success boolean NOT NULL,
    failure_reason text,
    tenant_slug text,
    attempted_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    metadata jsonb DEFAULT '{}'::jsonb,

    -- Primary Key
    CONSTRAINT auth_attempts_pkey PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_auth_attempts_attempted_at ON auth_management.auth_attempts USING btree (attempted_at DESC);
CREATE INDEX IF NOT EXISTS idx_auth_attempts_email ON auth_management.auth_attempts USING btree (email);
CREATE INDEX IF NOT EXISTS idx_auth_attempts_failed ON auth_management.auth_attempts USING btree (email, attempted_at) WHERE (success = false);
CREATE INDEX IF NOT EXISTS idx_auth_attempts_ip ON auth_management.auth_attempts USING btree (ip_address);

-- Comments
COMMENT ON TABLE auth_management.auth_attempts IS 'Registro de intentos de autenticación para seguridad y auditoría';
COMMENT ON COLUMN auth_management.auth_attempts.success IS 'True si el intento fue exitoso, false si falló';
COMMENT ON COLUMN auth_management.auth_attempts.failure_reason IS 'Razón del fallo: invalid_password, user_not_found, account_locked, etc.';

-- Permissions
ALTER TABLE auth_management.auth_attempts OWNER TO gamilit_user;
GRANT ALL ON TABLE auth_management.auth_attempts TO gamilit_user;
