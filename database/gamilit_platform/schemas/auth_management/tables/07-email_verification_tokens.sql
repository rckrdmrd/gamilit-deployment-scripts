-- =====================================================
-- Table: auth_management.email_verification_tokens
-- Description: Almacena tokens de verificación de email para registro de nuevos usuarios
-- Dependencies: auth.users
-- Created: 2025-10-27
-- =====================================================

SET search_path TO auth_management, public;

DROP TABLE IF EXISTS auth_management.email_verification_tokens CASCADE;

CREATE TABLE auth_management.email_verification_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token_hash character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,

    -- Primary Key
    CONSTRAINT email_verification_tokens_pkey PRIMARY KEY (id),

    -- Unique Constraints
    CONSTRAINT email_verification_tokens_token_hash_key UNIQUE (token_hash),

    -- Foreign Keys
    CONSTRAINT email_verification_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_hash ON auth_management.email_verification_tokens USING btree (token_hash);
CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_user ON auth_management.email_verification_tokens USING btree (user_id);

-- Comments
COMMENT ON TABLE auth_management.email_verification_tokens IS 'Stores email verification tokens for new user registration';
COMMENT ON COLUMN auth_management.email_verification_tokens.token_hash IS 'Hashed verification token';
COMMENT ON COLUMN auth_management.email_verification_tokens.verified_at IS 'Timestamp when email was verified';

-- Permissions
ALTER TABLE auth_management.email_verification_tokens OWNER TO postgres;
GRANT ALL ON TABLE auth_management.email_verification_tokens TO gamilit_user;
