-- =====================================================
-- RLS Policies for audit_logging schema
-- Description: Políticas de seguridad para auditoría y logs
-- Created: 2025-10-27
-- =====================================================

-- =====================================================
-- TABLE: audit_logging.audit_logs
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS audit_logs_select_admin ON audit_logging.audit_logs;
DROP POLICY IF EXISTS audit_logs_select_own ON audit_logging.audit_logs;

-- Policy: audit_logs_select_admin
-- Description: Los administradores pueden ver todos los registros de auditoría
CREATE POLICY audit_logs_select_admin
    ON audit_logging.audit_logs
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.is_admin());

COMMENT ON POLICY audit_logs_select_admin ON audit_logging.audit_logs IS
    'Permite a los administradores ver todos los registros de auditoría';

-- Policy: audit_logs_select_own
-- Description: Los usuarios pueden ver sus propios registros de auditoría
CREATE POLICY audit_logs_select_own
    ON audit_logging.audit_logs
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (actor_id = gamilit.get_current_user_id());

COMMENT ON POLICY audit_logs_select_own ON audit_logging.audit_logs IS
    'Permite a los usuarios ver únicamente sus propios registros de auditoría';
