-- =====================================================
-- Table: educational_content.exercises
-- Description: Ejercicios con 27 mecánicas diferentes - crucigramas, mapas, debates, etc.
-- Created: 2025-10-27
-- =====================================================

SET search_path TO educational_content, public;

DROP TABLE IF EXISTS educational_content.exercises CASCADE;

CREATE TABLE educational_content.exercises (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    module_id uuid NOT NULL,
    title text NOT NULL,
    subtitle text,
    description text,
    instructions text,
    exercise_type public.exercise_type NOT NULL,
    order_index integer NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    content jsonb DEFAULT '{"options": [], "question": "", "explanations": {}, "correct_answers": []}'::jsonb NOT NULL,
    solution jsonb,
    rubric jsonb,
    auto_gradable boolean DEFAULT true,
    difficulty_level public.difficulty_level DEFAULT 'beginner'::public.difficulty_level,
    max_points integer DEFAULT 100,
    passing_score integer DEFAULT 70,
    estimated_time_minutes integer DEFAULT 10,
    time_limit_minutes integer,
    max_attempts integer DEFAULT 3,
    allow_retry boolean DEFAULT true,
    retry_delay_minutes integer DEFAULT 0,
    hints text[],
    enable_hints boolean DEFAULT true,
    hint_cost_ml_coins integer DEFAULT 5,
    comodines_allowed public.comodin_type[] DEFAULT ARRAY['pistas'::public.comodin_type, 'vision_lectora'::public.comodin_type, 'segunda_oportunidad'::public.comodin_type],
    comodines_config jsonb DEFAULT '{"pistas": {"cost": 15, "enabled": true}, "vision_lectora": {"cost": 25, "enabled": true}, "segunda_oportunidad": {"cost": 40, "enabled": true}}'::jsonb,
    xp_reward integer DEFAULT 20,
    ml_coins_reward integer DEFAULT 5,
    bonus_multiplier numeric(3,2) DEFAULT 1.00,
    is_active boolean DEFAULT true,
    is_optional boolean DEFAULT false,
    is_bonus boolean DEFAULT false,
    version integer DEFAULT 1,
    version_notes text,
    created_by uuid,
    reviewed_by uuid,
    adaptive_difficulty boolean DEFAULT false,
    prerequisites uuid[],
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT exercises_check CHECK (((passing_score > 0) AND (passing_score <= max_points))),
    CONSTRAINT exercises_max_points_check CHECK ((max_points > 0)),
    CONSTRAINT exercises_ml_coins_reward_check CHECK ((ml_coins_reward >= 0)),
    CONSTRAINT exercises_xp_reward_check CHECK ((xp_reward >= 0))
);

ALTER TABLE educational_content.exercises OWNER TO postgres;

-- Primary Key
ALTER TABLE ONLY educational_content.exercises
    ADD CONSTRAINT exercises_pkey PRIMARY KEY (id);

-- Indexes
CREATE INDEX idx_exercises_active ON educational_content.exercises USING btree (is_active) WHERE (is_active = true);
CREATE INDEX idx_exercises_active_gradable ON educational_content.exercises USING btree (module_id, order_index) WHERE ((is_active = true) AND (auto_gradable = true));
CREATE INDEX idx_exercises_config_gin ON educational_content.exercises USING gin (config);
CREATE INDEX idx_exercises_content_gin ON educational_content.exercises USING gin (content);
CREATE INDEX idx_exercises_difficulty ON educational_content.exercises USING btree (difficulty_level);
CREATE INDEX idx_exercises_module_id ON educational_content.exercises USING btree (module_id);
CREATE INDEX idx_exercises_module_type_active ON educational_content.exercises USING btree (module_id, exercise_type, is_active);
CREATE INDEX idx_exercises_order ON educational_content.exercises USING btree (module_id, order_index);
CREATE INDEX idx_exercises_search ON educational_content.exercises USING gin (to_tsvector('spanish'::regconfig, ((COALESCE(title, ''::text) || ' '::text) || COALESCE(description, ''::text))));
CREATE INDEX idx_exercises_type ON educational_content.exercises USING btree (exercise_type);

-- Triggers
CREATE TRIGGER trg_exercises_updated_at BEFORE UPDATE ON educational_content.exercises FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- Foreign Keys
ALTER TABLE ONLY educational_content.exercises
    ADD CONSTRAINT exercises_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth_management.profiles(id);

ALTER TABLE ONLY educational_content.exercises
    ADD CONSTRAINT exercises_module_id_fkey FOREIGN KEY (module_id) REFERENCES educational_content.modules(id) ON DELETE CASCADE;

ALTER TABLE ONLY educational_content.exercises
    ADD CONSTRAINT exercises_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES auth_management.profiles(id);

-- Row Level Security Policies
CREATE POLICY exercises_all_admin ON educational_content.exercises USING (gamilit.is_admin());
CREATE POLICY exercises_select_active ON educational_content.exercises FOR SELECT USING ((is_active = true));
CREATE POLICY exercises_select_admin ON educational_content.exercises FOR SELECT USING (gamilit.is_admin());

-- Permissions
GRANT ALL ON TABLE educational_content.exercises TO gamilit_user;

-- Comments
COMMENT ON TABLE educational_content.exercises IS 'Ejercicios con 27 mecánicas diferentes - crucigramas, mapas, debates, etc.';
COMMENT ON COLUMN educational_content.exercises.exercise_type IS 'Tipo de ejercicio: crucigrama, mapa_conceptual, detective_textual, etc.';
COMMENT ON COLUMN educational_content.exercises.comodines_allowed IS 'Power-ups permitidos en este ejercicio';
