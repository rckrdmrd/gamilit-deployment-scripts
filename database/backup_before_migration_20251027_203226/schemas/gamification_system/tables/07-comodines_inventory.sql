--
-- PostgreSQL database dump
--

\restrict m4i6K1kzuaLf6QGzMPZ2WZ8F1XeaierVDJJwutgbzn9Ihi9adFfs8mjo0GV2U7V

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
-- Name: comodines_inventory; Type: TABLE; Schema: gamification_system; Owner: postgres
--

CREATE TABLE gamification_system.comodines_inventory (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    pistas_available integer DEFAULT 0,
    vision_lectora_available integer DEFAULT 0,
    segunda_oportunidad_available integer DEFAULT 0,
    pistas_purchased_total integer DEFAULT 0,
    vision_lectora_purchased_total integer DEFAULT 0,
    segunda_oportunidad_purchased_total integer DEFAULT 0,
    pistas_used_total integer DEFAULT 0,
    vision_lectora_used_total integer DEFAULT 0,
    segunda_oportunidad_used_total integer DEFAULT 0,
    pistas_cost integer DEFAULT 15,
    vision_lectora_cost integer DEFAULT 25,
    segunda_oportunidad_cost integer DEFAULT 40,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT comodines_inventory_pistas_available_check CHECK ((pistas_available >= 0)),
    CONSTRAINT comodines_inventory_segunda_oportunidad_available_check CHECK ((segunda_oportunidad_available >= 0)),
    CONSTRAINT comodines_inventory_vision_lectora_available_check CHECK ((vision_lectora_available >= 0))
);


ALTER TABLE gamification_system.comodines_inventory OWNER TO postgres;

--
-- Name: TABLE comodines_inventory; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON TABLE gamification_system.comodines_inventory IS 'Inventario de comodines (power-ups) por usuario';


--
-- Name: COLUMN comodines_inventory.pistas_available; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.comodines_inventory.pistas_available IS 'Pistas Contextuales disponibles (15 ML Coins)';


--
-- Name: COLUMN comodines_inventory.vision_lectora_available; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.comodines_inventory.vision_lectora_available IS 'Visión Lectora disponibles (25 ML Coins)';


--
-- Name: COLUMN comodines_inventory.segunda_oportunidad_available; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.comodines_inventory.segunda_oportunidad_available IS 'Segunda Oportunidad disponibles (40 ML Coins)';


--
-- Name: comodines_inventory comodines_inventory_pkey; Type: CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.comodines_inventory
    ADD CONSTRAINT comodines_inventory_pkey PRIMARY KEY (id);


--
-- Name: comodines_inventory comodines_inventory_user_id_key; Type: CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.comodines_inventory
    ADD CONSTRAINT comodines_inventory_user_id_key UNIQUE (user_id);


--
-- Name: idx_comodines_user_id; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_comodines_user_id ON gamification_system.comodines_inventory USING btree (user_id);


--
-- Name: comodines_inventory trg_comodines_inventory_updated_at; Type: TRIGGER; Schema: gamification_system; Owner: postgres
--

CREATE TRIGGER trg_comodines_inventory_updated_at BEFORE UPDATE ON gamification_system.comodines_inventory FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();


--
-- Name: comodines_inventory comodines_inventory_user_id_fkey; Type: FK CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.comodines_inventory
    ADD CONSTRAINT comodines_inventory_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id) ON DELETE CASCADE;


--
-- Name: TABLE comodines_inventory; Type: ACL; Schema: gamification_system; Owner: postgres
--

GRANT ALL ON TABLE gamification_system.comodines_inventory TO glit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict m4i6K1kzuaLf6QGzMPZ2WZ8F1XeaierVDJJwutgbzn9Ihi9adFfs8mjo0GV2U7V

