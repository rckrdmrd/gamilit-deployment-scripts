-- =====================================================
-- Schemas Creation for gamilit_platform
-- Description: Crear todos los schemas del sistema
-- Created: 2025-10-27
-- =====================================================

-- Enable extensions first
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Schema: audit_logging
CREATE SCHEMA IF NOT EXISTS audit_logging;
COMMENT ON SCHEMA audit_logging IS 'Schema para logs de auditoría y monitoreo del sistema';

-- Schema: auth
CREATE SCHEMA IF NOT EXISTS auth;
COMMENT ON SCHEMA auth IS 'Schema para autenticación y manejo de sesiones de usuarios';

-- Schema: auth_management
CREATE SCHEMA IF NOT EXISTS auth_management;
COMMENT ON SCHEMA auth_management IS 'Schema para gestión avanzada de autenticación y permisos';

-- Schema: content_management
CREATE SCHEMA IF NOT EXISTS content_management;
COMMENT ON SCHEMA content_management IS 'Schema para gestión de contenidos del sistema';

-- Schema: educational_content
CREATE SCHEMA IF NOT EXISTS educational_content;
COMMENT ON SCHEMA educational_content IS 'Schema para contenidos educativos y materiales de aprendizaje';

-- Schema: gamification_system
CREATE SCHEMA IF NOT EXISTS gamification_system;
COMMENT ON SCHEMA gamification_system IS 'Schema para sistema de gamificación, logros y recompensas';

-- Schema: gamilit
CREATE SCHEMA IF NOT EXISTS gamilit;
COMMENT ON SCHEMA gamilit IS 'Schema principal del sistema GAMILIT';

-- Schema: progress_tracking
CREATE SCHEMA IF NOT EXISTS progress_tracking;
COMMENT ON SCHEMA progress_tracking IS 'Schema para seguimiento de progreso y métricas de usuarios';

-- Schema: social_features
CREATE SCHEMA IF NOT EXISTS social_features;
COMMENT ON SCHEMA social_features IS 'Schema para características sociales e interacción entre usuarios';

-- Schema: system_configuration
CREATE SCHEMA IF NOT EXISTS system_configuration;
COMMENT ON SCHEMA system_configuration IS 'Schema para configuración general del sistema';
