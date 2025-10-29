-- =====================================================
-- Enable RLS for social_features tables
-- Created: 2025-10-27
-- Updated: 2025-10-28 (Agent 3 - Comprehensive RLS Integration)
-- Description: Habilita Row Level Security en todas las
--              tablas del schema social_features
-- =====================================================

-- Enable Row Level Security on all social_features tables
-- Schema: social_features
-- Tables: 6 tables with RLS protection

ALTER TABLE social_features.schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_features.classrooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_features.classroom_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_features.friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_features.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_features.team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_features.team_challenges ENABLE ROW LEVEL SECURITY;

-- Comentarios
COMMENT ON TABLE social_features.schools IS 'RLS enabled: Escuelas con aislamiento por tenant';
COMMENT ON TABLE social_features.classrooms IS 'RLS enabled: Aulas con acceso por profesor/estudiante/admin';
COMMENT ON TABLE social_features.classroom_members IS 'RLS enabled: Miembros de aulas - gestión por profesor';
COMMENT ON TABLE social_features.friendships IS 'RLS enabled: Amistades - gestión propia';
COMMENT ON TABLE social_features.teams IS 'RLS enabled: Equipos de trabajo colaborativo';
COMMENT ON TABLE social_features.team_members IS 'RLS enabled: Miembros de equipos - visibilidad entre miembros';
COMMENT ON TABLE social_features.team_challenges IS 'RLS enabled: Desafíos de equipo - visibilidad para miembros';
