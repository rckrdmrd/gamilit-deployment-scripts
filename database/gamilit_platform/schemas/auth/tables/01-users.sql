-- =====================================================
-- Table: auth.users
-- Description: Tabla de usuarios del sistema con autenticación y roles
-- Created: 2025-10-27
-- =====================================================

SET search_path TO auth, public;

DROP TABLE IF EXISTS auth.users CASCADE;

CREATE TABLE auth.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    encrypted_password text NOT NULL,
    role public.gamilit_role DEFAULT 'student'::public.gamilit_role NOT NULL,
    email_confirmed_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_user_meta_data jsonb DEFAULT '{}'::jsonb,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico()
);

ALTER TABLE auth.users OWNER TO postgres;

-- =====================================================
-- Constraints
-- =====================================================

-- Primary Key
ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);

-- Unique Constraints
ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);

-- =====================================================
-- Indexes
-- =====================================================

CREATE INDEX idx_auth_users_email ON auth.users USING btree (email);
CREATE INDEX idx_auth_users_role ON auth.users USING btree (role);

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON TABLE auth.users IS 'Tabla de usuarios del sistema con autenticación y roles';
COMMENT ON COLUMN auth.users.id IS 'Identificador único del usuario (UUID)';
COMMENT ON COLUMN auth.users.email IS 'Correo electrónico único del usuario';
COMMENT ON COLUMN auth.users.encrypted_password IS 'Contraseña encriptada del usuario';
COMMENT ON COLUMN auth.users.role IS 'Rol del usuario en el sistema (student, instructor, admin, etc.)';
COMMENT ON COLUMN auth.users.email_confirmed_at IS 'Fecha y hora de confirmación del email';
COMMENT ON COLUMN auth.users.last_sign_in_at IS 'Fecha y hora del último inicio de sesión';
COMMENT ON COLUMN auth.users.raw_user_meta_data IS 'Metadatos adicionales del usuario en formato JSON';
COMMENT ON COLUMN auth.users.deleted_at IS 'Fecha y hora de eliminación lógica (soft delete)';
COMMENT ON COLUMN auth.users.created_at IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN auth.users.updated_at IS 'Fecha y hora de última actualización del registro';

-- =====================================================
-- Grants
-- =====================================================

GRANT ALL ON TABLE auth.users TO gamilit_user;
