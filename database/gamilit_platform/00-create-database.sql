-- =====================================================
-- Database: gamilit_platform
-- Description: Base de datos para GAMILIT Platform
-- Created: 2025-10-27
-- =====================================================

-- Drop database if exists (CUIDADO: solo para desarrollo)
DROP DATABASE IF EXISTS gamilit_platform;

-- Create database
CREATE DATABASE gamilit_platform
    WITH
    OWNER = gamilit_user
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE gamilit_platform IS 'Base de datos para GAMILIT - Gamified Literacy Interactive Training Platform';
