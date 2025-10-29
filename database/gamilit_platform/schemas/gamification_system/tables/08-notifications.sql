--
-- PostgreSQL database dump
--

\restrict FdwVQAkdhU1Jxr218lV8bnvN6N1NgEpkvs1wtEgWfo8YAS8iltwbPnF2XOeFGFE

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
-- Name: notifications; Type: TABLE; Schema: gamification_system; Owner: postgres
--

CREATE TABLE gamification_system.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    type text NOT NULL,
    title text NOT NULL,
    message text NOT NULL,
    data jsonb,
    read boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT notifications_type_check CHECK ((type = ANY (ARRAY['achievement'::text, 'mission'::text, 'reward'::text, 'system'::text, 'social'::text, 'educational'::text])))
);


ALTER TABLE gamification_system.notifications OWNER TO gamilit_user;

--
-- Name: TABLE notifications; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON TABLE gamification_system.notifications IS 'User notifications for various system events';


--
-- Name: COLUMN notifications.type; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.notifications.type IS 'Type of notification: achievement, mission, reward, system, social, educational';


--
-- Name: COLUMN notifications.data; Type: COMMENT; Schema: gamification_system; Owner: postgres
--

COMMENT ON COLUMN gamification_system.notifications.data IS 'Additional notification data in JSON format';


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: idx_notifications_created_at; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_notifications_created_at ON gamification_system.notifications USING btree (created_at DESC);


--
-- Name: idx_notifications_type; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_notifications_type ON gamification_system.notifications USING btree (type);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_notifications_user_id ON gamification_system.notifications USING btree (user_id);


--
-- Name: idx_notifications_user_read; Type: INDEX; Schema: gamification_system; Owner: postgres
--

CREATE INDEX idx_notifications_user_read ON gamification_system.notifications USING btree (user_id, read);


--
-- Name: notifications notifications_updated_at; Type: TRIGGER; Schema: gamification_system; Owner: postgres
--

CREATE TRIGGER notifications_updated_at BEFORE UPDATE ON gamification_system.notifications FOR EACH ROW EXECUTE FUNCTION gamification_system.update_notifications_updated_at();


--
-- Name: notifications fk_notifications_user; Type: FK CONSTRAINT; Schema: gamification_system; Owner: postgres
--

ALTER TABLE ONLY gamification_system.notifications
    ADD CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES auth_management.profiles(id) ON DELETE CASCADE;


--
-- Name: TABLE notifications; Type: ACL; Schema: gamification_system; Owner: postgres
--

GRANT ALL ON TABLE gamification_system.notifications TO gamilit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict FdwVQAkdhU1Jxr218lV8bnvN6N1NgEpkvs1wtEgWfo8YAS8iltwbPnF2XOeFGFE

