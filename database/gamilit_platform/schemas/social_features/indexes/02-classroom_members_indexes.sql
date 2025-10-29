-- =====================================================
-- Indexes for: social_features.classroom_members
-- Created: 2025-10-28
-- Description: Índices para optimización de membresías de aulas
-- =====================================================

-- ========================================
-- PERFORMANCE INDEXES - Created 2025-10-28
-- ========================================

-- Index: idx_classroom_members_student
-- Purpose: Optimiza búsquedas de aulas por estudiante y estado
-- Type: BTREE Composite
-- Impact: Acelera queries de "mis aulas" y gestión de membresías
-- Use Case: SELECT * FROM classroom_members WHERE student_id = ? AND status = 'active'
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_classroom_members_student
    ON social_features.classroom_members(student_id, status);

COMMENT ON INDEX social_features.idx_classroom_members_student IS
'Índice para búsquedas de aulas por estudiante y estado de membresía';

-- =====================================================
-- Performance Improvement Examples
-- =====================================================

/*
-- Get student's active classrooms (uses idx_classroom_members_student)
SELECT
    cm.classroom_id,
    cm.role,
    cm.joined_at,
    c.name as classroom_name
FROM social_features.classroom_members cm
JOIN social_features.classrooms c ON c.classroom_id = cm.classroom_id
WHERE cm.student_id = $1
  AND cm.status = 'active'
ORDER BY cm.joined_at DESC;

-- Check if student is member of classroom
SELECT EXISTS (
    SELECT 1
    FROM social_features.classroom_members
    WHERE student_id = $1
      AND classroom_id = $2
      AND status = 'active'
);

-- Count student's active classrooms
SELECT COUNT(*)
FROM social_features.classroom_members
WHERE student_id = $1
  AND status = 'active';

-- Get student's pending invitations
SELECT
    cm.classroom_id,
    cm.invited_at,
    c.name as classroom_name,
    c.description
FROM social_features.classroom_members cm
JOIN social_features.classrooms c ON c.classroom_id = cm.classroom_id
WHERE cm.student_id = $1
  AND cm.status = 'pending'
ORDER BY cm.invited_at DESC;

-- Student's classroom history (including inactive)
SELECT
    classroom_id,
    status,
    role,
    joined_at,
    left_at
FROM social_features.classroom_members
WHERE student_id = $1
ORDER BY joined_at DESC;

-- =====================================================
-- COMPLEMENTARY INDEX CONSIDERATION
-- =====================================================
-- Nota: Para queries frecuentes del tipo "miembros de un aula", considerar:
--
-- CREATE INDEX idx_classroom_members_classroom
--     ON social_features.classroom_members(classroom_id, status);
--
-- Este índice complementario optimizaría:
-- - Lista de estudiantes en un aula
-- - Conteo de miembros activos por aula
-- - Filtrado de estudiantes por rol en el aula
--
-- Sin embargo, no está incluido en 04-INDEXES.sql
-- El índice actual (student_id) prioriza la perspectiva del estudiante
*/
