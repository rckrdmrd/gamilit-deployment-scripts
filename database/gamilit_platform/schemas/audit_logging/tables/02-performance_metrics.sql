-- =====================================================
-- Table: audit_logging.performance_metrics
-- Description: Métricas de rendimiento del sistema
-- Created: 2025-10-27
-- =====================================================

SET search_path TO audit_logging, public;

DROP TABLE IF EXISTS audit_logging.performance_metrics CASCADE;

CREATE TABLE audit_logging.performance_metrics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    metric_name text NOT NULL,
    metric_type text NOT NULL,
    category text,
    metric_value numeric NOT NULL,
    unit text,
    endpoint text,
    operation text,
    module_name text,
    function_name text,
    request_id text,
    session_id text,
    user_id uuid,
    dimensions jsonb DEFAULT '{}'::jsonb,
    tags text[],
    measured_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT performance_metrics_metric_type_check CHECK ((metric_type = ANY (ARRAY['counter'::text, 'gauge'::text, 'histogram'::text, 'timer'::text])))
);

ALTER TABLE audit_logging.performance_metrics OWNER TO postgres;

-- =====================================================
-- Constraints
-- =====================================================

-- Primary Key
ALTER TABLE ONLY audit_logging.performance_metrics
    ADD CONSTRAINT performance_metrics_pkey PRIMARY KEY (id);

-- Foreign Keys
ALTER TABLE ONLY audit_logging.performance_metrics
    ADD CONSTRAINT performance_metrics_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;

ALTER TABLE ONLY audit_logging.performance_metrics
    ADD CONSTRAINT performance_metrics_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id);

-- =====================================================
-- Indexes
-- =====================================================

CREATE INDEX idx_perf_metrics_category ON audit_logging.performance_metrics USING btree (category);
CREATE INDEX idx_perf_metrics_dimensions ON audit_logging.performance_metrics USING gin (dimensions);
CREATE INDEX idx_perf_metrics_measured ON audit_logging.performance_metrics USING btree (measured_at DESC);
CREATE INDEX idx_perf_metrics_name ON audit_logging.performance_metrics USING btree (metric_name);
CREATE INDEX idx_perf_metrics_type ON audit_logging.performance_metrics USING btree (metric_type);

-- =====================================================
-- Row Level Security
-- =====================================================

ALTER TABLE audit_logging.performance_metrics ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON TABLE audit_logging.performance_metrics IS 'Métricas de rendimiento del sistema';
COMMENT ON COLUMN audit_logging.performance_metrics.id IS 'Identificador único de la métrica';
COMMENT ON COLUMN audit_logging.performance_metrics.tenant_id IS 'ID del tenant/organización';
COMMENT ON COLUMN audit_logging.performance_metrics.metric_name IS 'Nombre de la métrica';
COMMENT ON COLUMN audit_logging.performance_metrics.metric_type IS 'Tipo: counter, gauge, histogram, timer';
COMMENT ON COLUMN audit_logging.performance_metrics.category IS 'Categoría de la métrica (performance, business, system, etc.)';
COMMENT ON COLUMN audit_logging.performance_metrics.metric_value IS 'Valor numérico de la métrica';
COMMENT ON COLUMN audit_logging.performance_metrics.unit IS 'Unidad de medida (ms, bytes, count, etc.)';
COMMENT ON COLUMN audit_logging.performance_metrics.endpoint IS 'Endpoint API relacionado';
COMMENT ON COLUMN audit_logging.performance_metrics.operation IS 'Operación relacionada';
COMMENT ON COLUMN audit_logging.performance_metrics.module_name IS 'Nombre del módulo';
COMMENT ON COLUMN audit_logging.performance_metrics.function_name IS 'Nombre de la función';
COMMENT ON COLUMN audit_logging.performance_metrics.request_id IS 'ID de la petición HTTP';
COMMENT ON COLUMN audit_logging.performance_metrics.session_id IS 'ID de la sesión';
COMMENT ON COLUMN audit_logging.performance_metrics.user_id IS 'ID del usuario relacionado';
COMMENT ON COLUMN audit_logging.performance_metrics.dimensions IS 'Dimensiones adicionales en formato JSON';
COMMENT ON COLUMN audit_logging.performance_metrics.tags IS 'Tags para categorización';
COMMENT ON COLUMN audit_logging.performance_metrics.measured_at IS 'Fecha y hora de la medición';
COMMENT ON COLUMN audit_logging.performance_metrics.created_at IS 'Fecha y hora de creación del registro';

-- =====================================================
-- Grants
-- =====================================================

GRANT ALL ON TABLE audit_logging.performance_metrics TO gamilit_user;
