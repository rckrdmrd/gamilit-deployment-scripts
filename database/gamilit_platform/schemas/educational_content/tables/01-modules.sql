-- =====================================================
-- Table: educational_content.modules
-- Description: Módulos educativos de Marie Curie - 5 niveles de comprensión lectora
-- Created: 2025-10-27
-- =====================================================

SET search_path TO educational_content, public;

DROP TABLE IF EXISTS educational_content.modules CASCADE;

CREATE TABLE educational_content.modules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    title text NOT NULL,
    subtitle text,
    description text,
    summary text,
    content jsonb DEFAULT '{"marie_curie_story": {}, "reading_materials": [], "historical_context": {}, "scientific_concepts": {}, "multimedia_resources": []}'::jsonb,
    order_index integer NOT NULL,
    module_code text,
    difficulty_level public.difficulty_level DEFAULT 'beginner'::public.difficulty_level,
    grade_levels text[] DEFAULT ARRAY['6'::text, '7'::text, '8'::text],
    subjects text[] DEFAULT ARRAY['Literatura'::text, 'Ciencias'::text],
    estimated_duration_minutes integer DEFAULT 120,
    estimated_sessions integer DEFAULT 4,
    learning_objectives text[],
    competencies text[],
    skills_developed text[],
    prerequisites uuid[],
    prerequisite_skills text[],
    maya_rank_required public.maya_rank,
    maya_rank_granted public.maya_rank,
    xp_reward integer DEFAULT 100,
    ml_coins_reward integer DEFAULT 50,
    status public.content_status DEFAULT 'draft'::public.content_status,
    is_published boolean DEFAULT false,
    is_featured boolean DEFAULT false,
    is_free boolean DEFAULT true,
    is_demo_module boolean DEFAULT false,
    published_at timestamp with time zone,
    archived_at timestamp with time zone,
    version integer DEFAULT 1,
    version_notes text,
    created_by uuid,
    reviewed_by uuid,
    approved_by uuid,
    keywords text[],
    tags text[],
    thumbnail_url text,
    cover_image_url text,
    settings jsonb DEFAULT '{}'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    total_exercises integer DEFAULT 0,
    CONSTRAINT modules_ml_coins_reward_check CHECK ((ml_coins_reward >= 0)),
    CONSTRAINT modules_xp_reward_check CHECK ((xp_reward >= 0))
);

ALTER TABLE educational_content.modules OWNER TO postgres;

-- Primary Key
ALTER TABLE ONLY educational_content.modules
    ADD CONSTRAINT modules_pkey PRIMARY KEY (id);

-- Indexes
CREATE INDEX idx_modules_active_published ON educational_content.modules USING btree (order_index) WHERE ((is_published = true) AND (status = 'published'::public.content_status));
CREATE INDEX idx_modules_content_gin ON educational_content.modules USING gin (content);
CREATE INDEX idx_modules_difficulty ON educational_content.modules USING btree (difficulty_level);
CREATE INDEX idx_modules_order ON educational_content.modules USING btree (order_index);
CREATE INDEX idx_modules_prerequisites_gin ON educational_content.modules USING gin (prerequisites);
CREATE INDEX idx_modules_published ON educational_content.modules USING btree (is_published) WHERE (is_published = true);
CREATE INDEX idx_modules_rango_required ON educational_content.modules USING btree (maya_rank_required);
CREATE INDEX idx_modules_search ON educational_content.modules USING gin (to_tsvector('spanish'::regconfig, ((COALESCE(title, ''::text) || ' '::text) || COALESCE(description, ''::text))));
CREATE INDEX idx_modules_status ON educational_content.modules USING btree (status);
CREATE INDEX idx_modules_status_published ON educational_content.modules USING btree (status, is_published, order_index);
CREATE INDEX idx_modules_tags_gin ON educational_content.modules USING gin (tags);
CREATE INDEX idx_modules_tenant_id ON educational_content.modules USING btree (tenant_id);

-- Triggers
CREATE TRIGGER trg_modules_updated_at BEFORE UPDATE ON educational_content.modules FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- Foreign Keys
ALTER TABLE ONLY educational_content.modules
    ADD CONSTRAINT modules_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES auth_management.profiles(id);

ALTER TABLE ONLY educational_content.modules
    ADD CONSTRAINT modules_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth_management.profiles(id);

ALTER TABLE ONLY educational_content.modules
    ADD CONSTRAINT modules_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES auth_management.profiles(id);

ALTER TABLE ONLY educational_content.modules
    ADD CONSTRAINT modules_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;

-- Row Level Security Policies
CREATE POLICY modules_all_admin ON educational_content.modules USING (gamilit.is_admin());
CREATE POLICY modules_select_admin ON educational_content.modules FOR SELECT USING (gamilit.is_admin());
CREATE POLICY modules_select_published ON educational_content.modules FOR SELECT USING (((is_published = true) AND (status = 'published'::public.content_status)));

-- Permissions
GRANT ALL ON TABLE educational_content.modules TO gamilit_user;

-- Comments
COMMENT ON TABLE educational_content.modules IS 'Módulos educativos de Marie Curie - 5 niveles de comprensión lectora';
COMMENT ON COLUMN educational_content.modules.rango_maya_required IS 'Rango maya requerido para desbloquear el módulo';
COMMENT ON COLUMN educational_content.modules.rango_maya_granted IS 'Rango maya otorgado al completar el módulo';
