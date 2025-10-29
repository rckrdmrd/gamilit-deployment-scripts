-- =====================================================
-- Indexes for: social_features.schools
-- Created: 2025-10-28
-- Description: Índices para optimización de multi-tenancy y gestión de escuelas
-- =====================================================

-- ========================================
-- MULTI-TENANCY INDEXES - Created 2025-10-28
-- ========================================

-- Index: idx_schools_tenant
-- Purpose: Optimiza búsquedas de escuelas por tenant (multi-tenancy)
-- Type: BTREE Composite
-- Impact: Crítico para arquitectura multi-tenant, asegura aislamiento eficiente
-- Use Case: SELECT * FROM schools WHERE tenant_id = ? AND is_active = true
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_schools_tenant
    ON social_features.schools(tenant_id, is_active);

COMMENT ON INDEX social_features.idx_schools_tenant IS
'Índice para multi-tenancy - búsquedas de escuelas por tenant y estado activo';

-- =====================================================
-- Performance Improvement Examples
-- =====================================================

/*
-- Get all active schools for a tenant (uses idx_schools_tenant)
-- Este es el patrón más común en arquitecturas multi-tenant
SELECT
    school_id,
    name,
    address,
    contact_info,
    created_at
FROM social_features.schools
WHERE tenant_id = $1
  AND is_active = true
ORDER BY name;

-- Count active schools per tenant
SELECT COUNT(*)
FROM social_features.schools
WHERE tenant_id = $1
  AND is_active = true;

-- Check if school exists and is active
SELECT EXISTS (
    SELECT 1
    FROM social_features.schools
    WHERE school_id = $1
      AND tenant_id = $2
      AND is_active = true
);

-- Get tenant's school with specific criteria
SELECT
    school_id,
    name,
    type,
    level
FROM social_features.schools
WHERE tenant_id = $1
  AND is_active = true
  AND type = 'public'
ORDER BY name;

-- Audit: Get all schools (including inactive) for tenant
SELECT
    school_id,
    name,
    is_active,
    created_at,
    updated_at
FROM social_features.schools
WHERE tenant_id = $1
ORDER BY is_active DESC, created_at DESC;

-- =====================================================
-- MULTI-TENANCY BEST PRACTICES
-- =====================================================
-- Este índice es CRÍTICO porque:
--
-- 1. Row-Level Security (RLS):
--    Todas las queries incluyen WHERE tenant_id = current_tenant_id()
--    Sin este índice, RLS causaría escaneos completos de tabla
--
-- 2. Aislamiento de datos:
--    Asegura que queries de un tenant no afecten performance de otros
--
-- 3. Escalabilidad:
--    Permite que la tabla crezca con múltiples tenants sin degradación
--
-- 4. Filtro adicional por is_active:
--    La mayoría de queries solo necesitan escuelas activas
--    El índice compuesto optimiza ambas condiciones
--
-- NOTA: Siempre incluir tenant_id en queries, incluso si parece redundante
-- Es esencial para seguridad y performance en multi-tenant
*/
