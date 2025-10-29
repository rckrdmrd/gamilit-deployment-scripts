-- =====================================================
-- Indexes for: auth_management.user_sessions
-- Created: 2025-10-28
-- Description: Índices para optimización de gestión de sesiones activas
-- =====================================================

-- ========================================
-- PARTIAL INDEXES - Created 2025-10-28
-- ========================================

-- Index: idx_user_sessions_active
-- Purpose: Optimiza búsquedas de sesiones activas por usuario
-- Type: BTREE Partial Index (WHERE is_active = true)
-- Impact: Índice compacto para validación de sesiones y control de acceso
-- Benefit: Excluye sesiones expiradas/cerradas del índice (mucho más eficiente)
-- Use Case: SELECT * FROM user_sessions WHERE user_id = ? AND is_active = true
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_sessions_active
    ON auth_management.user_sessions(user_id, expires_at)
    WHERE is_active = true;

COMMENT ON INDEX auth_management.idx_user_sessions_active IS
'Índice parcial para sesiones activas por usuario (optimizado para validación de sesiones)';

-- =====================================================
-- Performance Improvement Examples
-- =====================================================

/*
-- Get user's active sessions (uses idx_user_sessions_active)
-- Este es el caso de uso más frecuente en validación de sesiones
SELECT
    session_id,
    device_info,
    ip_address,
    created_at,
    expires_at
FROM auth_management.user_sessions
WHERE user_id = $1
  AND is_active = true
ORDER BY created_at DESC;

-- Validate specific session (uses idx_user_sessions_active)
SELECT EXISTS (
    SELECT 1
    FROM auth_management.user_sessions
    WHERE session_id = $1
      AND user_id = $2
      AND is_active = true
      AND expires_at > NOW()
);

-- Check for expired sessions to cleanup
-- NOTA: Esta query NO usa el índice parcial porque is_active puede ser cualquier valor
-- Para esta operación periódica, considerar índice adicional o escaneo por lotes
SELECT
    session_id,
    user_id
FROM auth_management.user_sessions
WHERE is_active = true
  AND expires_at < NOW()
LIMIT 1000;

-- Count active sessions per user
SELECT COUNT(*)
FROM auth_management.user_sessions
WHERE user_id = $1
  AND is_active = true;

-- Get active sessions expiring soon (uses idx_user_sessions_active)
SELECT
    user_id,
    session_id,
    expires_at
FROM auth_management.user_sessions
WHERE user_id = $1
  AND is_active = true
  AND expires_at BETWEEN NOW() AND NOW() + INTERVAL '1 hour'
ORDER BY expires_at;

-- =====================================================
-- PARTIAL INDEX BENEFITS
-- =====================================================
-- Este índice parcial es especialmente eficiente porque:
--
-- 1. Tamaño reducido:
--    Solo indexa sesiones activas (típicamente <5% del total)
--    Sesiones cerradas/expiradas no ocupan espacio en el índice
--
-- 2. Mantenimiento rápido:
--    - INSERT: Solo actualiza índice si is_active = true
--    - UPDATE: Solo afecta índice al cambiar is_active
--    - DELETE: Impacto mínimo en índice
--
-- 3. Cache eficiente:
--    Índice más pequeño = mejor aprovechamiento de RAM
--
-- 4. Caso de uso alineado:
--    >95% de queries buscan sesiones activas
--    Raramente se consultan sesiones cerradas/expiradas
--
-- 5. Columnas incluidas:
--    - user_id: Para encontrar sesiones del usuario
--    - expires_at: Para validar expiración sin acceder a la tabla
--
-- =====================================================
-- CLEANUP STRATEGY
-- =====================================================
-- Para limpieza de sesiones expiradas, considerar:
--
-- 1. Job periódico (cada hora):
--    UPDATE user_sessions
--    SET is_active = false
--    WHERE is_active = true
--      AND expires_at < NOW()
--    LIMIT 1000;
--
-- 2. Particionamiento por fecha (avanzado):
--    Particionar tabla por created_at
--    DROP particiones antiguas completas
--
-- 3. Archivado (opcional):
--    Mover sesiones antiguas a tabla de histórico
--    Mantener tabla principal con solo últimos 30-90 días
*/
