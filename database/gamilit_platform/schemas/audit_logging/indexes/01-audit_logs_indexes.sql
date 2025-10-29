-- =====================================================
-- Indexes for: audit_logging.audit_logs
-- Created: 2025-10-28
-- Description: Índices para optimización de auditoría y búsquedas de logs
-- =====================================================

-- ========================================
-- PERFORMANCE INDEXES - Created 2025-10-28
-- ========================================

-- Index: idx_audit_logs_user_created
-- Purpose: Optimiza búsquedas de auditoría por usuario ordenadas por fecha
-- Type: BTREE Composite
-- Impact: Acelera queries de historial de actividad de usuario
-- Use Case: SELECT * FROM audit_logs WHERE user_id = ? ORDER BY created_at DESC
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_logs_user_created
    ON audit_logging.audit_logs(user_id, created_at DESC);

COMMENT ON INDEX audit_logging.idx_audit_logs_user_created IS
'Índice compuesto para historial de auditoría por usuario ordenado por fecha';

-- Index: idx_audit_logs_entity
-- Purpose: Optimiza búsquedas de auditoría por entidad específica
-- Type: BTREE Composite
-- Impact: Permite rastrear cambios en entidades específicas eficientemente
-- Use Case: SELECT * FROM audit_logs WHERE entity_type = 'user' AND entity_id = '123'
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_logs_entity
    ON audit_logging.audit_logs(entity_type, entity_id);

COMMENT ON INDEX audit_logging.idx_audit_logs_entity IS
'Índice compuesto para rastrear cambios por tipo y ID de entidad';

-- ========================================
-- TIME-SERIES INDEXES - BRIN for Analytics
-- ========================================

-- Index: idx_audit_logs_user_created_brin
-- Purpose: Índice BRIN para queries de reportes y analytics por rango de fechas
-- Type: BRIN (Block Range Index)
-- Impact: Muy eficiente para tablas grandes con datos ordenados por tiempo
-- Benefit: Ocupa muy poco espacio comparado con BTREE
-- Use Case: Reportes mensuales, análisis de tendencias temporales
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_logs_user_created_brin
    ON audit_logging.audit_logs USING brin(created_at);

COMMENT ON INDEX audit_logging.idx_audit_logs_user_created_brin IS
'Índice BRIN para queries de analytics por rango de fechas (optimizado para tablas grandes)';

-- Index: idx_audit_logs_action_date
-- Purpose: Optimiza búsquedas por tipo de acción ordenadas por fecha
-- Type: BTREE Composite
-- Impact: Acelera queries de auditoría filtradas por acción específica
-- Use Case: SELECT * FROM audit_logs WHERE action = 'LOGIN' ORDER BY created_at DESC
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_logs_action_date
    ON audit_logging.audit_logs(action, created_at DESC);

COMMENT ON INDEX audit_logging.idx_audit_logs_action_date IS
'Índice compuesto para filtrar por acción y ordenar por fecha';

-- =====================================================
-- Performance Improvement Examples
-- =====================================================

/*
-- User Activity History (uses idx_audit_logs_user_created)
SELECT
    action,
    entity_type,
    entity_id,
    changes,
    created_at
FROM audit_logging.audit_logs
WHERE user_id = $1
ORDER BY created_at DESC
LIMIT 50;

-- Track changes to specific entity (uses idx_audit_logs_entity)
SELECT
    user_id,
    action,
    changes,
    created_at
FROM audit_logging.audit_logs
WHERE entity_type = 'achievement'
  AND entity_id = $1
ORDER BY created_at DESC;

-- Monthly activity report (uses idx_audit_logs_user_created_brin)
-- BRIN es ideal para este tipo de queries porque:
-- 1. Los datos están naturalmente ordenados por created_at
-- 2. Queries escanean rangos de fechas grandes
-- 3. El índice ocupa muy poco espacio
SELECT
    DATE_TRUNC('day', created_at) as day,
    COUNT(*) as total_actions,
    COUNT(DISTINCT user_id) as unique_users
FROM audit_logging.audit_logs
WHERE created_at >= '2025-10-01'
  AND created_at < '2025-11-01'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY day;

-- Filter by action type (uses idx_audit_logs_action_date)
SELECT
    user_id,
    entity_type,
    entity_id,
    created_at
FROM audit_logging.audit_logs
WHERE action = 'UPDATE'
ORDER BY created_at DESC
LIMIT 100;

-- =====================================================
-- BRIN vs BTREE: Cuándo usar cada uno
-- =====================================================
-- BTREE (idx_audit_logs_user_created):
--   - Búsquedas exactas por usuario
--   - Queries que retornan pocas filas
--   - Necesitas el resultado ordenado
--
-- BRIN (idx_audit_logs_user_created_brin):
--   - Reportes y analytics por rango de fechas
--   - Queries que escanean muchas filas
--   - Tablas muy grandes (millones de filas)
--   - Datos naturalmente ordenados por tiempo
*/
