--
-- PostgreSQL database dump
--

\restrict Zr1ruTbRYQXxryfHVVmqpYgkcmJ5F3L12cojUzbadGLB9yTqwq9SYqcXSeU6rVp

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
-- Name: user_stats; Type: TABLE; Schema: gamification_system; Owner: postgres
--

CREATE TABLE gamification_system.user_stats (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid,
    level integer DEFAULT 1,
    total_xp integer DEFAULT 0,
    xp_to_next_level integer DEFAULT 100,
    ml_coins integer DEFAULT 100,
    ml_coins_earned_total integer DEFAULT 100,
    ml_coins_spent_total integer DEFAULT 0,
    ml_coins_earned_today integer DEFAULT 0,
    current_streak integer DEFAULT 0,
    max_streak integer DEFAULT 0,
    days_active_total integer DEFAULT 0,
    exercises_completed integer DEFAULT 0,
    modules_completed integer DEFAULT 0,
    total_score integer DEFAULT 0,
    average_score numeric(5,2),
    achievements_earned integer DEFAULT 0,
    certificates_earned integer DEFAULT 0,
    total_time_spent interval DEFAULT '00:00:00'::interval,
    weekly_time_spent interval DEFAULT '00:00:00'::interval,
    sessions_count integer DEFAULT 0,
    weekly_xp integer DEFAULT 0,
    monthly_xp integer DEFAULT 0,
    weekly_exercises integer DEFAULT 0,
    global_rank_position integer,
    class_rank_position integer,
    school_rank_position integer,
    last_activity_at timestamp with time zone,
    last_ml_coins_reset timestamp with time zone,
    streak_started_at timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    last_login_at timestamp with time zone,
    CONSTRAINT user_stats_current_streak_check CHECK ((current_streak >= 0)),
    CONSTRAINT user_stats_exercises_completed_check CHECK ((exercises_completed >= 0)),
    CONSTRAINT user_stats_level_check CHECK ((level > 0)),
    CONSTRAINT user_stats_max_streak_check CHECK ((max_streak >= 0)),
    CONSTRAINT user_stats_ml_coins_check CHECK ((ml_coins >= 0)),
    CONSTRAINT user_stats_ml_coins_earned_total_check CHECK ((ml_coins_earned_total >= 0)),
    CONSTRAINT user_stats_ml_coins_spent_total_check CHECK ((ml_coins_spent_total >= 0)),
    CONSTRAINT user_stats_modules_completed_check CHECK ((modules_completed >= 0)),
    CONSTRAINT user_stats_total_xp_check CHECK ((total_xp >= 0))
);


ALTER TABLE gamification_system.user_stats OWNER TO postgres;

--
-- Name: TABLE user_stats; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON TABLE gamification_system.user_stats IS 'Estadísticas de gamificación por usuario - ML Coins, XP, streaks, rankings';


--
-- Name: COLUMN user_stats.xp_to_next_level; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.user_stats.xp_to_next_level IS 'XP necesaria para alcanzar el siguiente nivel';


--
-- Name: COLUMN user_stats.ml_coins; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.user_stats.ml_coins IS 'Monedas ML actuales del usuario (balance actual)';


--
-- Name: COLUMN user_stats.current_streak; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.user_stats.current_streak IS 'Racha de días consecutivos activa';


--
-- Name: user_stats user_stats_pkey; Type: CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.user_stats
    ADD CONSTRAINT user_stats_pkey PRIMARY KEY (id);


--
-- Name: user_stats user_stats_user_id_key; Type: CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.user_stats
    ADD CONSTRAINT user_stats_user_id_key UNIQUE (user_id);


--
-- Name: idx_user_stats_global_rank; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_stats_global_rank ON gamification_system.user_stats USING btree (global_rank_position) WHERE (global_rank_position IS NOT NULL);


--
-- Name: idx_user_stats_level; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_stats_level ON gamification_system.user_stats USING btree (level);


--
-- Name: idx_user_stats_ml_coins; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_stats_ml_coins ON gamification_system.user_stats USING btree (ml_coins);


--
-- Name: idx_user_stats_streak; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_stats_streak ON gamification_system.user_stats USING btree (current_streak DESC);


--
-- Name: idx_user_stats_tenant_id; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_stats_tenant_id ON gamification_system.user_stats USING btree (tenant_id);


--
-- Name: idx_user_stats_tenant_level; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_stats_tenant_level ON gamification_system.user_stats USING btree (tenant_id, level DESC);


--
-- Name: idx_user_stats_user_id; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_stats_user_id ON gamification_system.user_stats USING btree (user_id);


--
-- Name: user_stats trg_user_stats_updated_at; Type: TRIGGER; Schema: gamification_system; Owner: postgres
--

CREATE TRIGGER trg_user_stats_updated_at BEFORE UPDATE ON gamification_system.user_stats FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();


--
-- Name: user_stats user_stats_tenant_id_fkey; Type: FK CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.user_stats
    ADD CONSTRAINT user_stats_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;


--
-- Name: user_stats user_stats_user_id_fkey; Type: FK CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.user_stats
    ADD CONSTRAINT user_stats_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: user_stats user_stats_select_admin; Type: POLICY; Schema: gamification_system; Owner: postgres
--

CREATE POLICY user_stats_select_admin ON gamification_system.user_stats FOR SELECT USING (gamilit.is_admin());


--
-- Name: user_stats user_stats_select_own; Type: POLICY; Schema: gamification_system; Owner: postgres
--

CREATE POLICY user_stats_select_own ON gamification_system.user_stats FOR SELECT USING ((user_id = gamilit.get_current_user_id()));


--
-- Name: user_stats user_stats_update_system; Type: POLICY; Schema: gamification_system; Owner: postgres
--

CREATE POLICY user_stats_update_system ON gamification_system.user_stats FOR UPDATE USING (true);


--
-- Name: TABLE user_stats; Type: ACL; Schema: gamification_system; Owner: postgres
--

GRANT ALL ON TABLE gamification_system.user_stats TO gamilit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict Zr1ruTbRYQXxryfHVVmqpYgkcmJ5F3L12cojUzbadGLB9yTqwq9SYqcXSeU6rVp

