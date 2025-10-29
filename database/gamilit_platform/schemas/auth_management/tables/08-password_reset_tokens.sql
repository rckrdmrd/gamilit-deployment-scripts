-- =====================================================
-- Table: auth_management.password_reset_tokens
-- Description: Almacena tokens de restablecimiento de contraseña para recuperación de usuario
-- Dependencies: auth.users
-- Created: 2025-10-27
-- =====================================================

SET search_path TO auth_management, public;

DROP TABLE IF EXISTS auth_management.password_reset_tokens CASCADE;

CREATE TABLE auth_management.password_reset_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token_hash character varying(255) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    ip_address inet,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,

    -- Primary Key
    CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id),

    -- Unique Constraints
    CONSTRAINT password_reset_tokens_token_hash_key UNIQUE (token_hash),

    -- Foreign Keys
    CONSTRAINT password_reset_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_hash ON auth_management.password_reset_tokens USING btree (token_hash);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_user ON auth_management.password_reset_tokens USING btree (user_id);

-- Comments
COMMENT ON TABLE auth_management.password_reset_tokens IS 'Stores password reset tokens for user password recovery';
COMMENT ON COLUMN auth_management.password_reset_tokens.token_hash IS 'Hashed token for security';
COMMENT ON COLUMN auth_management.password_reset_tokens.expires_at IS 'Token expiration timestamp';
COMMENT ON COLUMN auth_management.password_reset_tokens.used_at IS 'Timestamp when token was used';

-- Permissions
ALTER TABLE auth_management.password_reset_tokens OWNER TO gamilit_user;
GRANT ALL ON TABLE auth_management.password_reset_tokens TO gamilit_user;
