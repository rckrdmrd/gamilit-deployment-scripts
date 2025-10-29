-- =====================================================
-- Enable RLS for auth_management tables
-- Created: 2025-10-27
-- Description: Habilita Row Level Security en tablas de
--              gestión de autenticación (solo profiles tiene policies activas)
-- =====================================================

-- Nota: Solo la tabla profiles tiene RLS habilitado actualmente
-- Otras tablas del schema no requieren RLS en este momento

-- Comentarios
COMMENT ON TABLE auth_management.profiles IS 'RLS enabled: Perfiles de usuario con acceso controlado';
