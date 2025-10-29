-- =====================================================
-- GIN Index: idx_user_roles_permissions_gin
-- Table: auth_management.user_roles
-- Column: permissions (JSONB)
-- Description: Índice GIN para búsqueda eficiente de permisos específicos
-- Priority: HIGH - Performance optimization
-- Created: 2025-10-27
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_user_roles_permissions_gin
ON auth_management.user_roles
USING GIN (permissions jsonb_path_ops);

COMMENT ON INDEX auth_management.idx_user_roles_permissions_gin IS 'Índice GIN para búsqueda eficiente de permisos específicos';

-- =====================================================
-- Performance Improvement Example
-- =====================================================

/*
-- Check if user has specific permission (now uses GIN index)
SELECT user_id
FROM auth_management.user_roles
WHERE permissions ? 'edit_users'
AND is_active = true;
*/
