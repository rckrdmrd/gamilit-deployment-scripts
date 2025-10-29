--
-- PostgreSQL database dump
--

\restrict ZWD7eFxolIbKXGLzhJpg7Jv7hW0TpZdh1eZz5KcK03ZFR7rvI6uxDA0OQKUNhBq

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
-- Name: classrooms; Type: TABLE; Schema: social_features; Owner: postgres
--

CREATE TABLE social_features.classrooms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    school_id uuid,
    tenant_id uuid NOT NULL,
    name text NOT NULL,
    code text,
    description text,
    grade_level text,
    section text,
    subject text,
    academic_year text,
    semester text,
    teacher_id uuid NOT NULL,
    co_teachers uuid[],
    capacity integer DEFAULT 40,
    current_students_count integer DEFAULT 0,
    settings jsonb DEFAULT '{"require_approval": true, "visible_in_directory": true, "allow_self_enrollment": false}'::jsonb,
    schedule jsonb DEFAULT '[]'::jsonb,
    meeting_url text,
    is_active boolean DEFAULT true,
    is_archived boolean DEFAULT false,
    start_date date,
    end_date date,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico()
);


ALTER TABLE social_features.classrooms OWNER TO postgres;

--
-- Name: TABLE classrooms; Type: COMMENT; Schema: social_features; Owner: postgres
--

COMMENT ON TABLE social_features.classrooms IS 'Aulas virtuales para organizar estudiantes por clase';


--
-- Name: classrooms classrooms_code_key; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.classrooms
    ADD CONSTRAINT classrooms_code_key UNIQUE (code);


--
-- Name: classrooms classrooms_pkey; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.classrooms
    ADD CONSTRAINT classrooms_pkey PRIMARY KEY (id);


--
-- Name: idx_classrooms_active; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_classrooms_active ON social_features.classrooms USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_classrooms_code; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_classrooms_code ON social_features.classrooms USING btree (code);


--
-- Name: idx_classrooms_school; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_classrooms_school ON social_features.classrooms USING btree (school_id);


--
-- Name: idx_classrooms_teacher; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_classrooms_teacher ON social_features.classrooms USING btree (teacher_id);


--
-- Name: classrooms trg_classrooms_updated_at; Type: TRIGGER; Schema: social_features; Owner: postgres
--

CREATE TRIGGER trg_classrooms_updated_at BEFORE UPDATE ON social_features.classrooms FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();


--
-- Name: classrooms classrooms_school_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.classrooms
    ADD CONSTRAINT classrooms_school_id_fkey FOREIGN KEY (school_id) REFERENCES social_features.schools(id) ON DELETE CASCADE;


--
-- Name: classrooms classrooms_teacher_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.classrooms
    ADD CONSTRAINT classrooms_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES auth_management.profiles(id);


--
-- Name: classrooms classrooms_tenant_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.classrooms
    ADD CONSTRAINT classrooms_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;


--
-- Name: classrooms classrooms_manage_teacher; Type: POLICY; Schema: social_features; Owner: postgres
--

CREATE POLICY classrooms_manage_teacher ON social_features.classrooms USING ((teacher_id = gamilit.get_current_user_id()));


--
-- Name: classrooms classrooms_select_admin; Type: POLICY; Schema: social_features; Owner: postgres
--

CREATE POLICY classrooms_select_admin ON social_features.classrooms FOR SELECT USING (gamilit.is_admin());


--
-- Name: classrooms classrooms_select_student; Type: POLICY; Schema: social_features; Owner: postgres
--

CREATE POLICY classrooms_select_student ON social_features.classrooms FOR SELECT USING ((EXISTS ( SELECT 1
   FROM social_features.classroom_members cm
  WHERE ((cm.classroom_id = classrooms.id) AND (cm.student_id = gamilit.get_current_user_id()) AND (cm.status = 'active'::text)))));


--
-- Name: classrooms classrooms_select_teacher; Type: POLICY; Schema: social_features; Owner: postgres
--

CREATE POLICY classrooms_select_teacher ON social_features.classrooms FOR SELECT USING ((teacher_id = gamilit.get_current_user_id()));


--
-- Name: TABLE classrooms; Type: ACL; Schema: social_features; Owner: postgres
--

GRANT ALL ON TABLE social_features.classrooms TO gamilit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict ZWD7eFxolIbKXGLzhJpg7Jv7hW0TpZdh1eZz5KcK03ZFR7rvI6uxDA0OQKUNhBq

