--
-- PostgreSQL database dump
--

\restrict wVciFTIbyq5HScZ8MIJN4egWgiAXHQB8gKhGheLSYexeff8PJlMkL1hYhgzQj5y

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
-- Name: exercise_attempts; Type: TABLE; Schema: progress_tracking; Owner: postgres
--

CREATE TABLE progress_tracking.exercise_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    exercise_id uuid NOT NULL,
    attempt_number integer DEFAULT 1,
    submitted_answers jsonb NOT NULL,
    is_correct boolean,
    score integer,
    time_spent_seconds integer,
    hints_used integer DEFAULT 0,
    comodines_used jsonb DEFAULT '[]'::jsonb,
    xp_earned integer DEFAULT 0,
    ml_coins_earned integer DEFAULT 0,
    submitted_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    metadata jsonb DEFAULT '{"browser": null, "device_type": null, "response_pattern": []}'::jsonb,
    CONSTRAINT exercise_attempts_attempt_number_check CHECK ((attempt_number > 0)),
    CONSTRAINT exercise_attempts_score_check CHECK ((score >= 0))
);


ALTER TABLE progress_tracking.exercise_attempts OWNER TO postgres;

--
-- Name: TABLE exercise_attempts; Type: COMMENT; Schema: progress_tracking; Owner: postgres
--

COMMENT ON TABLE progress_tracking.exercise_attempts IS 'Intentos de ejercicios con respuestas, puntajes y uso de comodines';


--
-- Name: COLUMN exercise_attempts.comodines_used; Type: COMMENT; Schema: progress_tracking; Owner: postgres
--

COMMENT ON COLUMN progress_tracking.exercise_attempts.comodines_used IS 'Array de comodines usados: ["pistas", "vision_lectora"]';


--
-- Name: exercise_attempts exercise_attempts_pkey; Type: CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.exercise_attempts
    ADD CONSTRAINT exercise_attempts_pkey PRIMARY KEY (id);


--
-- Name: idx_exercise_attempts_exercise; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_exercise_attempts_exercise ON progress_tracking.exercise_attempts USING btree (exercise_id);


--
-- Name: idx_exercise_attempts_submitted; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_exercise_attempts_submitted ON progress_tracking.exercise_attempts USING btree (submitted_at DESC);


--
-- Name: idx_exercise_attempts_user; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_exercise_attempts_user ON progress_tracking.exercise_attempts USING btree (user_id);


--
-- Name: idx_exercise_attempts_user_exercise; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_exercise_attempts_user_exercise ON progress_tracking.exercise_attempts USING btree (user_id, exercise_id);


--
-- Name: idx_exercise_attempts_user_exercise_date; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_exercise_attempts_user_exercise_date ON progress_tracking.exercise_attempts USING btree (user_id, exercise_id, submitted_at DESC);


--
-- Name: exercise_attempts trg_update_user_stats_on_exercise; Type: TRIGGER; Schema: progress_tracking; Owner: postgres
--

CREATE TRIGGER trg_update_user_stats_on_exercise AFTER INSERT ON progress_tracking.exercise_attempts FOR EACH ROW EXECUTE FUNCTION gamilit.update_user_stats_on_exercise_complete();


--
-- Name: exercise_attempts exercise_attempts_exercise_id_fkey; Type: FK CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.exercise_attempts
    ADD CONSTRAINT exercise_attempts_exercise_id_fkey FOREIGN KEY (exercise_id) REFERENCES educational_content.exercises(id) ON DELETE CASCADE;


--
-- Name: exercise_attempts exercise_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.exercise_attempts
    ADD CONSTRAINT exercise_attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id) ON DELETE CASCADE;


--
-- Name: exercise_attempts exercise_attempts_insert_own; Type: POLICY; Schema: progress_tracking; Owner: postgres
--

CREATE POLICY exercise_attempts_insert_own ON progress_tracking.exercise_attempts FOR INSERT WITH CHECK ((user_id = gamilit.get_current_user_id()));


--
-- Name: exercise_attempts exercise_attempts_select_admin; Type: POLICY; Schema: progress_tracking; Owner: postgres
--

CREATE POLICY exercise_attempts_select_admin ON progress_tracking.exercise_attempts FOR SELECT USING (gamilit.is_admin());


--
-- Name: exercise_attempts exercise_attempts_select_own; Type: POLICY; Schema: progress_tracking; Owner: postgres
--

CREATE POLICY exercise_attempts_select_own ON progress_tracking.exercise_attempts FOR SELECT USING ((user_id = gamilit.get_current_user_id()));


--
-- Name: exercise_attempts exercise_attempts_select_teacher; Type: POLICY; Schema: progress_tracking; Owner: postgres
--

CREATE POLICY exercise_attempts_select_teacher ON progress_tracking.exercise_attempts FOR SELECT USING (((gamilit.get_current_user_role() = 'admin_teacher'::public.gamilit_role) AND (EXISTS ( SELECT 1
   FROM (social_features.classroom_members cm
     JOIN social_features.classrooms c ON ((c.id = cm.classroom_id)))
  WHERE ((c.teacher_id = gamilit.get_current_user_id()) AND (cm.student_id = exercise_attempts.user_id))))));


--
-- Name: TABLE exercise_attempts; Type: ACL; Schema: progress_tracking; Owner: postgres
--

GRANT ALL ON TABLE progress_tracking.exercise_attempts TO gamilit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict wVciFTIbyq5HScZ8MIJN4egWgiAXHQB8gKhGheLSYexeff8PJlMkL1hYhgzQj5y

