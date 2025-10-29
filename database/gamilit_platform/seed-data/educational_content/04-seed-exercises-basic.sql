-- ============================================================================
-- File: 04-seed-exercises-basic.sql
-- Description: Basic exercises for the 4 modules
-- Created: 2025-10-28
-- ============================================================================

BEGIN;

-- Módulo 1 ID: 11111111-1111-1111-1111-111111111111
-- Módulo 2 ID: 11111111-1111-1111-1111-111111111112
-- Módulo 3 ID: 11111111-1111-1111-1111-111111111113
-- Módulo 4 ID: 11111111-1111-1111-1111-111111111114

-- ========================================================================
-- MÓDULO 1: Comprensión Literal - 5 Ejercicios
-- ========================================================================

INSERT INTO educational_content.exercises (
    module_id, title, subtitle, description,
    exercise_type, order_index,
    config, content,
    difficulty_level, max_points, passing_score,
    estimated_time_minutes, max_attempts,
    xp_reward, ml_coins_reward,
    is_active
) VALUES
('11111111-1111-1111-1111-111111111111',
 'Línea de Tiempo de Marie Curie',
 'Ordena los Eventos Cronológicamente',
 'Organiza los eventos importantes de la vida de Marie Curie en orden cronológico',
 'linea_tiempo', 1,
 '{"allowReordering": true, "showYears": true}'::jsonb,
 '{"events": [{"year": 1867, "title": "Nace en Varsovia"}, {"year": 1903, "title": "Primer Premio Nobel"}, {"year": 1911, "title": "Segundo Premio Nobel"}]}'::jsonb,
 'beginner', 100, 70,
 10, 3,
 20, 10,
 true),

('11111111-1111-1111-1111-111111111111',
 'Verdadero o Falso sobre Marie Curie',
 'Evalúa las afirmaciones',
 'Determina si las afirmaciones sobre Marie Curie son verdaderas o falsas',
 'verdadero_falso', 2,
 '{"showExplanations": true}'::jsonb,
 '{"statements": [{"statement": "Marie nació en Polonia", "correctAnswer": true}, {"statement": "Marie nació en Francia", "correctAnswer": false}]}'::jsonb,
 'beginner', 100, 75,
 8, 3,
 20, 10,
 true),

('11111111-1111-1111-1111-111111111111',
 'Empareja Conceptos Científicos',
 'Relaciona términos con definiciones',
 'Conecta cada término científico con su definición correcta',
 'emparejamiento', 3,
 '{"matchingType": "cards"}'::jsonb,
 '{"pairs": [{"left": "Radio", "right": "Elemento que brilla en la oscuridad"}, {"left": "Polonio", "right": "Nombrado por su país natal"}]}'::jsonb,
 'beginner', 100, 70,
 10, 3,
 20, 10,
 true),

('11111111-1111-1111-1111-111111111111',
 'Completa los Espacios',
 'Completa las frases sobre Marie Curie',
 'Completa las oraciones con las palabras correctas',
 'completar_espacios', 4,
 '{"allowHints": true}'::jsonb,
 '{"sentences": [{"text": "Marie Curie descubrió el ___ y el ___", "answers": ["polonio", "radio"]}]}'::jsonb,
 'beginner', 100, 70,
 10, 3,
 20, 10,
 true),

('11111111-1111-1111-1111-111111111111',
 'Crucigrama Científico',
 'Vocabulario de Radioactividad',
 'Completa el crucigrama con términos científicos',
 'crucigrama', 5,
 '{"gridSize": {"rows": 10, "cols": 10}}'::jsonb,
 '{"clues": [{"number": 1, "direction": "horizontal", "clue": "Elemento descubierto en 1898", "answer": "RADIO"}]}'::jsonb,
 'beginner', 100, 70,
 15, 3,
 25, 12,
 true);

-- ========================================================================
-- MÓDULO 2: Comprensión Inferencial - 3 Ejercicios
-- ========================================================================

INSERT INTO educational_content.exercises (
    module_id, title, subtitle, description,
    exercise_type, order_index,
    config, content,
    difficulty_level, max_points, passing_score,
    estimated_time_minutes, max_attempts,
    xp_reward, ml_coins_reward,
    is_active
) VALUES
('11111111-1111-1111-1111-111111111112',
 'Detective Textual: El Misterio de la Radiación',
 'Investiga las Pistas del Texto',
 'Analiza el texto como un detective y encuentra evidencias',
 'detective_textual', 1,
 '{"investigationMode": true}'::jsonb,
 '{"mystery": "¿Cómo descubrió Marie Curie la radioactividad?", "evidences": [{"type": "observation", "title": "Radiación anormal"}]}'::jsonb,
 'intermediate', 100, 70,
 15, 3,
 30, 15,
 true),

('11111111-1111-1111-1111-111111111112',
 'Construcción de Hipótesis',
 'Formúla hipótesis científicas',
 'Basándote en las observaciones, construye hipótesis sobre los descubrimientos de Marie',
 'construccion_hipotesis', 2,
 '{"allowMultipleHypothesis": true}'::jsonb,
 '{"scenario": "La pechblenda emitía más radiación que el uranio puro", "questions": [{"question": "¿Por qué la pechblenda era más radiactiva?"}]}'::jsonb,
 'intermediate', 100, 70,
 15, 3,
 30, 15,
 true),

