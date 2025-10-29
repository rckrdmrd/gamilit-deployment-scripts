-- =====================================================
-- Table: auth_management.user_preferences
-- Description: Preferencias de usuario (tema, idioma, notificaciones, sonido, tutorial)
-- Dependencies: auth_management.profiles
-- Created: 2025-10-28
-- Modified: 2025-10-28
-- =====================================================

SET search_path TO auth_management, public;

DROP TABLE IF EXISTS auth_management.user_preferences CASCADE;

CREATE TABLE IF NOT EXISTS auth_management.user_preferences (
    user_id UUID PRIMARY KEY REFERENCES auth_management.profiles(id) ON DELETE CASCADE,
    theme VARCHAR(20) DEFAULT 'light',
    language VARCHAR(10) DEFAULT 'es',
    notifications_enabled BOOLEAN DEFAULT true,
    email_notifications BOOLEAN DEFAULT true,
    sound_enabled BOOLEAN DEFAULT true,
    tutorial_completed BOOLEAN DEFAULT false,
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT chk_theme CHECK (theme IN ('light', 'dark', 'auto')),
    CONSTRAINT chk_language CHECK (language IN ('es', 'en'))
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_preferences_theme
    ON auth_management.user_preferences(theme);

CREATE INDEX IF NOT EXISTS idx_user_preferences_language
    ON auth_management.user_preferences(language);

CREATE INDEX IF NOT EXISTS idx_user_preferences_tutorial
    ON auth_management.user_preferences(tutorial_completed)
    WHERE tutorial_completed = false;

CREATE INDEX IF NOT EXISTS idx_user_preferences_preferences
    ON auth_management.user_preferences USING GIN(preferences);

-- Trigger para updated_at
CREATE TRIGGER trg_user_preferences_updated_at
    BEFORE UPDATE ON auth_management.user_preferences
    FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- Row Level Security Policies
CREATE POLICY user_preferences_select_own ON auth_management.user_preferences
    FOR SELECT USING (user_id = gamilit.get_current_user_id());

CREATE POLICY user_preferences_select_admin ON auth_management.user_preferences
    FOR SELECT USING (gamilit.is_admin());

CREATE POLICY user_preferences_update_own ON auth_management.user_preferences
    FOR UPDATE USING (user_id = gamilit.get_current_user_id());

CREATE POLICY user_preferences_update_admin ON auth_management.user_preferences
    FOR UPDATE USING (gamilit.is_admin());

CREATE POLICY user_preferences_insert_own ON auth_management.user_preferences
    FOR INSERT WITH CHECK (user_id = gamilit.get_current_user_id());

-- Comments
COMMENT ON TABLE auth_management.user_preferences IS 'Preferencias personalizadas de cada usuario para la interfaz y experiencia de la aplicación';
COMMENT ON COLUMN auth_management.user_preferences.user_id IS 'ID del usuario (PK y FK a profiles)';
COMMENT ON COLUMN auth_management.user_preferences.theme IS 'Tema de la interfaz: light, dark, auto';
COMMENT ON COLUMN auth_management.user_preferences.language IS 'Idioma preferido: es (español), en (inglés)';
COMMENT ON COLUMN auth_management.user_preferences.notifications_enabled IS 'Habilitar notificaciones en la aplicación';
COMMENT ON COLUMN auth_management.user_preferences.email_notifications IS 'Habilitar notificaciones por correo electrónico';
COMMENT ON COLUMN auth_management.user_preferences.sound_enabled IS 'Habilitar efectos de sonido en la aplicación';
COMMENT ON COLUMN auth_management.user_preferences.tutorial_completed IS 'Indica si el usuario completó el tutorial inicial';
COMMENT ON COLUMN auth_management.user_preferences.preferences IS 'Preferencias adicionales en formato JSON (configuraciones personalizadas)';

-- Permissions
ALTER TABLE auth_management.user_preferences OWNER TO gamilit_user;
GRANT ALL ON TABLE auth_management.user_preferences TO gamilit_user;
