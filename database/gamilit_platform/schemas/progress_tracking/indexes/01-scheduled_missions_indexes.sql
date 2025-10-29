-- =====================================================
-- Indexes: progress_tracking.scheduled_missions
-- Description: Índices para optimizar consultas de misiones programadas
-- Table: progress_tracking.scheduled_missions
-- Created: 2025-10-28
-- =====================================================

-- Index: Misiones por mission_id
CREATE INDEX IF NOT EXISTS idx_scheduled_missions_mission
    ON progress_tracking.scheduled_missions(mission_id);

-- Index: Misiones por classroom_id
CREATE INDEX IF NOT EXISTS idx_scheduled_missions_classroom
    ON progress_tracking.scheduled_missions(classroom_id);

-- Index: Misiones programadas por usuario
CREATE INDEX IF NOT EXISTS idx_scheduled_missions_scheduled_by
    ON progress_tracking.scheduled_missions(scheduled_by);

-- Index: Misiones por rango de fechas (solo activas)
CREATE INDEX IF NOT EXISTS idx_scheduled_missions_dates
    ON progress_tracking.scheduled_missions(starts_at, ends_at)
    WHERE is_active = true;

-- Index: Misiones activas por fecha de inicio
CREATE INDEX IF NOT EXISTS idx_scheduled_missions_active
    ON progress_tracking.scheduled_missions(is_active, starts_at)
    WHERE is_active = true;

-- Index: Misiones activas por aula
CREATE INDEX IF NOT EXISTS idx_scheduled_missions_classroom_active
    ON progress_tracking.scheduled_missions(classroom_id, is_active)
    WHERE is_active = true;

-- Comments
COMMENT ON INDEX progress_tracking.idx_scheduled_missions_mission IS 'Índice para buscar todas las programaciones de una misión';
COMMENT ON INDEX progress_tracking.idx_scheduled_missions_classroom IS 'Índice para buscar todas las misiones programadas en un aula';
COMMENT ON INDEX progress_tracking.idx_scheduled_missions_scheduled_by IS 'Índice para buscar misiones programadas por un profesor';
COMMENT ON INDEX progress_tracking.idx_scheduled_missions_dates IS 'Índice parcial para consultas por rango de fechas (solo activas)';
COMMENT ON INDEX progress_tracking.idx_scheduled_missions_active IS 'Índice para filtrar misiones activas ordenadas por inicio';
COMMENT ON INDEX progress_tracking.idx_scheduled_missions_classroom_active IS 'Índice compuesto para misiones activas de un aula';
