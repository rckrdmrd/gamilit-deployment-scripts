--
-- PostgreSQL database dump
--

\restrict 6J2QkxXkBpALX5f0jjonWdi5GHenC7H8EulqZo7sOSl7wbXCisFCQFrueuuU2vN

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
-- Name: achievements; Type: TABLE; Schema: gamification_system; Owner: postgres
--

CREATE TABLE gamification_system.achievements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    name text NOT NULL,
    description text,
    icon text DEFAULT 'trophy'::text,
    category public.achievement_category NOT NULL,
    rarity text DEFAULT 'common'::text,
    difficulty_level public.difficulty_level DEFAULT 'beginner'::public.difficulty_level,
    conditions jsonb DEFAULT '{"type": "progress", "requirements": {"exercises_completed": 10}}'::jsonb NOT NULL,
    rewards jsonb DEFAULT '{"xp": 100, "badge": null, "ml_coins": 50}'::jsonb,
    is_secret boolean DEFAULT false,
    is_active boolean DEFAULT true,
    is_repeatable boolean DEFAULT false,
    order_index integer DEFAULT 0,
    points_value integer DEFAULT 0,
    unlock_message text,
    instructions text,
    tips text[],
    metadata jsonb DEFAULT '{}'::jsonb,
    created_by uuid,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    ml_coins_reward integer DEFAULT 0,
    CONSTRAINT achievements_rarity_check CHECK ((rarity = ANY (ARRAY['common'::text, 'rare'::text, 'epic'::text, 'legendary'::text])))
);


ALTER TABLE gamification_system.achievements OWNER TO gamilit_user;

--
-- Name: TABLE achievements; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON TABLE gamification_system.achievements IS 'Definiciones de logros/achievements con condiciones y recompensas';


--
-- Name: COLUMN achievements.category; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.achievements.category IS 'Categoría: progress, streak, completion, social, special, mastery, exploration';


--
-- Name: COLUMN achievements.conditions; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.achievements.conditions IS 'Condiciones JSON para desbloquear el achievement';


--
-- Name: COLUMN achievements.is_secret; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.achievements.is_secret IS 'Si es true, el achievement está oculto hasta desbloquearlo';


--
-- Name: achievements achievements_pkey; Type: CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: idx_achievements_active; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_achievements_active ON gamification_system.achievements USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_achievements_category; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_achievements_category ON gamification_system.achievements USING btree (category);


--
-- Name: idx_achievements_conditions_gin; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_achievements_conditions_gin ON gamification_system.achievements USING gin (conditions);


--
-- Name: idx_achievements_secret; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_achievements_secret ON gamification_system.achievements USING btree (is_secret) WHERE (is_secret = true);


--
-- Name: achievements trg_achievements_updated_at; Type: TRIGGER; Schema: gamification_system; Owner: postgres
--

CREATE TRIGGER trg_achievements_updated_at BEFORE UPDATE ON gamification_system.achievements FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();


--
-- Name: achievements achievements_created_by_fkey; Type: FK CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.achievements
    ADD CONSTRAINT achievements_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth_management.profiles(id);


--
-- Name: achievements achievements_tenant_id_fkey; Type: FK CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.achievements
    ADD CONSTRAINT achievements_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;


--
-- Name: achievements achievements_all_admin; Type: POLICY; Schema: gamification_system; Owner: postgres
--

CREATE POLICY achievements_all_admin ON gamification_system.achievements USING (gamilit.is_admin());


--
-- Name: achievements achievements_select_active; Type: POLICY; Schema: gamification_system; Owner: postgres
--

CREATE POLICY achievements_select_active ON gamification_system.achievements FOR SELECT USING (((is_active = true) AND (is_secret = false)));


--
-- Name: achievements achievements_select_admin; Type: POLICY; Schema: gamification_system; Owner: postgres
--

CREATE POLICY achievements_select_admin ON gamification_system.achievements FOR SELECT USING (gamilit.is_admin());


--
-- Name: TABLE achievements; Type: ACL; Schema: gamification_system; Owner: postgres
--

GRANT ALL ON TABLE gamification_system.achievements TO gamilit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict 6J2QkxXkBpALX5f0jjonWdi5GHenC7H8EulqZo7sOSl7wbXCisFCQFrueuuU2vN

