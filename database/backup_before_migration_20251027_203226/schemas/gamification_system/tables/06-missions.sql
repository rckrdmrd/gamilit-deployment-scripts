--
-- PostgreSQL database dump
--

\restrict AtJnEXbedjz5RJkwhkmbMAdXQ81QPMgVQKHrTDaYVvJTYy6jFNJ7YcV0ITYqEfh

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
-- Name: missions; Type: TABLE; Schema: gamification_system; Owner: postgres
--

CREATE TABLE gamification_system.missions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    template_id text NOT NULL,
    title text NOT NULL,
    description text,
    mission_type text NOT NULL,
    objectives jsonb NOT NULL,
    rewards jsonb NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    progress double precision DEFAULT 0 NOT NULL,
    start_date timestamp without time zone DEFAULT now() NOT NULL,
    end_date timestamp without time zone NOT NULL,
    completed_at timestamp without time zone,
    claimed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT missions_mission_type_check CHECK ((mission_type = ANY (ARRAY['daily'::text, 'weekly'::text, 'special'::text]))),
    CONSTRAINT missions_progress_check CHECK (((progress >= (0)::double precision) AND (progress <= (100)::double precision))),
    CONSTRAINT missions_status_check CHECK ((status = ANY (ARRAY['active'::text, 'in_progress'::text, 'completed'::text, 'claimed'::text, 'expired'::text])))
);


ALTER TABLE gamification_system.missions OWNER TO postgres;

--
-- Name: TABLE missions; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON TABLE gamification_system.missions IS 'User missions/quests with objectives and rewards';


--
-- Name: COLUMN missions.template_id; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.missions.template_id IS 'Reference to mission template ID';


--
-- Name: COLUMN missions.objectives; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.missions.objectives IS 'JSON array of objectives with type, target, and current progress';


--
-- Name: COLUMN missions.rewards; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.missions.rewards IS 'JSON object with ml_coins, xp, and optional items';


--
-- Name: COLUMN missions.status; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.missions.status IS 'Mission lifecycle status';


--
-- Name: COLUMN missions.progress; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.missions.progress IS 'Overall completion percentage (0-100)';


--
-- Name: missions missions_pkey; Type: CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.missions
    ADD CONSTRAINT missions_pkey PRIMARY KEY (id);


--
-- Name: idx_missions_end_date; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_missions_end_date ON gamification_system.missions USING btree (end_date);


--
-- Name: idx_missions_status; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_missions_status ON gamification_system.missions USING btree (status);


--
-- Name: idx_missions_template_id; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_missions_template_id ON gamification_system.missions USING btree (template_id);


--
-- Name: idx_missions_type; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_missions_type ON gamification_system.missions USING btree (mission_type);


--
-- Name: idx_missions_user_id; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_missions_user_id ON gamification_system.missions USING btree (user_id);


--
-- Name: idx_missions_user_type_status; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_missions_user_type_status ON gamification_system.missions USING btree (user_id, mission_type, status);


--
-- Name: missions missions_updated_at; Type: TRIGGER; Schema: gamification_system; Owner: postgres
--

CREATE TRIGGER missions_updated_at BEFORE UPDATE ON gamification_system.missions FOR EACH ROW EXECUTE FUNCTION gamification_system.update_missions_updated_at();


--
-- Name: TABLE missions; Type: ACL; Schema: gamification_system; Owner: postgres
--

GRANT ALL ON TABLE gamification_system.missions TO glit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict AtJnEXbedjz5RJkwhkmbMAdXQ81QPMgVQKHrTDaYVvJTYy6jFNJ7YcV0ITYqEfh

