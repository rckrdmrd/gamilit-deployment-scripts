-- =====================================================
-- Seed Data: system_configuration.feature_flags
-- Description: Feature flags para control de funcionalidades del sistema GAMILIT
-- Records: 0 (Tabla vacía - Template para futuras feature flags)
-- Created: 2025-10-27
-- =====================================================

SET search_path TO system_configuration, public;

-- =====================================================
-- TRUNCATE TABLE (Usar con precaución en producción)
-- =====================================================
-- TRUNCATE TABLE system_configuration.feature_flags RESTART IDENTITY CASCADE;

-- =====================================================
-- ESTRUCTURA DE INSERCIÓN
-- =====================================================
-- Ejemplo de feature flag (comentado - adaptar según necesidades):
/*
INSERT INTO system_configuration.feature_flags (
    id,
    tenant_id,
    feature_name,
    feature_key,
    description,
    is_enabled,
    rollout_percentage,
    target_users,
    target_roles,
    target_conditions,
    starts_at,
    ends_at,
    metadata,
    created_by,
    updated_by,
    created_at,
    updated_at
) VALUES
    (
        gen_random_uuid(),                          -- id
        NULL,                                       -- tenant_id (NULL para feature flag global)
        'Nueva Interfaz de Dashboard',             -- feature_name
        'feature.dashboard.new_ui',                -- feature_key (UNIQUE)
        'Activa la nueva interfaz del dashboard con mejoras de UX',  -- description
        true,                                       -- is_enabled
        50,                                         -- rollout_percentage (0-100)
        NULL,                                       -- target_users (uuid[]) - array de UUIDs
        ARRAY['admin'::gamilit_role, 'manager'::gamilit_role],  -- target_roles (gamilit_role[])
        '{
            "min_account_age_days": 30,
            "beta_tester": true
        }'::jsonb,                                  -- target_conditions (JSONB)
        '2025-01-01 00:00:00-06'::timestamptz,     -- starts_at
        '2025-12-31 23:59:59-06'::timestamptz,     -- ends_at
        '{
            "version": "2.0",
            "jira_ticket": "GLIT-1234",
            "owner": "equipo-frontend"
        }'::jsonb,                                  -- metadata (JSONB)
        NULL,                                       -- created_by
        NULL,                                       -- updated_by
        CURRENT_TIMESTAMP,                          -- created_at
        CURRENT_TIMESTAMP                           -- updated_at
    )
ON CONFLICT (feature_key) DO UPDATE SET
    feature_name = EXCLUDED.feature_name,
    description = EXCLUDED.description,
    is_enabled = EXCLUDED.is_enabled,
    rollout_percentage = EXCLUDED.rollout_percentage,
    target_users = EXCLUDED.target_users,
    target_roles = EXCLUDED.target_roles,
    target_conditions = EXCLUDED.target_conditions,
    starts_at = EXCLUDED.starts_at,
    ends_at = EXCLUDED.ends_at,
    metadata = EXCLUDED.metadata,
    updated_by = EXCLUDED.updated_by,
    updated_at = CURRENT_TIMESTAMP;
*/

-- =====================================================
-- ROLES DISPONIBLES (enum gamilit_role)
-- =====================================================
-- • admin           - Administrador del sistema
-- • manager         - Gerente/Manager
-- • supervisor      - Supervisor
-- • employee        - Empleado
-- • viewer          - Visor (solo lectura)
-- • external        - Usuario externo

-- =====================================================
-- EJEMPLOS DE FEATURE FLAGS COMUNES
-- =====================================================

