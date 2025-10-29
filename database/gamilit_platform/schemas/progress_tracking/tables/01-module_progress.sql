--
-- PostgreSQL database dump
--

\restrict kbum8PVMgj5CLpUrEBeJlXIL8TxLp3qKyGRYM1icgHe84QAeAoEm90c4NVmH2oU

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
-- Name: module_progress; Type: TABLE; Schema: progress_tracking; Owner: postgres
--

CREATE TABLE progress_tracking.module_progress (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    module_id uuid NOT NULL,
    status public.progress_status DEFAULT 'not_started'::public.progress_status,
    progress_percentage integer DEFAULT 0,
    completed_exercises integer DEFAULT 0,
    total_exercises integer DEFAULT 0,
    skipped_exercises integer DEFAULT 0,
    total_score integer DEFAULT 0,
    max_possible_score integer,
    average_score numeric(5,2),
    best_score integer,
    total_xp_earned integer DEFAULT 0,
    total_ml_coins_earned integer DEFAULT 0,
    time_spent interval DEFAULT '00:00:00'::interval,
    sessions_count integer DEFAULT 0,
    attempts_count integer DEFAULT 0,
    hints_used_total integer DEFAULT 0,
    comodines_used_total integer DEFAULT 0,
    comodines_cost_total integer DEFAULT 0,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    last_accessed_at timestamp with time zone,
    deadline timestamp with time zone,
    classroom_id uuid,
    assignment_id uuid,
    allow_retry boolean DEFAULT true,
    sequential_completion boolean DEFAULT false,
    adaptive_difficulty boolean DEFAULT false,
    learning_path jsonb DEFAULT '[]'::jsonb,
    performance_analytics jsonb DEFAULT '{}'::jsonb,
    student_notes text,
    teacher_notes text,
    system_observations jsonb DEFAULT '{}'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT module_progress_progress_percentage_check CHECK (((progress_percentage >= 0) AND (progress_percentage <= 100)))
);


ALTER TABLE progress_tracking.module_progress OWNER TO postgres;

--
-- Name: TABLE module_progress; Type: COMMENT; Schema: progress_tracking; Owner: postgres
--

COMMENT ON TABLE progress_tracking.module_progress IS 'Progreso del estudiante por módulo - tracking completo de avance';


--
-- Name: COLUMN module_progress.status; Type: COMMENT; Schema: progress_tracking; Owner: postgres
--

COMMENT ON COLUMN progress_tracking.module_progress.status IS 'Estado: not_started, in_progress, completed, reviewed, mastered';


--
-- Name: module_progress module_progress_pkey; Type: CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.module_progress
    ADD CONSTRAINT module_progress_pkey PRIMARY KEY (id);


--
-- Name: module_progress module_progress_user_id_module_id_key; Type: CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.module_progress
    ADD CONSTRAINT module_progress_user_id_module_id_key UNIQUE (user_id, module_id);


--
-- Name: idx_module_progress_classroom; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_module_progress_classroom ON progress_tracking.module_progress USING btree (classroom_id);


--
-- Name: idx_module_progress_completed; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_module_progress_completed ON progress_tracking.module_progress USING btree (user_id, status) WHERE (status = 'completed'::public.progress_status);


--
-- Name: idx_module_progress_incomplete; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_module_progress_incomplete ON progress_tracking.module_progress USING btree (user_id, updated_at DESC) WHERE (status = ANY (ARRAY['not_started'::public.progress_status, 'in_progress'::public.progress_status]));


--
-- Name: idx_module_progress_module; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_module_progress_module ON progress_tracking.module_progress USING btree (module_id);


--
-- Name: idx_module_progress_status; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_module_progress_status ON progress_tracking.module_progress USING btree (status);


--
-- Name: idx_module_progress_user; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_module_progress_user ON progress_tracking.module_progress USING btree (user_id);


--
-- Name: idx_module_progress_user_status_updated; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_module_progress_user_status_updated ON progress_tracking.module_progress USING btree (user_id, status, updated_at DESC);


--
-- Name: module_progress trg_module_progress_updated_at; Type: TRIGGER; Schema: progress_tracking; Owner: postgres
--

CREATE TRIGGER trg_module_progress_updated_at BEFORE UPDATE ON progress_tracking.module_progress FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();


--
-- Name: module_progress module_progress_module_id_fkey; Type: FK CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.module_progress
    ADD CONSTRAINT module_progress_module_id_fkey FOREIGN KEY (module_id) REFERENCES educational_content.modules(id) ON DELETE CASCADE;


--
-- Name: module_progress module_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.module_progress
    ADD CONSTRAINT module_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id) ON DELETE CASCADE;


--
-- Name: module_progress module_progress_insert_own; Type: POLICY; Schema: progress_tracking; Owner: postgres
--

CREATE POLICY module_progress_insert_own ON progress_tracking.module_progress FOR INSERT WITH CHECK ((user_id = gamilit.get_current_user_id()));


--
-- Name: module_progress module_progress_select_admin; Type: POLICY; Schema: progress_tracking; Owner: postgres
--

CREATE POLICY module_progress_select_admin ON progress_tracking.module_progress FOR SELECT USING (gamilit.is_admin());


--
-- Name: module_progress module_progress_select_own; Type: POLICY; Schema: progress_tracking; Owner: postgres
--

CREATE POLICY module_progress_select_own ON progress_tracking.module_progress FOR SELECT USING ((user_id = gamilit.get_current_user_id()));


--
-- Name: module_progress module_progress_select_teacher; Type: POLICY; Schema: progress_tracking; Owner: postgres
--

CREATE POLICY module_progress_select_teacher ON progress_tracking.module_progress FOR SELECT USING (((gamilit.get_current_user_role() = 'admin_teacher'::public.gamilit_role) AND (EXISTS ( SELECT 1
   FROM (social_features.classroom_members cm
     JOIN social_features.classrooms c ON ((c.id = cm.classroom_id)))
  WHERE ((c.teacher_id = gamilit.get_current_user_id()) AND (cm.student_id = module_progress.user_id) AND (cm.status = 'active'::text))))));


--
-- Name: module_progress module_progress_update_own; Type: POLICY; Schema: progress_tracking; Owner: postgres
--

CREATE POLICY module_progress_update_own ON progress_tracking.module_progress FOR UPDATE USING ((user_id = gamilit.get_current_user_id()));


--
-- Name: TABLE module_progress; Type: ACL; Schema: progress_tracking; Owner: postgres
--

GRANT ALL ON TABLE progress_tracking.module_progress TO gamilit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict kbum8PVMgj5CLpUrEBeJlXIL8TxLp3qKyGRYM1icgHe84QAeAoEm90c4NVmH2oU

