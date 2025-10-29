--
-- PostgreSQL database dump
--

\restrict p4E1DqUh5koUE2iTbc2LIFCSCHDZpMxCLEZPFQ9jBCzdpiS4oKm6NR3zMLa9yfp

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
-- Name: schools; Type: TABLE; Schema: social_features; Owner: postgres
--

CREATE TABLE social_features.schools (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    name text NOT NULL,
    code text,
    short_name text,
    description text,
    address text,
    city text,
    region text,
    country text DEFAULT 'México'::text,
    postal_code text,
    phone text,
    email text,
    website text,
    principal_id uuid,
    administrative_contact_id uuid,
    academic_year text,
    semester_system boolean DEFAULT true,
    grade_levels text[] DEFAULT ARRAY['6'::text, '7'::text, '8'::text],
    settings jsonb DEFAULT '{}'::jsonb,
    max_students integer DEFAULT 1000,
    max_teachers integer DEFAULT 100,
    current_students_count integer DEFAULT 0,
    current_teachers_count integer DEFAULT 0,
    is_active boolean DEFAULT true,
    is_verified boolean DEFAULT false,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico()
);


ALTER TABLE social_features.schools OWNER TO gamilit_user;

--
-- Name: TABLE schools; Type: COMMENT; Schema: social_features; Owner: postgres
--

COMMENT ON TABLE social_features.schools IS 'Instituciones educativas - escuelas y colegios';


--
-- Name: schools schools_code_key; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.schools
    ADD CONSTRAINT schools_code_key UNIQUE (code);


--
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- Name: idx_schools_active; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_schools_active ON social_features.schools USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_schools_code; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_schools_code ON social_features.schools USING btree (code);


--
-- Name: idx_schools_tenant; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_schools_tenant ON social_features.schools USING btree (tenant_id);


--
-- Name: schools trg_schools_updated_at; Type: TRIGGER; Schema: social_features; Owner: postgres
--

CREATE TRIGGER trg_schools_updated_at BEFORE UPDATE ON social_features.schools FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();


--
-- Name: schools schools_administrative_contact_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.schools
    ADD CONSTRAINT schools_administrative_contact_id_fkey FOREIGN KEY (administrative_contact_id) REFERENCES auth_management.profiles(id);


--
-- Name: schools schools_principal_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.schools
    ADD CONSTRAINT schools_principal_id_fkey FOREIGN KEY (principal_id) REFERENCES auth_management.profiles(id);


--
-- Name: schools schools_tenant_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.schools
    ADD CONSTRAINT schools_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;


--
-- Name: TABLE schools; Type: ACL; Schema: social_features; Owner: postgres
--

GRANT ALL ON TABLE social_features.schools TO gamilit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict p4E1DqUh5koUE2iTbc2LIFCSCHDZpMxCLEZPFQ9jBCzdpiS4oKm6NR3zMLa9yfp

