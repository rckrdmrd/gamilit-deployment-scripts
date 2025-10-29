-- =====================================================
-- Table: audit_logging.system_logs
-- Description: Logs del sistema - errores, advertencias, información de debugging
-- Created: 2025-10-27
-- =====================================================

SET search_path TO audit_logging, public;

DROP TABLE IF EXISTS audit_logging.system_logs CASCADE;

CREATE TABLE audit_logging.system_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    log_level text NOT NULL,
    logger_name text,
    message text NOT NULL,
    module_name text,
    function_name text,
    line_number integer,
    file_path text,
    request_id text,
    session_id text,
    user_id uuid,
    ip_address inet,
    exception_type text,
    exception_message text,
    stack_trace text,
    execution_time_ms integer,
    memory_usage_mb numeric(10,2),
    cpu_usage_percent numeric(5,2),
    environment text DEFAULT 'production'::text,
    server_name text,
    thread_id text,
    correlation_id text,
    extra_data jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT system_logs_environment_check CHECK ((environment = ANY (ARRAY['development'::text, 'staging'::text, 'production'::text]))),
    CONSTRAINT system_logs_log_level_check CHECK ((log_level = ANY (ARRAY['TRACE'::text, 'DEBUG'::text, 'INFO'::text, 'WARN'::text, 'ERROR'::text, 'FATAL'::text])))
);

ALTER TABLE audit_logging.system_logs OWNER TO postgres;

-- =====================================================
-- Constraints
-- =====================================================

-- Primary Key
ALTER TABLE ONLY audit_logging.system_logs
    ADD CONSTRAINT system_logs_pkey PRIMARY KEY (id);

-- Foreign Keys
ALTER TABLE ONLY audit_logging.system_logs
    ADD CONSTRAINT system_logs_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;

ALTER TABLE ONLY audit_logging.system_logs
    ADD CONSTRAINT system_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id);

-- =====================================================
-- Indexes
-- =====================================================

CREATE INDEX idx_system_logs_created ON audit_logging.system_logs USING btree (created_at DESC);
CREATE INDEX idx_system_logs_errors ON audit_logging.system_logs USING btree (log_level, created_at DESC) WHERE (log_level = ANY (ARRAY['ERROR'::text, 'FATAL'::text]));
CREATE INDEX idx_system_logs_level ON audit_logging.system_logs USING btree (log_level);
CREATE INDEX idx_system_logs_user ON audit_logging.system_logs USING btree (user_id) WHERE (user_id IS NOT NULL);

-- =====================================================
-- Row Level Security
-- =====================================================

ALTER TABLE audit_logging.system_logs ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON TABLE audit_logging.system_logs IS 'Logs del sistema - errores, advertencias, información de debugging';
COMMENT ON COLUMN audit_logging.system_logs.id IS 'Identificador único del log';
COMMENT ON COLUMN audit_logging.system_logs.tenant_id IS 'ID del tenant/organización';
COMMENT ON COLUMN audit_logging.system_logs.log_level IS 'Nivel: TRACE, DEBUG, INFO, WARN, ERROR, FATAL';
COMMENT ON COLUMN audit_logging.system_logs.logger_name IS 'Nombre del logger';
COMMENT ON COLUMN audit_logging.system_logs.message IS 'Mensaje del log';
COMMENT ON COLUMN audit_logging.system_logs.module_name IS 'Nombre del módulo';
COMMENT ON COLUMN audit_logging.system_logs.function_name IS 'Nombre de la función';
COMMENT ON COLUMN audit_logging.system_logs.line_number IS 'Número de línea en el código';
COMMENT ON COLUMN audit_logging.system_logs.file_path IS 'Ruta del archivo de código';
COMMENT ON COLUMN audit_logging.system_logs.request_id IS 'ID de la petición HTTP';
COMMENT ON COLUMN audit_logging.system_logs.session_id IS 'ID de la sesión';
COMMENT ON COLUMN audit_logging.system_logs.user_id IS 'ID del usuario relacionado';
COMMENT ON COLUMN audit_logging.system_logs.ip_address IS 'Dirección IP';
COMMENT ON COLUMN audit_logging.system_logs.exception_type IS 'Tipo de excepción';
COMMENT ON COLUMN audit_logging.system_logs.exception_message IS 'Mensaje de la excepción';
COMMENT ON COLUMN audit_logging.system_logs.stack_trace IS 'Stack trace del error';
COMMENT ON COLUMN audit_logging.system_logs.execution_time_ms IS 'Tiempo de ejecución en milisegundos';
COMMENT ON COLUMN audit_logging.system_logs.memory_usage_mb IS 'Uso de memoria en MB';
COMMENT ON COLUMN audit_logging.system_logs.cpu_usage_percent IS 'Uso de CPU en porcentaje';
COMMENT ON COLUMN audit_logging.system_logs.environment IS 'Ambiente: development, staging, production';
COMMENT ON COLUMN audit_logging.system_logs.server_name IS 'Nombre del servidor';
COMMENT ON COLUMN audit_logging.system_logs.thread_id IS 'ID del hilo/thread';
COMMENT ON COLUMN audit_logging.system_logs.correlation_id IS 'ID de correlación para seguimiento';
COMMENT ON COLUMN audit_logging.system_logs.extra_data IS 'Datos adicionales en formato JSON';
COMMENT ON COLUMN audit_logging.system_logs.created_at IS 'Fecha y hora de creación del registro';

-- =====================================================
-- Grants
-- =====================================================

GRANT ALL ON TABLE audit_logging.system_logs TO glit_user;