/*
-- Feature Flag: Nueva funcionalidad de gamificación
INSERT INTO system_configuration.feature_flags (
    feature_name,
    feature_key,
    description,
    is_enabled,
    rollout_percentage,
    target_roles,
    metadata
) VALUES
    (
        'Sistema de Achievements',
        'feature.gamification.achievements',
        'Habilita el nuevo sistema de logros y achievements',
        true,
        100,
        ARRAY['admin'::gamilit_role, 'manager'::gamilit_role, 'employee'::gamilit_role],
        '{
            "jira": "GLIT-5678",
            "release": "v2.1.0"
        }'::jsonb
    )
ON CONFLICT (feature_key) DO UPDATE SET
    is_enabled = EXCLUDED.is_enabled,
    rollout_percentage = EXCLUDED.rollout_percentage,
    updated_at = CURRENT_TIMESTAMP;

-- Feature Flag: Beta testing con usuarios específicos
INSERT INTO system_configuration.feature_flags (
    feature_name,
    feature_key,
    description,
    is_enabled,
    rollout_percentage,
    target_users,
    target_conditions,
    starts_at,
    ends_at
) VALUES
    (
        'Reportes Avanzados Beta',
        'feature.reports.advanced_beta',
        'Acceso beta a reportes avanzados para usuarios seleccionados',
        true,
        0,  -- 0% de rollout general
        ARRAY[
            '11111111-1111-1111-1111-111111111111'::uuid,
            '22222222-2222-2222-2222-222222222222'::uuid
        ],  -- Lista específica de usuarios beta
        '{
            "beta_tester": true,
            "department": ["IT", "Management"]
        }'::jsonb,
        '2025-02-01 00:00:00-06'::timestamptz,
        '2025-03-31 23:59:59-06'::timestamptz
    )
ON CONFLICT (feature_key) DO UPDATE SET
    is_enabled = EXCLUDED.is_enabled,
    target_users = EXCLUDED.target_users,
    updated_at = CURRENT_TIMESTAMP;

-- Feature Flag: Rollout gradual (canary deployment)
INSERT INTO system_configuration.feature_flags (
    feature_name,
    feature_key,
    description,
    is_enabled,
    rollout_percentage
) VALUES
    (
        'Nueva API de Notificaciones',
        'feature.api.notifications_v2',
        'Migración gradual a la nueva API de notificaciones',
        true,
        25  -- Activar para 25% de usuarios
    )
ON CONFLICT (feature_key) DO UPDATE SET
    rollout_percentage = EXCLUDED.rollout_percentage,
    updated_at = CURRENT_TIMESTAMP;

-- Feature Flag: Feature temporaria/experimental
INSERT INTO system_configuration.feature_flags (
    feature_name,
    feature_key,
    description,
    is_enabled,
    starts_at,
    ends_at,
    metadata
) VALUES
    (
        'Promoción de Fin de Año',
        'feature.promo.end_of_year_2025',
        'Feature flag para promoción especial de fin de año',
        true,
        '2025-12-01 00:00:00-06'::timestamptz,
        '2025-12-31 23:59:59-06'::timestamptz,
        '{
            "promo_code": "EOY2025",
            "discount_percentage": 20
        }'::jsonb
    )
ON CONFLICT (feature_key) DO UPDATE SET
    is_enabled = EXCLUDED.is_enabled,
    starts_at = EXCLUDED.starts_at,
    ends_at = EXCLUDED.ends_at,
    updated_at = CURRENT_TIMESTAMP;

-- Feature Flag: Solo para administradores
INSERT INTO system_configuration.feature_flags (
    feature_name,
    feature_key,
    description,
    is_enabled,
    rollout_percentage,
    target_roles
) VALUES
    (
        'Panel de Debug',
        'feature.admin.debug_panel',
        'Panel de debugging solo para administradores',
        true,
        100,
        ARRAY['admin'::gamilit_role]
    )
ON CONFLICT (feature_key) DO UPDATE SET
    is_enabled = EXCLUDED.is_enabled,
    updated_at = CURRENT_TIMESTAMP;
*/

-- =====================================================
-- ESTRATEGIAS DE ROLLOUT
-- =====================================================
-- 1. ROLLOUT COMPLETO
--    is_enabled = true, rollout_percentage = 100
--
-- 2. ROLLOUT GRADUAL (Canary)
--    is_enabled = true, rollout_percentage = 10 (incrementar gradualmente)
--
-- 3. USUARIOS ESPECÍFICOS
--    is_enabled = true, rollout_percentage = 0, target_users = [UUID array]
--
-- 4. ROLES ESPECÍFICOS
--    is_enabled = true, target_roles = [roles array]
--
-- 5. FEATURE TEMPORARIA
--    is_enabled = true, starts_at = fecha_inicio, ends_at = fecha_fin
--
-- 6. CONDICIONES AVANZADAS
--    target_conditions = {"criteria": "value"}

-- =====================================================
-- CAMPOS IMPORTANTES
-- =====================================================
-- • feature_key: ÚNICO, usar nomenclatura feature.categoria.nombre
-- • is_enabled: Activa/desactiva el feature flag
-- • rollout_percentage: 0-100, porcentaje de usuarios que verán la feature
-- • target_users: Array de UUIDs para usuarios específicos
-- • target_roles: Array de roles (gamilit_role[])
-- • target_conditions: JSONB con condiciones personalizadas
-- • starts_at/ends_at: Ventana temporal de activación
-- • metadata: JSONB con información adicional (tickets, versiones, etc.)

-- =====================================================
-- VALIDACIONES
-- =====================================================
-- • rollout_percentage debe estar entre 0 y 100
-- • feature_key debe ser único
-- • created_at/updated_at se manejan automáticamente

-- =====================================================
-- CONSULTAS ÚTILES
-- =====================================================
/*
-- Ver feature flags activos
SELECT feature_key, feature_name, is_enabled, rollout_percentage
FROM system_configuration.feature_flags
WHERE is_enabled = true
  AND (starts_at IS NULL OR starts_at <= CURRENT_TIMESTAMP)
  AND (ends_at IS NULL OR ends_at >= CURRENT_TIMESTAMP);

-- Ver feature flags para un rol específico
SELECT feature_key, feature_name, target_roles
FROM system_configuration.feature_flags
WHERE is_enabled = true
  AND 'admin'::gamilit_role = ANY(target_roles);

-- Ver feature flags temporarias activas
SELECT feature_key, feature_name, starts_at, ends_at
FROM system_configuration.feature_flags
WHERE is_enabled = true
  AND starts_at IS NOT NULL
  AND ends_at IS NOT NULL
  AND starts_at <= CURRENT_TIMESTAMP
  AND ends_at >= CURRENT_TIMESTAMP;
*/

-- =====================================================
-- FIN DEL ARCHIVO
-- =====================================================
