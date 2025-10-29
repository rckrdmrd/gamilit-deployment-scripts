-- =====================================================
-- Table: content_management.marie_curie_content
-- Description: Contenido curado sobre Marie Curie - biografía, descubrimientos, legado
-- Created: 2025-10-27
-- =====================================================

SET search_path TO content_management, public;

DROP TABLE IF EXISTS content_management.marie_curie_content CASCADE;

CREATE TABLE content_management.marie_curie_content (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    title text NOT NULL,
    subtitle text,
    description text,
    category text,
    content jsonb DEFAULT '{"quotes": [], "timeline": [], "key_points": [], "introduction": "", "main_content": ""}'::jsonb,
    target_grade_levels text[] DEFAULT ARRAY['6'::text, '7'::text, '8'::text],
    difficulty_level public.difficulty_level DEFAULT 'beginner'::public.difficulty_level,
    reading_level text,
    learning_objectives text[],
    prerequisite_knowledge text[],
    key_vocabulary text[],
    images uuid[],
    videos uuid[],
    audio_files uuid[],
    documents uuid[],
    historical_period text,
    scientific_field text,
    cultural_context jsonb DEFAULT '{}'::jsonb,
    status public.content_status DEFAULT 'draft'::public.content_status,
    is_featured boolean DEFAULT false,
    is_interactive boolean DEFAULT false,
    created_by uuid,
    reviewed_by uuid,
    approved_by uuid,
    keywords text[],
    search_tags text[],
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT marie_curie_content_category_check CHECK ((category = ANY (ARRAY['biography'::text, 'discoveries'::text, 'historical_context'::text, 'scientific_method'::text, 'radioactivity'::text, 'nobel_prizes'::text, 'women_in_science'::text, 'modern_physics'::text, 'legacy'::text])))
);

ALTER TABLE content_management.marie_curie_content OWNER TO postgres;

-- Primary Key
ALTER TABLE ONLY content_management.marie_curie_content
    ADD CONSTRAINT marie_curie_content_pkey PRIMARY KEY (id);

-- Indexes
CREATE INDEX idx_marie_content_category ON content_management.marie_curie_content USING btree (category);
CREATE INDEX idx_marie_content_featured ON content_management.marie_curie_content USING btree (is_featured) WHERE (is_featured = true);
CREATE INDEX idx_marie_content_search ON content_management.marie_curie_content USING gin (to_tsvector('spanish'::regconfig, ((COALESCE(title, ''::text) || ' '::text) || COALESCE(description, ''::text))));
CREATE INDEX idx_marie_content_status ON content_management.marie_curie_content USING btree (status);
CREATE INDEX idx_marie_content_tags ON content_management.marie_curie_content USING gin (search_tags);
CREATE INDEX idx_marie_content_tenant ON content_management.marie_curie_content USING btree (tenant_id);

-- Triggers
CREATE TRIGGER trg_marie_curie_content_updated_at BEFORE UPDATE ON content_management.marie_curie_content FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- Foreign Keys
ALTER TABLE ONLY content_management.marie_curie_content
    ADD CONSTRAINT marie_curie_content_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES auth_management.profiles(id);

ALTER TABLE ONLY content_management.marie_curie_content
    ADD CONSTRAINT marie_curie_content_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth_management.profiles(id);

ALTER TABLE ONLY content_management.marie_curie_content
    ADD CONSTRAINT marie_curie_content_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES auth_management.profiles(id);

ALTER TABLE ONLY content_management.marie_curie_content
    ADD CONSTRAINT marie_curie_content_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;

-- Row Level Security
ALTER TABLE content_management.marie_curie_content ENABLE ROW LEVEL SECURITY;

CREATE POLICY marie_content_all_admin ON content_management.marie_curie_content USING (gamilit.is_admin());
CREATE POLICY marie_content_select_all ON content_management.marie_curie_content FOR SELECT USING ((status = 'published'::public.content_status));

-- Permissions
GRANT ALL ON TABLE content_management.marie_curie_content TO glit_user;

-- Comments
COMMENT ON TABLE content_management.marie_curie_content IS 'Contenido curado sobre Marie Curie - biografía, descubrimientos, legado';
COMMENT ON COLUMN content_management.marie_curie_content.category IS 'Categoría del contenido: biografía, descubrimientos, premios Nobel, etc.';
