--
-- PostgreSQL database dump
--

\restrict JkMoCHhPfMAoUUjiHRVs5mrWGjZPO4gttGfaijbbJrTDYsPb3qEmbfVky6kxADf

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
-- Name: user_ranks; Type: TABLE; Schema: gamification_system; Owner: postgres
--

CREATE TABLE gamification_system.user_ranks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid,
    current_rank maya_rank DEFAULT 'mercenario'::maya_rank NOT NULL,
    previous_rank maya_rank,
    rank_progress_percentage integer DEFAULT 0,
    modules_required_for_next integer,
    modules_completed_for_rank integer DEFAULT 0,
    xp_required_for_next integer,
    xp_earned_for_rank integer DEFAULT 0,
    ml_coins_bonus integer DEFAULT 0,
    certificate_url text,
    badge_url text,
    achieved_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    previous_rank_achieved_at timestamp with time zone,
    is_current boolean DEFAULT true,
    rank_metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT user_ranks_rank_progress_percentage_check CHECK (((rank_progress_percentage >= 0) AND (rank_progress_percentage <= 100)))
);


ALTER TABLE gamification_system.user_ranks OWNER TO postgres;

--
-- Name: TABLE user_ranks; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON TABLE gamification_system.user_ranks IS 'Progresión de rangos maya: NACOM → BATAB → HOLCATTE → GUERRERO → MERCENARIO';


--
-- Name: COLUMN user_ranks.current_rank; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.user_ranks.current_rank IS 'Rango maya actual del usuario';


--
-- Name: COLUMN user_ranks.ml_coins_bonus; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.user_ranks.ml_coins_bonus IS 'Bonus de ML Coins otorgado al alcanzar el rango';


--
-- Name: user_ranks user_ranks_pkey; Type: CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.user_ranks
    ADD CONSTRAINT user_ranks_pkey PRIMARY KEY (id);


--
-- Name: idx_user_ranks_current; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_ranks_current ON gamification_system.user_ranks USING btree (current_rank);


--
-- Name: idx_user_ranks_is_current; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_ranks_is_current ON gamification_system.user_ranks USING btree (user_id, is_current) WHERE (is_current = true);


--
-- Name: idx_user_ranks_user_id; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_user_ranks_user_id ON gamification_system.user_ranks USING btree (user_id);


--
-- Name: user_ranks trg_user_ranks_updated_at; Type: TRIGGER; Schema: gamification_system; Owner: postgres
--

CREATE TRIGGER trg_user_ranks_updated_at BEFORE UPDATE ON gamification_system.user_ranks FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();


--
-- Name: user_ranks user_ranks_tenant_id_fkey; Type: FK CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.user_ranks
    ADD CONSTRAINT user_ranks_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;


--
-- Name: user_ranks user_ranks_user_id_fkey; Type: FK CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.user_ranks
    ADD CONSTRAINT user_ranks_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: TABLE user_ranks; Type: ACL; Schema: gamification_system; Owner: postgres
--

GRANT ALL ON TABLE gamification_system.user_ranks TO gamilit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict JkMoCHhPfMAoUUjiHRVs5mrWGjZPO4gttGfaijbbJrTDYsPb3qEmbfVky6kxADf

