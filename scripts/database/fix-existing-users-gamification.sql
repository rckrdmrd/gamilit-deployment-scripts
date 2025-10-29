-- =====================================================
-- Script: Corregir Gamificación de Usuarios Existentes
-- Descripción: Inicializa stats y ranks para usuarios que fueron
--              creados antes de corregir el trigger
-- Fecha: 2025-10-28
-- =====================================================

-- Este script inicializa la gamificación para usuarios estudiantes
-- que no tienen user_stats o user_ranks

BEGIN;

-- Mostrar usuarios sin inicializar
SELECT
    u.id,
    u.email,
    u.created_at,
    CASE WHEN us.id IS NULL THEN '❌ Missing' ELSE '✓ OK' END as user_stats,
    CASE WHEN ur.id IS NULL THEN '❌ Missing' ELSE '✓ OK' END as user_ranks,
    CASE WHEN ci.id IS NULL THEN '❌ Missing' ELSE '✓ OK' END as comodines
FROM auth.users u
JOIN auth_management.profiles p ON u.id = p.user_id
LEFT JOIN gamification_system.user_stats us ON u.id = us.user_id
LEFT JOIN gamification_system.user_ranks ur ON u.id = ur.user_id AND ur.is_current = true
LEFT JOIN gamification_system.comodines_inventory ci ON u.id = ci.user_id
WHERE p.role = 'student'
  AND u.deleted_at IS NULL
ORDER BY u.created_at;

-- Crear user_stats para usuarios que no lo tienen
INSERT INTO gamification_system.user_stats (
    user_id,
    tenant_id,
    ml_coins,
    ml_coins_earned_total
)
SELECT
    u.id,
    p.tenant_id,
    100,  -- Welcome bonus
    100
FROM auth.users u
JOIN auth_management.profiles p ON u.id = p.user_id
LEFT JOIN gamification_system.user_stats us ON u.id = us.user_id
WHERE p.role = 'student'
  AND u.deleted_at IS NULL
  AND us.id IS NULL
ON CONFLICT (user_id) DO NOTHING;

-- Crear comodines_inventory para usuarios que no lo tienen
INSERT INTO gamification_system.comodines_inventory (user_id)
SELECT u.id
FROM auth.users u
JOIN auth_management.profiles p ON u.id = p.user_id
LEFT JOIN gamification_system.comodines_inventory ci ON u.id = ci.user_id
WHERE p.role = 'student'
  AND u.deleted_at IS NULL
  AND ci.id IS NULL
ON CONFLICT (user_id) DO NOTHING;

-- Crear user_ranks para usuarios que no lo tienen
INSERT INTO gamification_system.user_ranks (
    user_id,
    tenant_id,
    current_rank
)
SELECT
    u.id,
    p.tenant_id,
    'MERCENARIO'::maya_rank
FROM auth.users u
JOIN auth_management.profiles p ON u.id = p.user_id
LEFT JOIN gamification_system.user_ranks ur ON u.id = ur.user_id AND ur.is_current = true
WHERE p.role = 'student'
  AND u.deleted_at IS NULL
  AND ur.id IS NULL;

-- Mostrar resumen de usuarios corregidos
SELECT
    COUNT(*) as total_students,
    COUNT(DISTINCT us.user_id) as with_stats,
    COUNT(DISTINCT ur.user_id) as with_ranks,
    COUNT(DISTINCT ci.user_id) as with_comodines
FROM auth.users u
JOIN auth_management.profiles p ON u.id = p.user_id
LEFT JOIN gamification_system.user_stats us ON u.id = us.user_id
LEFT JOIN gamification_system.user_ranks ur ON u.id = ur.user_id AND ur.is_current = true
LEFT JOIN gamification_system.comodines_inventory ci ON u.id = ci.user_id
WHERE p.role = 'student'
  AND u.deleted_at IS NULL;

COMMIT;

-- Verificación final
SELECT
    u.email,
    us.level,
    us.total_xp,
    us.ml_coins,
    ur.current_rank,
    CASE WHEN ci.id IS NOT NULL THEN '✓' ELSE '❌' END as comodines
FROM auth.users u
JOIN auth_management.profiles p ON u.id = p.user_id
LEFT JOIN gamification_system.user_stats us ON u.id = us.user_id
LEFT JOIN gamification_system.user_ranks ur ON u.id = ur.user_id AND ur.is_current = true
LEFT JOIN gamification_system.comodines_inventory ci ON u.id = ci.user_id
WHERE p.role = 'student'
  AND u.deleted_at IS NULL
ORDER BY u.created_at;
