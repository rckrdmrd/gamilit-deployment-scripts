-- =====================================================
-- Table: audit_logging.audit_logs
-- Description: Registro de auditoría completo de todas las acciones del sistema
-- Created: 2025-10-27
-- =====================================================

SET search_path TO audit_logging, public;

DROP TABLE IF EXISTS audit_logging.audit_logs CASCADE;

CREATE TABLE audit_logging.audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    event_type text NOT NULL,
    action text NOT NULL,
    resource_type text,
    resource_id uuid,
    actor_id uuid,
    actor_type text DEFAULT 'user'::text,
    actor_ip inet,
    actor_user_agent text,
    target_id uuid,
    target_type text,
    session_id text,
    description text,
    old_values jsonb DEFAULT '{}'::jsonb,
    new_values jsonb DEFAULT '{}'::jsonb,
    changes jsonb DEFAULT '{}'::jsonb,
    severity text DEFAULT 'info'::text,
    status text DEFAULT 'success'::text,
    error_code text,
    error_message text,
    stack_trace text,
    request_id text,
    correlation_id text,
    additional_data jsonb DEFAULT '{}'::jsonb,
    tags text[],
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT audit_logs_actor_type_check CHECK ((actor_type = ANY (ARRAY['user'::text, 'system'::text, 'api'::text, 'cron'::text]))),
    CONSTRAINT audit_logs_severity_check CHECK ((severity = ANY (ARRAY['debug'::text, 'info'::text, 'warning'::text, 'error'::text, 'critical'::text]))),
    CONSTRAINT audit_logs_status_check CHECK ((status = ANY (ARRAY['success'::text, 'failure'::text, 'partial'::text])))
);

ALTER TABLE audit_logging.audit_logs OWNER TO postgres;

-- =====================================================
-- Constraints
-- =====================================================

-- Primary Key
ALTER TABLE ONLY audit_logging.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);

-- Foreign Keys
ALTER TABLE ONLY audit_logging.audit_logs
    ADD CONSTRAINT audit_logs_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES auth_management.profiles(id);

ALTER TABLE ONLY audit_logging.audit_logs
    ADD CONSTRAINT audit_logs_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;

-- =====================================================
-- Indexes
-- =====================================================

CREATE INDEX idx_audit_logs_actor ON audit_logging.audit_logs USING btree (actor_id);
CREATE INDEX idx_audit_logs_correlation ON audit_logging.audit_logs USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);
CREATE INDEX idx_audit_logs_created ON audit_logging.audit_logs USING btree (created_at DESC);
CREATE INDEX idx_audit_logs_event_type ON audit_logging.audit_logs USING btree (event_type);
CREATE INDEX idx_audit_logs_resource ON audit_logging.audit_logs USING btree (resource_type, resource_id);
CREATE INDEX idx_audit_logs_severity ON audit_logging.audit_logs USING btree (severity) WHERE (severity = ANY (ARRAY['error'::text, 'critical'::text]));
CREATE INDEX idx_audit_logs_tenant ON audit_logging.audit_logs USING btree (tenant_id);

-- =====================================================
-- Row Level Security
-- =====================================================

ALTER TABLE audit_logging.audit_logs ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY audit_logs_select_admin ON audit_logging.audit_logs FOR SELECT USING (gamilit.is_admin());
CREATE POLICY audit_logs_select_own ON audit_logging.audit_logs FOR SELECT USING ((actor_id = gamilit.get_current_user_id()));

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON TABLE audit_logging.audit_logs IS 'Registro de auditoría completo de todas las acciones del sistema';
COMMENT ON COLUMN audit_logging.audit_logs.id IS 'Identificador único del registro de auditoría';
COMMENT ON COLUMN audit_logging.audit_logs.tenant_id IS 'ID del tenant/organización';
COMMENT ON COLUMN audit_logging.audit_logs.event_type IS 'Tipo de evento: user_login, module_created, achievement_earned, etc.';
COMMENT ON COLUMN audit_logging.audit_logs.action IS 'Acción realizada (create, read, update, delete, etc.)';
COMMENT ON COLUMN audit_logging.audit_logs.resource_type IS 'Tipo de recurso afectado';
COMMENT ON COLUMN audit_logging.audit_logs.resource_id IS 'ID del recurso afectado';
COMMENT ON COLUMN audit_logging.audit_logs.actor_id IS 'ID del usuario/sistema que realizó la acción';
COMMENT ON COLUMN audit_logging.audit_logs.actor_type IS 'Tipo de actor: user, system, api, cron';
COMMENT ON COLUMN audit_logging.audit_logs.actor_ip IS 'Dirección IP del actor';
COMMENT ON COLUMN audit_logging.audit_logs.actor_user_agent IS 'User agent del navegador/cliente';
COMMENT ON COLUMN audit_logging.audit_logs.target_id IS 'ID del objetivo de la acción';
COMMENT ON COLUMN audit_logging.audit_logs.target_type IS 'Tipo del objetivo';
COMMENT ON COLUMN audit_logging.audit_logs.session_id IS 'ID de la sesión';
COMMENT ON COLUMN audit_logging.audit_logs.description IS 'Descripción textual de la acción';
COMMENT ON COLUMN audit_logging.audit_logs.old_values IS 'Valores anteriores (en formato JSON)';
COMMENT ON COLUMN audit_logging.audit_logs.new_values IS 'Valores nuevos (en formato JSON)';
COMMENT ON COLUMN audit_logging.audit_logs.changes IS 'Cambios realizados (en formato JSON)';
COMMENT ON COLUMN audit_logging.audit_logs.severity IS 'Severidad: debug, info, warning, error, critical';
COMMENT ON COLUMN audit_logging.audit_logs.status IS 'Estado: success, failure, partial';
COMMENT ON COLUMN audit_logging.audit_logs.error_code IS 'Código de error si aplica';
COMMENT ON COLUMN audit_logging.audit_logs.error_message IS 'Mensaje de error si aplica';
COMMENT ON COLUMN audit_logging.audit_logs.stack_trace IS 'Stack trace del error si aplica';
COMMENT ON COLUMN audit_logging.audit_logs.request_id IS 'ID de la petición HTTP';
COMMENT ON COLUMN audit_logging.audit_logs.correlation_id IS 'ID de correlación para seguimiento entre servicios';
COMMENT ON COLUMN audit_logging.audit_logs.additional_data IS 'Datos adicionales en formato JSON';
COMMENT ON COLUMN audit_logging.audit_logs.tags IS 'Tags para categorización';
COMMENT ON COLUMN audit_logging.audit_logs.created_at IS 'Fecha y hora de creación del registro';

-- =====================================================
-- Grants
-- =====================================================

GRANT ALL ON TABLE audit_logging.audit_logs TO glit_user;
