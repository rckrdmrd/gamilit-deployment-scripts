-- =====================================================
-- Table: audit_logging.user_activity_logs
-- Description: Registro de actividad de usuarios para analytics
-- Created: 2025-10-27
-- =====================================================

SET search_path TO audit_logging, public;

DROP TABLE IF EXISTS audit_logging.user_activity_logs CASCADE;

CREATE TABLE audit_logging.user_activity_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid,
    activity_type text NOT NULL,
    action_detail text,
    page_url text,
    page_title text,
    referrer_url text,
    session_id text,
    session_duration interval,
    element_id text,
    element_type text,
    element_text text,
    coordinates point,
    module_id uuid,
    exercise_id uuid,
    classroom_id uuid,
    user_agent text,
    ip_address inet,
    device_type text,
    browser_name text,
    browser_version text,
    screen_resolution text,
    load_time_ms integer,
    interaction_time_ms integer,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT user_activity_logs_activity_type_check CHECK ((activity_type = ANY (ARRAY['page_view'::text, 'button_click'::text, 'form_submit'::text, 'exercise_start'::text, 'exercise_complete'::text, 'module_access'::text, 'video_play'::text, 'resource_download'::text, 'search_query'::text])))
);

ALTER TABLE audit_logging.user_activity_logs OWNER TO postgres;

-- =====================================================
-- Constraints
-- =====================================================

-- Primary Key
ALTER TABLE ONLY audit_logging.user_activity_logs
    ADD CONSTRAINT user_activity_logs_pkey PRIMARY KEY (id);

-- Foreign Keys
ALTER TABLE ONLY audit_logging.user_activity_logs
    ADD CONSTRAINT user_activity_logs_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;

ALTER TABLE ONLY audit_logging.user_activity_logs
    ADD CONSTRAINT user_activity_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id) ON DELETE CASCADE;

-- =====================================================
-- Indexes
-- =====================================================

CREATE INDEX idx_activity_created ON audit_logging.user_activity_logs USING btree (created_at DESC);
CREATE INDEX idx_activity_module ON audit_logging.user_activity_logs USING btree (module_id) WHERE (module_id IS NOT NULL);
CREATE INDEX idx_activity_session ON audit_logging.user_activity_logs USING btree (session_id);
CREATE INDEX idx_activity_type ON audit_logging.user_activity_logs USING btree (activity_type);
CREATE INDEX idx_activity_user ON audit_logging.user_activity_logs USING btree (user_id);

-- =====================================================
-- Row Level Security
-- =====================================================

ALTER TABLE audit_logging.user_activity_logs ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON TABLE audit_logging.user_activity_logs IS 'Registro de actividad de usuarios para analytics';
COMMENT ON COLUMN audit_logging.user_activity_logs.id IS 'Identificador único del registro de actividad';
COMMENT ON COLUMN audit_logging.user_activity_logs.user_id IS 'ID del usuario que realizó la actividad';
COMMENT ON COLUMN audit_logging.user_activity_logs.tenant_id IS 'ID del tenant/organización';
COMMENT ON COLUMN audit_logging.user_activity_logs.activity_type IS 'Tipo: page_view, button_click, exercise_start, etc.';
COMMENT ON COLUMN audit_logging.user_activity_logs.action_detail IS 'Detalle de la acción realizada';
COMMENT ON COLUMN audit_logging.user_activity_logs.page_url IS 'URL de la página';
COMMENT ON COLUMN audit_logging.user_activity_logs.page_title IS 'Título de la página';
COMMENT ON COLUMN audit_logging.user_activity_logs.referrer_url IS 'URL de referencia';
COMMENT ON COLUMN audit_logging.user_activity_logs.session_id IS 'ID de la sesión';
COMMENT ON COLUMN audit_logging.user_activity_logs.session_duration IS 'Duración de la sesión';
COMMENT ON COLUMN audit_logging.user_activity_logs.element_id IS 'ID del elemento HTML interactuado';
COMMENT ON COLUMN audit_logging.user_activity_logs.element_type IS 'Tipo de elemento HTML';
COMMENT ON COLUMN audit_logging.user_activity_logs.element_text IS 'Texto del elemento';
COMMENT ON COLUMN audit_logging.user_activity_logs.coordinates IS 'Coordenadas del click (punto x,y)';
COMMENT ON COLUMN audit_logging.user_activity_logs.module_id IS 'ID del módulo educativo';
COMMENT ON COLUMN audit_logging.user_activity_logs.exercise_id IS 'ID del ejercicio';
COMMENT ON COLUMN audit_logging.user_activity_logs.classroom_id IS 'ID del aula/salón';
COMMENT ON COLUMN audit_logging.user_activity_logs.user_agent IS 'User agent del navegador';
COMMENT ON COLUMN audit_logging.user_activity_logs.ip_address IS 'Dirección IP del usuario';
COMMENT ON COLUMN audit_logging.user_activity_logs.device_type IS 'Tipo de dispositivo (desktop, mobile, tablet)';
COMMENT ON COLUMN audit_logging.user_activity_logs.browser_name IS 'Nombre del navegador';
COMMENT ON COLUMN audit_logging.user_activity_logs.browser_version IS 'Versión del navegador';
COMMENT ON COLUMN audit_logging.user_activity_logs.screen_resolution IS 'Resolución de pantalla';
COMMENT ON COLUMN audit_logging.user_activity_logs.load_time_ms IS 'Tiempo de carga en milisegundos';
COMMENT ON COLUMN audit_logging.user_activity_logs.interaction_time_ms IS 'Tiempo de interacción en milisegundos';
COMMENT ON COLUMN audit_logging.user_activity_logs.metadata IS 'Metadatos adicionales en formato JSON';
COMMENT ON COLUMN audit_logging.user_activity_logs.created_at IS 'Fecha y hora de creación del registro';

-- =====================================================
-- Grants
-- =====================================================

GRANT ALL ON TABLE audit_logging.user_activity_logs TO gamilit_user;
