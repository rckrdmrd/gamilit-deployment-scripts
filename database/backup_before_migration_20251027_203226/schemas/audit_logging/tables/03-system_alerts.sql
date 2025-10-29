-- =====================================================
-- Table: audit_logging.system_alerts
-- Description: Alertas del sistema - rendimiento, seguridad, errores
-- Created: 2025-10-27
-- =====================================================

SET search_path TO audit_logging, public;

DROP TABLE IF EXISTS audit_logging.system_alerts CASCADE;

CREATE TABLE audit_logging.system_alerts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    alert_type text NOT NULL,
    severity text NOT NULL,
    title text NOT NULL,
    description text,
    source_system text,
    source_module text,
    error_code text,
    affected_users integer DEFAULT 0,
    status text DEFAULT 'open'::text,
    acknowledgment_note text,
    resolution_note text,
    acknowledged_by uuid,
    acknowledged_at timestamp with time zone,
    resolved_by uuid,
    resolved_at timestamp with time zone,
    notification_sent boolean DEFAULT false,
    escalation_level integer DEFAULT 1,
    auto_resolve boolean DEFAULT false,
    suppress_similar boolean DEFAULT false,
    context_data jsonb DEFAULT '{}'::jsonb,
    metrics jsonb DEFAULT '{}'::jsonb,
    related_alerts uuid[],
    triggered_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT system_alerts_alert_type_check CHECK ((alert_type = ANY (ARRAY['performance_degradation'::text, 'high_error_rate'::text, 'security_breach'::text, 'resource_limit'::text, 'service_outage'::text, 'data_anomaly'::text]))),
    CONSTRAINT system_alerts_escalation_level_check CHECK (((escalation_level >= 1) AND (escalation_level <= 5))),
    CONSTRAINT system_alerts_severity_check CHECK ((severity = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'critical'::text]))),
    CONSTRAINT system_alerts_status_check CHECK ((status = ANY (ARRAY['open'::text, 'acknowledged'::text, 'resolved'::text, 'suppressed'::text])))
);

ALTER TABLE audit_logging.system_alerts OWNER TO postgres;

-- =====================================================
-- Constraints
-- =====================================================

-- Primary Key
ALTER TABLE ONLY audit_logging.system_alerts
    ADD CONSTRAINT system_alerts_pkey PRIMARY KEY (id);

-- Foreign Keys
ALTER TABLE ONLY audit_logging.system_alerts
    ADD CONSTRAINT system_alerts_acknowledged_by_fkey FOREIGN KEY (acknowledged_by) REFERENCES auth_management.profiles(id);

ALTER TABLE ONLY audit_logging.system_alerts
    ADD CONSTRAINT system_alerts_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES auth_management.profiles(id);

ALTER TABLE ONLY audit_logging.system_alerts
    ADD CONSTRAINT system_alerts_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;

-- =====================================================
-- Indexes
-- =====================================================

CREATE INDEX idx_alerts_open ON audit_logging.system_alerts USING btree (status, severity) WHERE (status = 'open'::text);
CREATE INDEX idx_alerts_severity ON audit_logging.system_alerts USING btree (severity);
CREATE INDEX idx_alerts_status ON audit_logging.system_alerts USING btree (status);
CREATE INDEX idx_alerts_triggered ON audit_logging.system_alerts USING btree (triggered_at DESC);
CREATE INDEX idx_alerts_type ON audit_logging.system_alerts USING btree (alert_type);

-- =====================================================
-- Triggers
-- =====================================================

CREATE TRIGGER trg_system_alerts_updated_at
    BEFORE UPDATE ON audit_logging.system_alerts
    FOR EACH ROW
    EXECUTE FUNCTION gamilit.update_updated_at_column();

-- =====================================================
-- Row Level Security
-- =====================================================

ALTER TABLE audit_logging.system_alerts ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON TABLE audit_logging.system_alerts IS 'Alertas del sistema - rendimiento, seguridad, errores';
COMMENT ON COLUMN audit_logging.system_alerts.id IS 'Identificador único de la alerta';
COMMENT ON COLUMN audit_logging.system_alerts.tenant_id IS 'ID del tenant/organización';
COMMENT ON COLUMN audit_logging.system_alerts.alert_type IS 'Tipo de alerta: performance_degradation, high_error_rate, security_breach, resource_limit, service_outage, data_anomaly';
COMMENT ON COLUMN audit_logging.system_alerts.severity IS 'Severidad: low, medium, high, critical';
COMMENT ON COLUMN audit_logging.system_alerts.title IS 'Título de la alerta';
COMMENT ON COLUMN audit_logging.system_alerts.description IS 'Descripción detallada de la alerta';
COMMENT ON COLUMN audit_logging.system_alerts.source_system IS 'Sistema origen de la alerta';
COMMENT ON COLUMN audit_logging.system_alerts.source_module IS 'Módulo origen de la alerta';
COMMENT ON COLUMN audit_logging.system_alerts.error_code IS 'Código de error asociado';
COMMENT ON COLUMN audit_logging.system_alerts.affected_users IS 'Número de usuarios afectados';
COMMENT ON COLUMN audit_logging.system_alerts.status IS 'Estado: open, acknowledged, resolved, suppressed';
COMMENT ON COLUMN audit_logging.system_alerts.acknowledgment_note IS 'Nota de reconocimiento de la alerta';
COMMENT ON COLUMN audit_logging.system_alerts.resolution_note IS 'Nota de resolución de la alerta';
COMMENT ON COLUMN audit_logging.system_alerts.acknowledged_by IS 'Usuario que reconoció la alerta';
COMMENT ON COLUMN audit_logging.system_alerts.acknowledged_at IS 'Fecha y hora de reconocimiento';
COMMENT ON COLUMN audit_logging.system_alerts.resolved_by IS 'Usuario que resolvió la alerta';
COMMENT ON COLUMN audit_logging.system_alerts.resolved_at IS 'Fecha y hora de resolución';
COMMENT ON COLUMN audit_logging.system_alerts.notification_sent IS 'Indica si se envió notificación';
COMMENT ON COLUMN audit_logging.system_alerts.escalation_level IS 'Nivel de escalamiento (1-5)';
COMMENT ON COLUMN audit_logging.system_alerts.auto_resolve IS 'Indica si se resuelve automáticamente';
COMMENT ON COLUMN audit_logging.system_alerts.suppress_similar IS 'Indica si se suprimen alertas similares';
COMMENT ON COLUMN audit_logging.system_alerts.context_data IS 'Datos de contexto en formato JSON';
COMMENT ON COLUMN audit_logging.system_alerts.metrics IS 'Métricas relacionadas en formato JSON';
COMMENT ON COLUMN audit_logging.system_alerts.related_alerts IS 'IDs de alertas relacionadas';
COMMENT ON COLUMN audit_logging.system_alerts.triggered_at IS 'Fecha y hora cuando se activó la alerta';
COMMENT ON COLUMN audit_logging.system_alerts.created_at IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN audit_logging.system_alerts.updated_at IS 'Fecha y hora de última actualización';

-- =====================================================
-- Grants
-- =====================================================

GRANT ALL ON TABLE audit_logging.system_alerts TO glit_user;
