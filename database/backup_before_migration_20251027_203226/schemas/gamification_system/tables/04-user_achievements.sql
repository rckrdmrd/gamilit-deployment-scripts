--
-- PostgreSQL database dump
--

\restrict qgsapznIPwhDZ0SllkJ2wANy5lIsyf28sGULf4vFSlU8KVpmRQOD0aFC5HNxLWN

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
-- Name: user_achievements; Type: TABLE; Schema: gamification_system; Owner: postgres
--

CREATE TABLE gamification_system.user_achievements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    achievement_id uuid NOT NULL,
    progress integer DEFAULT 0,
    max_progress integer DEFAULT 100,
    is_completed boolean DEFAULT false,
    completion_percentage numeric(5,2) DEFAULT 0.00,
    completed_at timestamp with time zone,
    notified boolean DEFAULT false,
    viewed boolean DEFAULT false,
    rewards_claimed boolean DEFAULT false,
    rewards_received jsonb DEFAULT '{}'::jsonb,
    progress_data jsonb DEFAULT '{}'::jsonb,
    milestones_reached text[],
    metadata jsonb DEFAULT '{}'::jsonb,
    started_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT user_achievements_progress_check CHECK ((progress >= 0))
);


ALTER TABLE gamification_system.user_achievements OWNER TO postgres;

--
-- Name: TABLE user_achievements; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON TABLE gamification_system.user_achievements IS 'Achievements desbloqueados por usuario con progreso y recompensas';


--
-- Name: COLUMN user_achievements.progress; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.user_achievements.progress IS 'Progreso actual hacia el achievement';


--
-- Name: COLUMN user_achievements.rewards_claimed; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.user_achievements.rewards_claimed IS 'True si el usuario ya reclamó las recompensas';


--
-- Name: user_achievements user_achievements_pkey; Type: CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.user_achievements
    ADD CONSTRAINT user_achievements_pkey PRIMARY KEY (id);


--
-- Name: user_achievements user_achievements_user_id_achievement_id_key; Type: CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.user_achievements
    ADD CONSTRAINT user_achievements_user_id_achievement_id_key UNIQUE (user_id, achievement_id);


--
-- Name: idx_user_achievements_achievement_id; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_achievements_achievement_id ON gamification_system.user_achievements USING btree (achievement_id);


--
-- Name: idx_user_achievements_completed; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_achievements_completed ON gamification_system.user_achievements USING btree (user_id, is_completed);


--
-- Name: idx_user_achievements_unclaimed; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_achievements_unclaimed ON gamification_system.user_achievements USING btree (user_id) WHERE ((is_completed = true) AND (rewards_claimed = false));


--
-- Name: idx_user_achievements_user_completed; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_achievements_user_completed ON gamification_system.user_achievements USING btree (user_id, is_completed, completed_at);


--
-- Name: idx_user_achievements_user_id; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_achievements_user_id ON gamification_system.user_achievements USING btree (user_id);


--
-- Name: user_achievements user_achievements_achievement_id_fkey; Type: FK CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.user_achievements
    ADD CONSTRAINT user_achievements_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES gamification_system.achievements(id) ON DELETE CASCADE;


--
-- Name: user_achievements user_achievements_user_id_fkey; Type: FK CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.user_achievements
    ADD CONSTRAINT user_achievements_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id) ON DELETE CASCADE;


--
-- Name: user_achievements user_achievements_select_admin; Type: POLICY; Schema: gamification_system; Owner: postgres
--

CREATE POLICY user_achievements_select_admin ON gamification_system.user_achievements FOR SELECT USING (gamilit.is_admin());


--
-- Name: user_achievements user_achievements_select_own; Type: POLICY; Schema: gamification_system; Owner: postgres
--

CREATE POLICY user_achievements_select_own ON gamification_system.user_achievements FOR SELECT USING ((user_id = gamilit.get_current_user_id()));


--
-- Name: TABLE user_achievements; Type: ACL; Schema: gamification_system; Owner: postgres
--

GRANT ALL ON TABLE gamification_system.user_achievements TO glit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict qgsapznIPwhDZ0SllkJ2wANy5lIsyf28sGULf4vFSlU8KVpmRQOD0aFC5HNxLWN

