-- =====================================================
-- Indexes for: social_features.friendships
-- Created: 2025-10-28
-- Description: Índices para optimización de relaciones de amistad
-- =====================================================

-- ========================================
-- BIDIRECTIONAL FRIENDSHIP INDEXES
-- ========================================

-- Index: idx_friendships_user1_status
-- Purpose: Optimiza búsquedas de amistades iniciadas por el usuario
-- Type: BTREE Composite
-- Impact: Acelera queries de lista de amigos y solicitudes enviadas
-- Use Case: SELECT * FROM friendships WHERE user_id = ? AND status = 'accepted'
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_friendships_user1_status
    ON social_features.friendships(user_id, status);

COMMENT ON INDEX social_features.idx_friendships_user1_status IS
'Índice para búsquedas de amistades por usuario iniciador y estado';

-- Index: idx_friendships_user2_status
-- Purpose: Optimiza búsquedas de amistades recibidas por el usuario
-- Type: BTREE Composite
-- Impact: Acelera queries de solicitudes de amistad pendientes recibidas
-- Use Case: SELECT * FROM friendships WHERE friend_id = ? AND status = 'pending'
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_friendships_user2_status
    ON social_features.friendships(friend_id, status);

COMMENT ON INDEX social_features.idx_friendships_user2_status IS
'Índice para búsquedas de amistades por usuario receptor y estado';

-- =====================================================
-- Performance Improvement Examples
-- =====================================================

/*
-- Get user's friends list (uses idx_friendships_user1_status)
SELECT
    friend_id,
    created_at
FROM social_features.friendships
WHERE user_id = $1
  AND status = 'accepted'
ORDER BY created_at DESC;

-- Get pending friend requests received (uses idx_friendships_user2_status)
-- Este es el caso de uso más importante para idx_friendships_user2_status
SELECT
    user_id,
    created_at
FROM social_features.friendships
WHERE friend_id = $1
  AND status = 'pending'
ORDER BY created_at DESC;

-- Check if two users are friends (bidirectional search)
-- Esta query usará ambos índices eficientemente
SELECT EXISTS (
    SELECT 1
    FROM social_features.friendships
    WHERE (
        (user_id = $1 AND friend_id = $2)
        OR (user_id = $2 AND friend_id = $1)
    )
    AND status = 'accepted'
);

-- Count user's friends (uses idx_friendships_user1_status)
SELECT COUNT(*)
FROM social_features.friendships
WHERE user_id = $1
  AND status = 'accepted';

-- Get all friendship activity for user (uses both indexes)
-- Postgres elegirá automáticamente el índice más apropiado
SELECT
    CASE
        WHEN user_id = $1 THEN 'sent'
        ELSE 'received'
    END as direction,
    CASE
        WHEN user_id = $1 THEN friend_id
        ELSE user_id
    END as other_user_id,
    status,
    created_at
FROM social_features.friendships
WHERE user_id = $1 OR friend_id = $1
ORDER BY created_at DESC;

-- =====================================================
-- INDEX STRATEGY EXPLANATION
-- =====================================================
-- Por qué necesitamos DOS índices:
--
-- 1. Relaciones bidireccionales: Una amistad puede ser almacenada como:
--    (user_id=A, friend_id=B) o (user_id=B, friend_id=A)
--
-- 2. Diferentes patrones de búsqueda:
--    - idx_friendships_user1_status: Para "amigos que agregué"
--    - idx_friendships_user2_status: Para "solicitudes que recibí"
--
-- 3. Ambos índices son necesarios para cubrir todas las queries eficientemente
--
-- 4. Sin estos índices, queries como "solicitudes pendientes recibidas"
--    requerirían escaneo completo de la tabla
*/
