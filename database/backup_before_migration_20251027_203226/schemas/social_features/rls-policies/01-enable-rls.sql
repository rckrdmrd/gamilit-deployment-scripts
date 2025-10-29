-- =====================================================
-- Enable RLS for social_features tables
-- Created: 2025-10-27
-- Description: Habilita Row Level Security en todas las
--              tablas del schema social_features
-- =====================================================

-- Tablas con RLS habilitado
ALTER TABLE social_features.teams ENABLE ROW LEVEL SECURITY;

-- Comentarios
COMMENT ON TABLE social_features.teams IS 'RLS enabled: Equipos de trabajo colaborativo';
