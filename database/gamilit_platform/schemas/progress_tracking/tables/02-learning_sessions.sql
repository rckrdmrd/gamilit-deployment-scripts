--
-- PostgreSQL database dump
--

\restrict LAyybR8vaczj904lSiuzS43Wn4wakgHOWharmARXg1RdGuUzTcQkLUvSfslDbQj

-- Dumped from database version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: learning_sessions; Type: TABLE; Schema: progress_tracking; Owner: postgres
--

CREATE TABLE progress_tracking.learning_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid,
    session_token text,
    session_type text DEFAULT 'learning'::text,
    module_id uuid,
    exercise_id uuid,
    classroom_id uuid,
    started_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    ended_at timestamp with time zone,
    duration interval,
    active_time interval,
    idle_time interval,
    exercises_attempted integer DEFAULT 0,
    exercises_completed integer DEFAULT 0,
    content_viewed integer DEFAULT 0,
    total_score integer DEFAULT 0,
    total_xp_earned integer DEFAULT 0,
    total_ml_coins_earned integer DEFAULT 0,
    clicks_count integer DEFAULT 0,
    page_views integer DEFAULT 0,
    resource_downloads integer DEFAULT 0,
    device_info jsonb DEFAULT '{}'::jsonb,
    browser_info jsonb DEFAULT '{}'::jsonb,
    connection_quality text,
    errors_encountered integer DEFAULT 0,
    is_active boolean DEFAULT true,
    completion_status text DEFAULT 'ongoing'::text,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT learning_sessions_completion_status_check CHECK ((completion_status = ANY (ARRAY['ongoing'::text, 'completed'::text, 'abandoned'::text, 'timed_out'::text]))),
    CONSTRAINT learning_sessions_session_type_check CHECK ((session_type = ANY (ARRAY['learning'::text, 'practice'::text, 'assessment'::text, 'review'::text])))
);


ALTER TABLE progress_tracking.learning_sessions OWNER TO postgres;

--
-- Name: TABLE learning_sessions; Type: COMMENT; Schema: progress_tracking; Owner: postgres
--

COMMENT ON TABLE progress_tracking.learning_sessions IS 'Sesiones de aprendizaje con tracking de tiempo y actividad';


--
-- Name: COLUMN learning_sessions.session_type; Type: COMMENT; Schema: progress_tracking; Owner: postgres
--

COMMENT ON COLUMN progress_tracking.learning_sessions.session_type IS 'Tipo: learning, practice, assessment, review';


--
-- Name: learning_sessions learning_sessions_pkey; Type: CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.learning_sessions
    ADD CONSTRAINT learning_sessions_pkey PRIMARY KEY (id);


--
-- Name: learning_sessions learning_sessions_session_token_key; Type: CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.learning_sessions
    ADD CONSTRAINT learning_sessions_session_token_key UNIQUE (session_token);


--
-- Name: idx_sessions_active; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_sessions_active ON progress_tracking.learning_sessions USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_sessions_module; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_sessions_module ON progress_tracking.learning_sessions USING btree (module_id);


--
-- Name: idx_sessions_started; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_sessions_started ON progress_tracking.learning_sessions USING btree (started_at DESC);


--
-- Name: idx_sessions_user; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_sessions_user ON progress_tracking.learning_sessions USING btree (user_id);


--
-- Name: learning_sessions learning_sessions_exercise_id_fkey; Type: FK CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.learning_sessions
    ADD CONSTRAINT learning_sessions_exercise_id_fkey FOREIGN KEY (exercise_id) REFERENCES educational_content.exercises(id);


--
-- Name: learning_sessions learning_sessions_module_id_fkey; Type: FK CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.learning_sessions
    ADD CONSTRAINT learning_sessions_module_id_fkey FOREIGN KEY (module_id) REFERENCES educational_content.modules(id);


--
-- Name: learning_sessions learning_sessions_tenant_id_fkey; Type: FK CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.learning_sessions
    ADD CONSTRAINT learning_sessions_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;


--
-- Name: learning_sessions learning_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.learning_sessions
    ADD CONSTRAINT learning_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id) ON DELETE CASCADE;


--
-- Name: learning_sessions; Type: ROW SECURITY; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE progress_tracking.learning_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: TABLE learning_sessions; Type: ACL; Schema: progress_tracking; Owner: postgres
--

GRANT ALL ON TABLE progress_tracking.learning_sessions TO gamilit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict LAyybR8vaczj904lSiuzS43Wn4wakgHOWharmARXg1RdGuUzTcQkLUvSfslDbQj