('11111111-1111-1111-1111-111111111112',
 'Predicción Narrativa',
 'Predice eventos futuros',
 'Basándote en el patrón de comportamiento de Marie, predice qué hizo después',
 'prediccion_narrativa', 3,
 '{"scenarioBased": true}'::jsonb,
 '{"scenario": "Después de la muerte de Pierre en 1906...", "predictions": [{"option": "Continuar investigando", "isCorrect": true}]}'::jsonb,
 'intermediate', 100, 70,
 15, 3,
 30, 15,
 true);

-- ========================================================================
-- MÓDULO 3: Comprensión Crítica - 3 Ejercicios
-- ========================================================================

INSERT INTO educational_content.exercises (
    module_id, title, subtitle, description,
    exercise_type, order_index,
    config, content,
    difficulty_level, max_points, passing_score,
    estimated_time_minutes, max_attempts,
    xp_reward, ml_coins_reward,
    is_active
) VALUES
('11111111-1111-1111-1111-111111111113',
 'Tribunal de Opiniones',
 'Defiende tu postura',
 'Analiza diferentes perspectivas y defiende tu opinión con argumentos',
 'tribunal_opiniones', 1,
 '{"allowDebate": true}'::jsonb,
 '{"question": "¿Marie Curie debió patentar sus descubrimientos?", "positions": [{"stance": "Sí", "arguments": []}, {"stance": "No", "arguments": []}]}'::jsonb,
 'advanced', 100, 70,
 20, 3,
 40, 20,
 true),

('11111111-1111-1111-1111-111111111113',
 'Análisis de Fuentes',
 'Evalúa la credibilidad',
 'Analiza diferentes fuentes de información sobre Marie Curie y evalúa su credibilidad',
 'analisis_fuentes', 2,
 '{"multipleSource": true}'::jsonb,
 '{"sources": [{"type": "article", "title": "Biografía oficial", "credibility": "high"}, {"type": "blog", "title": "Post anónimo", "credibility": "low"}]}'::jsonb,
 'advanced', 100, 70,
 20, 3,
 40, 20,
 true),

('11111111-1111-1111-1111-111111111113',
 'Matriz de Perspectivas',
 'Compara diferentes puntos de vista',
 'Analiza cómo diferentes grupos veían el trabajo de Marie Curie',
 'matriz_perspectivas', 3,
 '{"compareViews": true}'::jsonb,
 '{"perspectives": [{"group": "Comunidad científica", "view": "Revolucionario"}, {"group": "Sociedad conservadora", "view": "Controversial"}]}'::jsonb,
 'advanced', 100, 70,
 20, 3,
 40, 20,
 true);

-- ========================================================================
-- MÓDULO 4: Lectura Digital - 3 Ejercicios
-- ========================================================================

INSERT INTO educational_content.exercises (
    module_id, title, subtitle, description,
    exercise_type, order_index,
    config, content,
    difficulty_level, max_points, passing_score,
    estimated_time_minutes, max_attempts,
    xp_reward, ml_coins_reward,
    is_active
) VALUES
('11111111-1111-1111-1111-111111111114',
 'Infografía Interactiva',
 'Explora la línea de tiempo visual',
 'Navega por una infografía interactiva sobre los descubrimientos de Marie',
 'infografia_interactiva', 1,
 '{"interactiveElements": true}'::jsonb,
 '{"sections": [{"title": "Descubrimientos", "content": "Polonio y Radio"}, {"title": "Premios", "content": "Dos Premios Nobel"}]}'::jsonb,
 'intermediate', 100, 70,
 15, 3,
 30, 15,
 true),

('11111111-1111-1111-1111-111111111114',
 'Navegación Hipertextual',
 'Explora contenido enlazado',
 'Navega entre diferentes textos relacionados y encuentra las conexiones',
 'navegacion_hipertextual', 2,
 '{"allowNavigation": true}'::jsonb,
 '{"nodes": [{"id": "bio", "title": "Biografía", "links": ["discoveries", "awards"]}, {"id": "discoveries", "title": "Descubrimientos"}]}'::jsonb,
 'intermediate', 100, 70,
 15, 3,
 30, 15,
 true),

('11111111-1111-1111-1111-111111111114',
 'Quiz TikTok',
 'Respuestas rápidas',
 'Quiz dinámico de preguntas rápidas sobre Marie Curie',
 'quiz_tiktok', 3,
 '{"timedQuestions": true}'::jsonb,
 '{"questions": [{"question": "¿Cuántos Premios Nobel ganó Marie?", "answer": "2", "timeLimit": 10}]}'::jsonb,
 'intermediate', 100, 70,
 10, 3,
 30, 15,
 true);

-- Update total_exercises count for each module
UPDATE educational_content.modules
SET total_exercises = (
    SELECT COUNT(*)
    FROM educational_content.exercises e
    WHERE e.module_id = modules.id
)
WHERE id IN (
    '11111111-1111-1111-1111-111111111111',
    '11111111-1111-1111-1111-111111111112',
    '11111111-1111-1111-1111-111111111113',
    '11111111-1111-1111-1111-111111111114'
);

COMMIT;

-- Summary
DO $$
DECLARE
    total_exercises INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_exercises FROM educational_content.exercises;
    RAISE NOTICE '✅ Ejercicios cargados exitosamente: %', total_exercises;
    RAISE NOTICE '  - Módulo 1: 5 ejercicios';
    RAISE NOTICE '  - Módulo 2: 3 ejercicios';
    RAISE NOTICE '  - Módulo 3: 3 ejercicios';
    RAISE NOTICE '  - Módulo 4: 3 ejercicios';
END $$;
