--
-- PostgreSQL database dump
--

\restrict osJUvm0AzJPenTlRRivBE9S1J1JMuLiwfvOr9pjcbYRe0UXUcZb4MtyDLjwc52u

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
-- Name: friendships; Type: TABLE; Schema: social_features; Owner: postgres
--

CREATE TABLE social_features.friendships (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    friend_id uuid NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT friendships_check CHECK ((user_id <> friend_id)),
    CONSTRAINT friendships_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'accepted'::character varying, 'rejected'::character varying, 'blocked'::character varying])::text[])))
);


ALTER TABLE social_features.friendships OWNER TO gamilit_user;

--
-- Name: TABLE friendships; Type: COMMENT; Schema: social_features; Owner: postgres
--

COMMENT ON TABLE social_features.friendships IS 'Relaciones de amistad entre usuarios';


--
-- Name: friendships friendships_pkey; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.friendships
    ADD CONSTRAINT friendships_pkey PRIMARY KEY (id);


--
-- Name: friendships friendships_user_id_friend_id_key; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.friendships
    ADD CONSTRAINT friendships_user_id_friend_id_key UNIQUE (user_id, friend_id);


--
-- Name: idx_friendships_friend_id; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_friendships_friend_id ON social_features.friendships USING btree (friend_id);


--
-- Name: idx_friendships_status; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_friendships_status ON social_features.friendships USING btree (status);


--
-- Name: idx_friendships_user_id; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_friendships_user_id ON social_features.friendships USING btree (user_id);


--
-- Name: friendships friendships_friend_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.friendships
    ADD CONSTRAINT friendships_friend_id_fkey FOREIGN KEY (friend_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: friendships friendships_user_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.friendships
    ADD CONSTRAINT friendships_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: TABLE friendships; Type: ACL; Schema: social_features; Owner: postgres
--

GRANT ALL ON TABLE social_features.friendships TO gamilit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict osJUvm0AzJPenTlRRivBE9S1J1JMuLiwfvOr9pjcbYRe0UXUcZb4MtyDLjwc52u

