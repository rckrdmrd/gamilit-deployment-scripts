--
-- PostgreSQL database dump
--

\restrict AABqnHjY4B9nmmHtkoZtgWOxcMIkALL4MDIVZDXYmD0b8p85Oubtez3j2WBwLva

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
-- Name: leaderboard_metadata; Type: TABLE; Schema: gamification_system; Owner: glit_user
--

CREATE TABLE gamification_system.leaderboard_metadata (
    view_name text NOT NULL,
    last_refresh_at timestamp with time zone DEFAULT now(),
    total_users integer,
    refresh_duration_ms integer,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE gamification_system.leaderboard_metadata OWNER TO glit_user;

--
-- Name: TABLE leaderboard_metadata; Type: COMMENT; Schema: gamification_system; Owner: glit_user
--

COMMENT ON TABLE gamification_system.leaderboard_metadata IS 'Tracks refresh status and statistics for materialized leaderboard views';


--
-- Name: leaderboard_metadata leaderboard_metadata_pkey; Type: CONSTRAINT; Schema: gamification_system; Owner: glit_user
--

ALTER TABLE ONLY gamification_system.leaderboard_metadata
    ADD CONSTRAINT leaderboard_metadata_pkey PRIMARY KEY (view_name);


--
-- PostgreSQL database dump complete
--

\unrestrict AABqnHjY4B9nmmHtkoZtgWOxcMIkALL4MDIVZDXYmD0b8p85Oubtez3j2WBwLva

