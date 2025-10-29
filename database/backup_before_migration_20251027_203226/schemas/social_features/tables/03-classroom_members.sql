--
-- PostgreSQL database dump
--

\restrict h626hMccX4FrcHg534sgHNHX1gB7MAZU3xaXXGSCb4qU45zKGpTSaKSBKga7wQe

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
-- Name: classroom_members; Type: TABLE; Schema: social_features; Owner: postgres
--

CREATE TABLE social_features.classroom_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    classroom_id uuid NOT NULL,
    student_id uuid NOT NULL,
    enrollment_date timestamp with time zone DEFAULT gamilit.now_mexico(),
    enrollment_method text DEFAULT 'teacher_invite'::text,
    enrolled_by uuid,
    status text DEFAULT 'active'::text,
    withdrawal_date timestamp with time zone,
    withdrawal_reason text,
    student_number text,
    final_grade numeric(3,1),
    attendance_percentage numeric(5,2),
    permissions jsonb DEFAULT '{}'::jsonb,
    teacher_notes text,
    parent_contact_info jsonb DEFAULT '{}'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT classroom_members_enrollment_method_check CHECK ((enrollment_method = ANY (ARRAY['teacher_invite'::text, 'self_enroll'::text, 'admin_add'::text, 'bulk_import'::text]))),
    CONSTRAINT classroom_members_status_check CHECK ((status = ANY (ARRAY['active'::text, 'inactive'::text, 'withdrawn'::text, 'completed'::text])))
);


ALTER TABLE social_features.classroom_members OWNER TO postgres;

--
-- Name: TABLE classroom_members; Type: COMMENT; Schema: social_features; Owner: postgres
--

COMMENT ON TABLE social_features.classroom_members IS 'Membresía de estudiantes en aulas';


--
-- Name: classroom_members classroom_members_classroom_id_student_id_key; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.classroom_members
    ADD CONSTRAINT classroom_members_classroom_id_student_id_key UNIQUE (classroom_id, student_id);


--
-- Name: classroom_members classroom_members_pkey; Type: CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.classroom_members
    ADD CONSTRAINT classroom_members_pkey PRIMARY KEY (id);


--
-- Name: idx_classroom_members_active; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_classroom_members_active ON social_features.classroom_members USING btree (student_id, status) WHERE (status = 'active'::text);


--
-- Name: idx_classroom_members_classroom; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_classroom_members_classroom ON social_features.classroom_members USING btree (classroom_id);


--
-- Name: idx_classroom_members_classroom_status; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_classroom_members_classroom_status ON social_features.classroom_members USING btree (classroom_id, status) WHERE (status = 'active'::text);


--
-- Name: idx_classroom_members_student; Type: INDEX; Schema: social_features; Owner: postgres
--

CREATE INDEX idx_classroom_members_student ON social_features.classroom_members USING btree (student_id);


--
-- Name: classroom_members trg_classroom_members_updated_at; Type: TRIGGER; Schema: social_features; Owner: postgres
--

CREATE TRIGGER trg_classroom_members_updated_at BEFORE UPDATE ON social_features.classroom_members FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();


--
-- Name: classroom_members trg_update_classroom_count; Type: TRIGGER; Schema: social_features; Owner: postgres
--

CREATE TRIGGER trg_update_classroom_count AFTER INSERT OR DELETE ON social_features.classroom_members FOR EACH ROW EXECUTE FUNCTION gamilit.update_classroom_member_count();


--
-- Name: classroom_members classroom_members_classroom_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.classroom_members
    ADD CONSTRAINT classroom_members_classroom_id_fkey FOREIGN KEY (classroom_id) REFERENCES social_features.classrooms(id) ON DELETE CASCADE;


--
-- Name: classroom_members classroom_members_enrolled_by_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.classroom_members
    ADD CONSTRAINT classroom_members_enrolled_by_fkey FOREIGN KEY (enrolled_by) REFERENCES auth_management.profiles(id);


--
-- Name: classroom_members classroom_members_student_id_fkey; Type: FK CONSTRAINT; Schema: social_features; Owner: postgres
--

ALTER TABLE ONLY social_features.classroom_members
    ADD CONSTRAINT classroom_members_student_id_fkey FOREIGN KEY (student_id) REFERENCES auth_management.profiles(id) ON DELETE CASCADE;


--
-- Name: classroom_members classroom_members_manage_teacher; Type: POLICY; Schema: social_features; Owner: postgres
--

CREATE POLICY classroom_members_manage_teacher ON social_features.classroom_members USING ((EXISTS ( SELECT 1
   FROM social_features.classrooms c
  WHERE ((c.id = classroom_members.classroom_id) AND (c.teacher_id = gamilit.get_current_user_id())))));


--
-- Name: classroom_members classroom_members_select_admin; Type: POLICY; Schema: social_features; Owner: postgres
--

CREATE POLICY classroom_members_select_admin ON social_features.classroom_members FOR SELECT USING (gamilit.is_admin());


--
-- Name: classroom_members classroom_members_select_own; Type: POLICY; Schema: social_features; Owner: postgres
--

CREATE POLICY classroom_members_select_own ON social_features.classroom_members FOR SELECT USING ((student_id = gamilit.get_current_user_id()));


--
-- Name: classroom_members classroom_members_select_teacher; Type: POLICY; Schema: social_features; Owner: postgres
--

CREATE POLICY classroom_members_select_teacher ON social_features.classroom_members FOR SELECT USING ((EXISTS ( SELECT 1
   FROM social_features.classrooms c
  WHERE ((c.id = classroom_members.classroom_id) AND (c.teacher_id = gamilit.get_current_user_id())))));


--
-- Name: TABLE classroom_members; Type: ACL; Schema: social_features; Owner: postgres
--

GRANT ALL ON TABLE social_features.classroom_members TO glit_user;


--
-- PostgreSQL database dump complete
--

\unrestrict h626hMccX4FrcHg534sgHNHX1gB7MAZU3xaXXGSCb4qU45zKGpTSaKSBKga7wQe

