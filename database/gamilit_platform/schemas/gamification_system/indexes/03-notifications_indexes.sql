-- =====================================================
-- Indexes for: gamification_system.notifications
-- Created: 2025-10-28
-- Description: Índices para optimización de consultas de notificaciones
-- =====================================================

-- ========================================
-- PARTIAL INDEXES - Created 2025-10-28
-- ========================================

-- Index: idx_notifications_user_unread
-- Purpose: Optimiza queries de notificaciones no leídas por usuario
-- Type: BTREE Partial Index (WHERE is_read = false)
-- Impact: Índice compacto que solo indexa notificaciones pendientes
-- Benefit: Reduce tamaño del índice al excluir notificaciones ya leídas
-- Use Case: SELECT * FROM notifications WHERE user_id = ? AND is_read = false
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_notifications_user_unread
    ON gamification_system.notifications(user_id, is_read)
    WHERE is_read = false;

COMMENT ON INDEX gamification_system.idx_notifications_user_unread IS
'Índice parcial para notificaciones no leídas por usuario (optimizado para queries de bandeja de entrada)';

-- =====================================================
-- Performance Improvement Examples
-- =====================================================

/*
-- Get unread notifications for user (uses idx_notifications_user_unread)
-- Este índice es especialmente eficiente porque:
-- 1. Solo indexa notificaciones no leídas (WHERE is_read = false)
-- 2. Mucho más pequeño que un índice completo
-- 3. Más rápido de mantener en INSERTs/UPDATEs

SELECT
    notification_id,
    user_id,
    type,
    title,
    message,
    created_at
FROM gamification_system.notifications
WHERE user_id = $1
  AND is_read = false
ORDER BY created_at DESC;

-- Get unread notification count (also uses partial index)
SELECT COUNT(*)
FROM gamification_system.notifications
WHERE user_id = $1
  AND is_read = false;

-- NOTA: Queries que filtran por is_read = true NO usarán este índice
-- (por diseño, ya que la mayoría de queries buscan notificaciones no leídas)
*/
