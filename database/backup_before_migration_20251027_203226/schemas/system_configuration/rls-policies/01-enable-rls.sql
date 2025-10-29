-- =====================================================
-- Enable RLS for system_configuration tables
-- Created: 2025-10-27
-- Description: Habilita Row Level Security en todas las
--              tablas del schema system_configuration
-- =====================================================

-- Tablas con RLS habilitado
ALTER TABLE system_configuration.feature_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_configuration.system_settings ENABLE ROW LEVEL SECURITY;

-- Comentarios
COMMENT ON TABLE system_configuration.feature_flags IS 'RLS enabled: Banderas de características del sistema';
COMMENT ON TABLE system_configuration.system_settings IS 'RLS enabled: Configuraciones del sistema';
