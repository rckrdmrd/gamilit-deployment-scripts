--
-- PostgreSQL database dump
--

\restrict cnrNfHcto9l4Zw1gf8bWfVXccB7G1i4i3178nVMdiGq3gZJVLDPQMi9wlfsmQLg

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
-- Name: exercise_submissions; Type: TABLE; Schema: progress_tracking; Owner: postgres
--

CREATE TABLE progress_tracking.exercise_submissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    exercise_id uuid NOT NULL,
    answer_data jsonb NOT NULL,
    is_correct boolean,
    score integer DEFAULT 0,
    max_score integer DEFAULT 100,
    feedback text,
    hint_used boolean DEFAULT false,
    hints_count integer DEFAULT 0,
    comodines_used text[],
    ml_coins_spent integer DEFAULT 0,
    time_spent_seconds integer,
    attempt_number integer DEFAULT 1,
    status text DEFAULT 'submitted'::text,
    started_at timestamp with time zone,
    submitted_at timestamp with time zone DEFAULT now(),
    graded_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT check_score_range CHECK (((score >= 0) AND (score <= max_score))),
    CONSTRAINT exercise_submissions_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'submitted'::text, 'graded'::text, 'reviewed'::text])))
);


ALTER TABLE progress_tracking.exercise_submissions OWNER TO postgres;

--
-- Name: TABLE exercise_submissions; Type: COMMENT; Schema: progress_tracking; Owner: postgres
--

COMMENT ON TABLE progress_tracking.exercise_submissions IS 'Student exercise submissions and attempts';


--
-- Name: COLUMN exercise_submissions.answer_data; Type: COMMENT; Schema: progress_tracking; Owner: postgres
--

COMMENT ON COLUMN progress_tracking.exercise_submissions.answer_data IS 'Student answer in JSON format';


--
-- Name: COLUMN exercise_submissions.comodines_used; Type: COMMENT; Schema: progress_tracking; Owner: postgres
--

COMMENT ON COLUMN progress_tracking.exercise_submissions.comodines_used IS 'Array of comodin types used (pistas, vision_lectora, etc)';


--
-- Name: exercise_submissions exercise_submissions_pkey; Type: CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.exercise_submissions
    ADD CONSTRAINT exercise_submissions_pkey PRIMARY KEY (id);


--
-- Name: idx_exercise_submissions_exercise_id; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_exercise_submissions_exercise_id ON progress_tracking.exercise_submissions USING btree (exercise_id);


--
-- Name: idx_exercise_submissions_status; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_exercise_submissions_status ON progress_tracking.exercise_submissions USING btree (status);


--
-- Name: idx_exercise_submissions_submitted_at; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_exercise_submissions_submitted_at ON progress_tracking.exercise_submissions USING btree (submitted_at DESC);


--
-- Name: idx_exercise_submissions_user_exercise; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_exercise_submissions_user_exercise ON progress_tracking.exercise_submissions USING btree (user_id, exercise_id);


--
-- Name: idx_exercise_submissions_user_id; Type: INDEX; Schema: progress_tracking; Owner: postgres
--

CREATE INDEX idx_exercise_submissions_user_id ON progress_tracking.exercise_submissions USING btree (user_id);


--
-- Name: exercise_submissions exercise_submissions_updated_at; Type: TRIGGER; Schema: progress_tracking; Owner: postgres
--

CREATE TRIGGER exercise_submissions_updated_at BEFORE UPDATE ON progress_tracking.exercise_submissions FOR EACH ROW EXECUTE FUNCTION progress_tracking.update_exercise_submissions_updated_at();


--
-- Name: exercise_submissions fk_exercise_submissions_exercise; Type: FK CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.exercise_submissions
    ADD CONSTRAINT fk_exercise_submissions_exercise FOREIGN KEY (exercise_id) REFERENCES educational_content.exercises(id) ON DELETE CASCADE;


--
-- Name: exercise_submissions fk_exercise_submissions_user; Type: FK CONSTRAINT; Schema: progress_tracking; Owner: postgres
--

ALTER TABLE ONLY progress_tracking.exercise_submissions
    ADD CONSTRAINT fk_exercise_submissions_user FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id) ON DELETE CASCADE;


--
-- Name: TABLE exercise_submissions; Type: ACL; Schema: progress_tracking; Owner: postgres
--

GRANT ALL ON TABLE progress_tracking.exercise_submissions TO glit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict cnrNfHcto9l4Zw1gf8bWfVXccB7G1i4i3178nVMdiGq3gZJVLDPQMi9wlfsmQLg

