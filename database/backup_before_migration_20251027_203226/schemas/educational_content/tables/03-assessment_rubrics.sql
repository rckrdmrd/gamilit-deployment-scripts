-- =====================================================
-- Table: educational_content.assessment_rubrics
-- Description: Rúbricas de evaluación para ejercicios y módulos
-- Created: 2025-10-27
-- =====================================================

SET search_path TO educational_content, public;

DROP TABLE IF EXISTS educational_content.assessment_rubrics CASCADE;

CREATE TABLE educational_content.assessment_rubrics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    exercise_id uuid,
    module_id uuid,
    name text NOT NULL,
    description text,
    assessment_type text,
    criteria jsonb DEFAULT '{"criteria_1": {"name": "Comprehension", "levels": {"good": {"points": 75, "description": "Good comprehension"}, "basic": {"points": 50, "description": "Basic comprehension"}, "excellent": {"points": 100, "description": "Full comprehension"}, "insufficient": {"points": 25, "description": "Limited comprehension"}}, "weight": 40}}'::jsonb,
    scoring_scale jsonb DEFAULT '{"max": 100, "min": 0, "passing": 70}'::jsonb,
    weight_percentage numeric(5,2) DEFAULT 100.00,
    is_active boolean DEFAULT true,
    allow_resubmission boolean DEFAULT true,
    feedback_template text,
    auto_feedback_enabled boolean DEFAULT true,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_by uuid,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT assessment_rubrics_assessment_type_check CHECK ((assessment_type = ANY (ARRAY['automatic'::text, 'manual'::text, 'hybrid'::text, 'peer_review'::text]))),
    CONSTRAINT assessment_rubrics_weight_percentage_check CHECK ((weight_percentage > (0)::numeric)),
    CONSTRAINT rubric_reference_check CHECK ((((exercise_id IS NOT NULL) AND (module_id IS NULL)) OR ((exercise_id IS NULL) AND (module_id IS NOT NULL))))
);

ALTER TABLE educational_content.assessment_rubrics OWNER TO postgres;

-- Primary Key
ALTER TABLE ONLY educational_content.assessment_rubrics
    ADD CONSTRAINT assessment_rubrics_pkey PRIMARY KEY (id);

-- Indexes
CREATE INDEX idx_rubrics_active ON educational_content.assessment_rubrics USING btree (is_active) WHERE (is_active = true);
CREATE INDEX idx_rubrics_exercise_id ON educational_content.assessment_rubrics USING btree (exercise_id);
CREATE INDEX idx_rubrics_module_id ON educational_content.assessment_rubrics USING btree (module_id);

-- Triggers
CREATE TRIGGER trg_assessment_rubrics_updated_at BEFORE UPDATE ON educational_content.assessment_rubrics FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- Foreign Keys
ALTER TABLE ONLY educational_content.assessment_rubrics
    ADD CONSTRAINT assessment_rubrics_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth_management.profiles(id);

ALTER TABLE ONLY educational_content.assessment_rubrics
    ADD CONSTRAINT assessment_rubrics_exercise_id_fkey FOREIGN KEY (exercise_id) REFERENCES educational_content.exercises(id) ON DELETE CASCADE;

ALTER TABLE ONLY educational_content.assessment_rubrics
    ADD CONSTRAINT assessment_rubrics_module_id_fkey FOREIGN KEY (module_id) REFERENCES educational_content.modules(id) ON DELETE CASCADE;

-- Row Level Security
ALTER TABLE educational_content.assessment_rubrics ENABLE ROW LEVEL SECURITY;

-- Permissions
GRANT ALL ON TABLE educational_content.assessment_rubrics TO glit_user;

-- Comments
COMMENT ON TABLE educational_content.assessment_rubrics IS 'Rúbricas de evaluación para ejercicios y módulos';
COMMENT ON COLUMN educational_content.assessment_rubrics.assessment_type IS 'Tipo: automatic, manual, hybrid, peer_review';
