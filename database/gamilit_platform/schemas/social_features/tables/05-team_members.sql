--
-- PostgreSQL database dump
--

\restrict FDdTzV8JI3U2pNHSEoCOcHtwue30lpFka1CJNnE1gaO6JblfcZpED1nCnhyvqLa

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
-- Name: team_members; Type: TABLE; Schema: social_features; Owner: postgres
--

CREATE TABLE social_features.team_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    team_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role character varying(20) DEFAULT 'member'::character varying NOT NULL,
    joined_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    left_at timestamp with time zone,
    CONSTRAINT team_members_role_check CHECK (((role)::text = ANY ((ARRAY['owner'::character varying, 'admin'::character varying, 'member'::character varying])::text[])))
);


ALTER TABLE social_features.team_members OWNER TO gamilit_user;

--
-- Name: TABLE team_members; Type: COMMENT; Schema: social_features; Owner: postgres
--

COMMENT ON TABLE social_features.team_members IS 'Miembros de equipos colaborativos';


--
-- Name: team_members team_members_pkey; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.team_members
    ADD CONSTRAINT team_members_pkey PRIMARY KEY (id);


--
-- Name: team_members team_members_team_id_user_id_key; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.team_members
    ADD CONSTRAINT team_members_team_id_user_id_key UNIQUE (team_id, user_id);


--
-- Name: idx_team_members_active; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_team_members_active ON social_features.team_members USING btree (team_id, user_id) WHERE (left_at IS NULL);


--
-- Name: idx_team_members_team_id; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_team_members_team_id ON social_features.team_members USING btree (team_id);


--
-- Name: idx_team_members_user_id; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_team_members_user_id ON social_features.team_members USING btree (user_id);


--
-- Name: team_members team_members_team_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.team_members
    ADD CONSTRAINT team_members_team_id_fkey FOREIGN KEY (team_id) REFERENCES social_features.teams(id) ON DELETE CASCADE;


--
-- Name: team_members team_members_user_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.team_members
    ADD CONSTRAINT team_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: TABLE team_members; Type: ACL; Schema: social_features; Owner: postgres
--

GRANT ALL ON TABLE social_features.team_members TO gamilit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict FDdTzV8JI3U2pNHSEoCOcHtwue30lpFka1CJNnE1gaO6JblfcZpED1nCnhyvqLa

