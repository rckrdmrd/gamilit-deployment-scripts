-- =====================================================
-- Seed Data: system_configuration.system_settings
-- Description: Configuraciones globales del sistema GAMILIT
-- Records: 0 (Tabla vacía - Template para futuras configuraciones)
-- Created: 2025-10-27
-- =====================================================

SET search_path TO system_configuration, public;

-- =====================================================
-- TRUNCATE TABLE (Usar con precaución en producción)
-- =====================================================
-- TRUNCATE TABLE system_configuration.system_settings RESTART IDENTITY CASCADE;

-- =====================================================
-- ESTRUCTURA DE INSERCIÓN
-- =====================================================
-- Ejemplo de configuración (comentado - adaptar según necesidades):
/*
INSERT INTO system_configuration.system_settings (
    id,
    tenant_id,
    setting_key,
    setting_category,
    setting_subcategory,
    setting_value,
    value_type,
    default_value,
    display_name,
    description,
    help_text,
    is_public,
    is_readonly,
    is_system,
    requires_restart,
    validation_rules,
    allowed_values,
    min_value,
    max_value,
    metadata,
    created_by,
    updated_by,
    created_at,
    updated_at
) VALUES
    (
        gen_random_uuid(),                          -- id
        NULL,                                       -- tenant_id (NULL para configuración global)
        'app.name',                                 -- setting_key (UNIQUE)
        'general',                                  -- setting_category
        'application',                              -- setting_subcategory
        'GAMILIT Platform',                         -- setting_value
        'string',                                   -- value_type
        'GAMILIT',                                  -- default_value
        'Nombre de la Aplicación',                 -- display_name
        'Nombre público de la plataforma',         -- description
        'Este nombre se muestra en el frontend',   -- help_text
        true,                                       -- is_public
        false,                                      -- is_readonly
        true,                                       -- is_system
        false,                                      -- requires_restart
        '{"min_length": 3, "max_length": 100}'::jsonb,  -- validation_rules (JSONB)
        NULL,                                       -- allowed_values (text[])
        NULL,                                       -- min_value
        NULL,                                       -- max_value
        '{"version": "1.0", "last_reviewed": "2025-10-27"}'::jsonb,  -- metadata (JSONB)
        NULL,                                       -- created_by
        NULL,                                       -- updated_by
        CURRENT_TIMESTAMP,                          -- created_at
        CURRENT_TIMESTAMP                           -- updated_at
    )
ON CONFLICT (setting_key) DO UPDATE SET
    setting_value = EXCLUDED.setting_value,
    setting_category = EXCLUDED.setting_category,
    setting_subcategory = EXCLUDED.setting_subcategory,
    value_type = EXCLUDED.value_type,
    default_value = EXCLUDED.default_value,
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    help_text = EXCLUDED.help_text,
    is_public = EXCLUDED.is_public,
    is_readonly = EXCLUDED.is_readonly,
    is_system = EXCLUDED.is_system,
    requires_restart = EXCLUDED.requires_restart,
    validation_rules = EXCLUDED.validation_rules,
    allowed_values = EXCLUDED.allowed_values,
    min_value = EXCLUDED.min_value,
    max_value = EXCLUDED.max_value,
    metadata = EXCLUDED.metadata,
    updated_by = EXCLUDED.updated_by,
    updated_at = CURRENT_TIMESTAMP;
*/

-- =====================================================
-- CATEGORÍAS DE CONFIGURACIÓN DISPONIBLES
-- =====================================================
-- • general       - Configuraciones generales del sistema
-- • gamification  - Configuraciones de gamificación
-- • security      - Configuraciones de seguridad
-- • email         - Configuraciones de correo electrónico
-- • storage       - Configuraciones de almacenamiento
-- • analytics     - Configuraciones de analíticas
-- • integrations  - Configuraciones de integraciones

-- =====================================================
-- TIPOS DE VALOR DISPONIBLES
-- =====================================================
-- • string   - Cadena de texto
-- • number   - Valor numérico
-- • boolean  - Valor booleano (true/false)
-- • json     - Objeto JSON
-- • array    - Array de valores

-- =====================================================
-- EJEMPLOS DE CONFIGURACIONES COMUNES
-- =====================================================

/*
-- Configuración de gamificación
INSERT INTO system_configuration.system_settings (
    setting_key,
    setting_category,
    setting_value,
    value_type,
    display_name,
    description,
    is_system,
    validation_rules
) VALUES
    (
        'gamification.points_multiplier',
        'gamification',
        '1.5',
        'number',
        'Multiplicador de Puntos',
        'Factor de multiplicación para puntos ganados',
        true,
        '{"min": 0.1, "max": 10.0}'::jsonb
    )
ON CONFLICT (setting_key) DO UPDATE SET
    setting_value = EXCLUDED.setting_value,
    updated_at = CURRENT_TIMESTAMP;

-- Configuración de seguridad
INSERT INTO system_configuration.system_settings (
    setting_key,
    setting_category,
    setting_value,
    value_type,
    display_name,
    description,
    is_system,
    validation_rules
) VALUES
    (
        'security.session_timeout',
        'security',
        '3600',
        'number',
        'Timeout de Sesión',
        'Tiempo de inactividad en segundos antes de cerrar sesión',
        true,
        '{"min": 300, "max": 86400}'::jsonb
    )
ON CONFLICT (setting_key) DO UPDATE SET
    setting_value = EXCLUDED.setting_value,
    updated_at = CURRENT_TIMESTAMP;

-- Configuración con array
INSERT INTO system_configuration.system_settings (
    setting_key,
    setting_category,
    setting_value,
    value_type,
    display_name,
    description,
    allowed_values,
    is_system
) VALUES
    (
        'general.supported_locales',
        'general',
        'es-MX',
        'string',
        'Idiomas Soportados',
        'Idiomas disponibles en la plataforma',
        ARRAY['es-MX', 'en-US', 'pt-BR'],
        true
    )
ON CONFLICT (setting_key) DO UPDATE SET
    setting_value = EXCLUDED.setting_value,
    updated_at = CURRENT_TIMESTAMP;
*/

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================
-- 1. setting_key debe ser ÚNICO en toda la tabla
-- 2. validation_rules y metadata son columnas JSONB
-- 3. allowed_values es un array de texto (text[])
-- 4. Usar ON CONFLICT para actualizaciones idempotentes
-- 5. is_system=true indica configuraciones críticas del sistema
-- 6. requires_restart=true indica que cambios requieren reinicio
-- 7. created_at/updated_at se manejan automáticamente con triggers

-- =====================================================
-- FIN DEL ARCHIVO
-- =====================================================
