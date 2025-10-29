-- =====================================================
-- Table: progress_tracking.scheduled_missions
-- Description: Misiones programadas para aulas específicas con fechas y bonificaciones
-- Dependencies: auth_management.profiles
-- Created: 2025-10-28
-- Modified: 2025-10-28
-- =====================================================

SET search_path TO progress_tracking, public;

DROP TABLE IF EXISTS progress_tracking.scheduled_missions CASCADE;

CREATE TABLE IF NOT EXISTS progress_tracking.scheduled_missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mission_id UUID NOT NULL,
    classroom_id UUID NOT NULL,
    scheduled_by UUID NOT NULL REFERENCES auth_management.profiles(id),
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN DEFAULT true,
    bonus_xp INTEGER DEFAULT 0,
    bonus_coins INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT chk_mission_dates CHECK (ends_at > starts_at),
    CONSTRAINT chk_bonus_xp CHECK (bonus_xp >= 0),
    CONSTRAINT chk_bonus_coins CHECK (bonus_coins >= 0)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_scheduled_missions_mission
    ON progress_tracking.scheduled_missions(mission_id);

CREATE INDEX IF NOT EXISTS idx_scheduled_missions_classroom
    ON progress_tracking.scheduled_missions(classroom_id);

CREATE INDEX IF NOT EXISTS idx_scheduled_missions_scheduled_by
    ON progress_tracking.scheduled_missions(scheduled_by);

CREATE INDEX IF NOT EXISTS idx_scheduled_missions_dates
    ON progress_tracking.scheduled_missions(starts_at, ends_at)
    WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_scheduled_missions_active
    ON progress_tracking.scheduled_missions(is_active, starts_at)
    WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_scheduled_missions_classroom_active
    ON progress_tracking.scheduled_missions(classroom_id, is_active)
    WHERE is_active = true;

-- Comments
COMMENT ON TABLE progress_tracking.scheduled_missions IS 'Misiones programadas para aulas específicas con fechas de inicio/fin y bonificaciones opcionales';
COMMENT ON COLUMN progress_tracking.scheduled_missions.mission_id IS 'ID de la misión programada';
COMMENT ON COLUMN progress_tracking.scheduled_missions.classroom_id IS 'ID del aula donde se programa la misión';
COMMENT ON COLUMN progress_tracking.scheduled_missions.scheduled_by IS 'Usuario (profesor) que programó la misión';
COMMENT ON COLUMN progress_tracking.scheduled_missions.starts_at IS 'Fecha y hora de inicio de la misión';
COMMENT ON COLUMN progress_tracking.scheduled_missions.ends_at IS 'Fecha y hora de finalización de la misión';
COMMENT ON COLUMN progress_tracking.scheduled_missions.is_active IS 'Indica si la misión programada está activa';
COMMENT ON COLUMN progress_tracking.scheduled_missions.bonus_xp IS 'Puntos de experiencia adicionales otorgados al completar';
COMMENT ON COLUMN progress_tracking.scheduled_missions.bonus_coins IS 'ML Coins adicionales otorgadas al completar';

-- Permissions
ALTER TABLE progress_tracking.scheduled_missions OWNER TO postgres;
GRANT ALL ON TABLE progress_tracking.scheduled_missions TO gamilit_user;
