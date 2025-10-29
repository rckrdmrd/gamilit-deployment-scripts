--
-- PostgreSQL database dump
--

\restrict 2aPgN7u9Z6hmntzIOKt7Cb2Mu1JOKJl6mw64DTkZOT3ceWtQFRnj9GGVHXoQLei

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
-- Name: team_challenges; Type: TABLE; Schema: social_features; Owner: postgres
--

CREATE TABLE social_features.team_challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    team_id uuid NOT NULL,
    challenge_id uuid NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying NOT NULL,
    started_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    completed_at timestamp with time zone,
    score integer DEFAULT 0,
    CONSTRAINT team_challenges_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'in_progress'::character varying, 'completed'::character varying, 'failed'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE social_features.team_challenges OWNER TO gamilit_user;

--
-- Name: TABLE team_challenges; Type: COMMENT; Schema: social_features; Owner: postgres
--

COMMENT ON TABLE social_features.team_challenges IS 'Desafíos asignados a equipos';


--
-- Name: team_challenges team_challenges_pkey; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.team_challenges
    ADD CONSTRAINT team_challenges_pkey PRIMARY KEY (id);


--
-- Name: team_challenges team_challenges_team_id_challenge_id_key; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.team_challenges
    ADD CONSTRAINT team_challenges_team_id_challenge_id_key UNIQUE (team_id, challenge_id);


--
-- Name: idx_team_challenges_challenge_id; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_team_challenges_challenge_id ON social_features.team_challenges USING btree (challenge_id);


--
-- Name: idx_team_challenges_status; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_team_challenges_status ON social_features.team_challenges USING btree (status);


--
-- Name: idx_team_challenges_team_id; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_team_challenges_team_id ON social_features.team_challenges USING btree (team_id);


--
-- Name: team_challenges team_challenges_team_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.team_challenges
    ADD CONSTRAINT team_challenges_team_id_fkey FOREIGN KEY (team_id) REFERENCES social_features.teams(id) ON DELETE CASCADE;


--
-- Name: TABLE team_challenges; Type: ACL; Schema: social_features; Owner: postgres
--

GRANT ALL ON TABLE social_features.team_challenges TO gamilit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict 2aPgN7u9Z6hmntzIOKt7Cb2Mu1JOKJl6mw64DTkZOT3ceWtQFRnj9GGVHXoQLei

