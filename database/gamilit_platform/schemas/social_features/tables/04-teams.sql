--
-- PostgreSQL database dump
--

\restrict AVkh11wxJU1xQZUEkt14ZM1e1ddrRBjX1z3ynl1VDfHzdppS7VfgyOAgbp1BFzT

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
-- Name: teams; Type: TABLE; Schema: social_features; Owner: postgres
--

CREATE TABLE social_features.teams (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    classroom_id uuid,
    tenant_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    motto text,
    color_primary text DEFAULT '#3B82F6'::text,
    color_secondary text DEFAULT '#10B981'::text,
    avatar_url text,
    banner_url text,
    badges jsonb DEFAULT '[]'::jsonb,
    creator_id uuid NOT NULL,
    leader_id uuid,
    team_code text,
    max_members integer DEFAULT 5,
    current_members_count integer DEFAULT 0,
    is_public boolean DEFAULT false,
    allow_join_requests boolean DEFAULT true,
    require_approval boolean DEFAULT true,
    total_xp integer DEFAULT 0,
    total_ml_coins integer DEFAULT 0,
    modules_completed integer DEFAULT 0,
    achievements_earned integer DEFAULT 0,
    is_active boolean DEFAULT true,
    is_verified boolean DEFAULT false,
    founded_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    last_activity_at timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico()
);


ALTER TABLE social_features.teams OWNER TO gamilit_user;

--
-- Name: TABLE teams; Type: COMMENT; Schema: social_features; Owner: postgres
--

COMMENT ON TABLE social_features.teams IS 'Equipos colaborativos de estudiantes';


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: teams teams_team_code_key; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.teams
    ADD CONSTRAINT teams_team_code_key UNIQUE (team_code);


--
-- Name: idx_teams_active; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_teams_active ON social_features.teams USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_teams_classroom; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_teams_classroom ON social_features.teams USING btree (classroom_id);


--
-- Name: idx_teams_classroom_active_xp; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_teams_classroom_active_xp ON social_features.teams USING btree (classroom_id, is_active, total_xp DESC) WHERE (is_active = true);


--
-- Name: idx_teams_leader; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_teams_leader ON social_features.teams USING btree (leader_id);


--
-- Name: idx_teams_xp; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_teams_xp ON social_features.teams USING btree (total_xp DESC);


--
-- Name: teams trg_teams_updated_at; Type: TRIGGER; Schema: social_features; Owner: postgres
--

CREATE TRIGGER trg_teams_updated_at BEFORE UPDATE ON social_features.teams FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();


--
-- Name: teams teams_classroom_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.teams
    ADD CONSTRAINT teams_classroom_id_fkey FOREIGN KEY (classroom_id) REFERENCES social_features.classrooms(id) ON DELETE CASCADE;


--
-- Name: teams teams_creator_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.teams
    ADD CONSTRAINT teams_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES auth_management.profiles(id);


--
-- Name: teams teams_leader_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.teams
    ADD CONSTRAINT teams_leader_id_fkey FOREIGN KEY (leader_id) REFERENCES auth_management.profiles(id);


--
-- Name: teams teams_tenant_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.teams
    ADD CONSTRAINT teams_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;


--
-- Name: teams; Type: ROW SECURITY; Schema: social_features; Owner: postgres
--

ALTER TABLE social_features.teams ENABLE ROW LEVEL SECURITY;

--
-- Name: TABLE teams; Type: ACL; Schema: social_features; Owner: postgres
--

GRANT ALL ON TABLE social_features.teams TO gamilit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict AVkh11wxJU1xQZUEkt14ZM1e1ddrRBjX1z3ynl1VDfHzdppS7VfgyOAgbp1BFzT

