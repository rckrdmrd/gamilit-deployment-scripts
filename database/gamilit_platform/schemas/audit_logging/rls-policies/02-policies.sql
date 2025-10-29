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

-- =====================================================
-- TABLE: audit_logging.performance_metrics
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS performance_metrics_select_admin ON audit_logging.performance_metrics;
DROP POLICY IF EXISTS performance_metrics_insert_system ON audit_logging.performance_metrics;

-- Policy: performance_metrics_select_admin
-- Description: Solo los administradores pueden leer las métricas de rendimiento
CREATE POLICY performance_metrics_select_admin
    ON audit_logging.performance_metrics
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.is_admin() OR gamilit.is_super_admin());

COMMENT ON POLICY performance_metrics_select_admin ON audit_logging.performance_metrics IS
    'Permite a los administradores leer todas las métricas de rendimiento del sistema';

-- Policy: performance_metrics_insert_system
-- Description: Cualquier usuario autenticado puede insertar métricas (el sistema lo hace automáticamente)
CREATE POLICY performance_metrics_insert_system
    ON audit_logging.performance_metrics
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (gamilit.get_current_user_id() IS NOT NULL);

COMMENT ON POLICY performance_metrics_insert_system ON audit_logging.performance_metrics IS
    'Permite que el sistema registre métricas de rendimiento automáticamente';

-- =====================================================
-- TABLE: audit_logging.system_alerts
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS system_alerts_all_admin ON audit_logging.system_alerts;

-- Policy: system_alerts_all_admin
-- Description: Solo los administradores pueden gestionar alertas del sistema
CREATE POLICY system_alerts_all_admin
    ON audit_logging.system_alerts
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (gamilit.is_admin() OR gamilit.is_super_admin());

COMMENT ON POLICY system_alerts_all_admin ON audit_logging.system_alerts IS
    'Permite a los administradores gestión completa de las alertas del sistema';

-- =====================================================
-- TABLE: audit_logging.system_logs
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS system_logs_select_admin ON audit_logging.system_logs;
DROP POLICY IF EXISTS system_logs_insert_system ON audit_logging.system_logs;

-- Policy: system_logs_select_admin
-- Description: Solo los administradores pueden leer los logs del sistema
CREATE POLICY system_logs_select_admin
    ON audit_logging.system_logs
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.is_admin() OR gamilit.is_super_admin());

COMMENT ON POLICY system_logs_select_admin ON audit_logging.system_logs IS
    'Permite a los administradores leer todos los logs del sistema';

-- Policy: system_logs_insert_system
-- Description: El sistema puede insertar logs automáticamente
CREATE POLICY system_logs_insert_system
    ON audit_logging.system_logs
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (gamilit.get_current_user_id() IS NOT NULL);

COMMENT ON POLICY system_logs_insert_system ON audit_logging.system_logs IS
    'Permite que el sistema registre logs automáticamente';

-- =====================================================
-- TABLE: audit_logging.user_activity_logs
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS user_activity_logs_select_admin ON audit_logging.user_activity_logs;
DROP POLICY IF EXISTS user_activity_logs_select_own ON audit_logging.user_activity_logs;
DROP POLICY IF EXISTS user_activity_logs_insert_own ON audit_logging.user_activity_logs;

-- Policy: user_activity_logs_select_admin
-- Description: Los administradores pueden ver toda la actividad de usuarios
CREATE POLICY user_activity_logs_select_admin
    ON audit_logging.user_activity_logs
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (gamilit.is_admin() OR gamilit.is_super_admin());

COMMENT ON POLICY user_activity_logs_select_admin ON audit_logging.user_activity_logs IS
    'Permite a los administradores ver la actividad de todos los usuarios';

-- Policy: user_activity_logs_select_own
-- Description: Los usuarios pueden ver sus propios logs de actividad
CREATE POLICY user_activity_logs_select_own
    ON audit_logging.user_activity_logs
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = gamilit.get_current_user_id());

COMMENT ON POLICY user_activity_logs_select_own ON audit_logging.user_activity_logs IS
    'Permite a los usuarios ver únicamente sus propios logs de actividad';

-- Policy: user_activity_logs_insert_own
-- Description: Los usuarios pueden registrar su propia actividad
CREATE POLICY user_activity_logs_insert_own
    ON audit_logging.user_activity_logs
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (user_id = gamilit.get_current_user_id());

COMMENT ON POLICY user_activity_logs_insert_own ON audit_logging.user_activity_logs IS
    'Permite que el sistema registre la actividad del usuario autenticado';
