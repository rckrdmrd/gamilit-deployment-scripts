-- ============================================================================
-- File: 05-seed-module1-complete.sql  
-- Description: Module 1 - Complete Marie Curie Exercises (5 exercises)
-- Adapted from glit seed data
-- ============================================================================

BEGIN;

-- Módulo 1 ID fijo: 11111111-1111-1111-1111-111111111111

-- ========================================================================
-- EXERCISE 1: LÍNEA DE TIEMPO
-- ========================================================================
INSERT INTO educational_content.exercises (
    module_id, title, subtitle, description, instructions,
    exercise_type, order_index,
    config, content, solution,
    difficulty_level, max_points, passing_score,
    estimated_time_minutes, time_limit_minutes, max_attempts,
    enable_hints, hint_cost_ml_coins,
    xp_reward, ml_coins_reward,
    is_active
) VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'Línea de Tiempo de Marie Curie',
    'Ordena los Eventos Cronológicamente',
    'Organiza los eventos más importantes de la vida de Marie Curie en orden cronológico correcto.',
    'Arrastra los eventos a la línea de tiempo en el orden correcto. Comienza con el evento más antiguo.',
    'linea_tiempo', 1,
    '{"allowReordering": true, "showYears": true, "visualStyle": "horizontal"}'::jsonb,
    '{
        "events": [
            {"id": "event-1", "year": 1867, "title": "Nace en Varsovia, Polonia, como Maria Sklodowska", "description": "Nace en Varsovia, Polonia", "category": "Personal"},
            {"id": "event-2", "year": 1891, "title": "Se traslada a París para estudiar en la Sorbona", "description": "Se traslada a París", "category": "Educación"},
            {"id": "event-3", "year": 1903, "title": "Recibe su primer Premio Nobel de Física", "description": "Primer Premio Nobel", "category": "Reconocimiento"},
            {"id": "event-4", "year": 1911, "title": "Recibe su segundo Premio Nobel, esta vez en Química", "description": "Segundo Premio Nobel", "category": "Reconocimiento"}
        ],
        "categories": ["Personal", "Educación", "Reconocimiento"]
    }'::jsonb,
    '{"correctOrder": ["event-1", "event-2", "event-3", "event-4"], "yearSequence": [1867, 1891, 1903, 1911]}'::jsonb,
    'beginner', 100, 70,
    5, 8, 3,
    true, 15,
    20, 10,
    true
);

-- ========================================================================
-- EXERCISE 2: VERDADERO/FALSO
-- ========================================================================
INSERT INTO educational_content.exercises (
    module_id, title, subtitle, description, instructions,
    exercise_type, order_index,
    config, content, solution,
    difficulty_level, max_points, passing_score,
    estimated_time_minutes, max_attempts,
    enable_hints, hint_cost_ml_coins,
    xp_reward, ml_coins_reward,
    is_active
) VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'Verdadero o Falso sobre Marie Curie',
    'Evalúa las Afirmaciones',
    'Lee cada afirmación y determina si es verdadera o falsa según el contexto histórico de Marie Curie.',
    'Lee cuidadosamente cada afirmación. Marca Verdadero o Falso según corresponda.',
    'verdadero_falso', 2,
    '{"showExplanations": true, "randomizeOrder": false}'::jsonb,
    '{
        "contextText": "Durante su infancia en Polonia, Marie era conocida por su insaciable curiosidad científica. Su padre le enseñó los primeros principios de las matemáticas y la física.",
        "statements": [
            {"id": "stmt-1", "statement": "Marie mostró curiosidad excepcional por las ciencias desde muy pequeña", "correctAnswer": true, "explanation": "Correcto. Desde su infancia, Marie mostró un gran interés por las ciencias, influenciada por su padre."},
            {"id": "stmt-2", "statement": "Su padre era profesor de química solamente", "correctAnswer": false, "explanation": "Falso. Su padre era profesor de matemáticas y física, no solo de química."},
            {"id": "stmt-3", "statement": "Marie nació en Francia", "correctAnswer": false, "explanation": "Falso. Marie Curie nació en Varsovia, Polonia, no en Francia."},
            {"id": "stmt-4", "statement": "Su familia valoraba mucho la educación", "correctAnswer": true, "explanation": "Correcto. La familia Sklodowska tenía una fuerte tradición educativa."}
        ]
    }'::jsonb,
    '{"answers": [{"id": "stmt-1", "value": true}, {"id": "stmt-2", "value": false}, {"id": "stmt-3", "value": false}, {"id": "stmt-4", "value": true}]}'::jsonb,
    'beginner', 100, 75,
    5, 3,
    true, 15,
    20, 10,
    true
);

-- ========================================================================
-- EXERCISE 3: EMPAREJAMIENTO
-- ========================================================================
INSERT INTO educational_content.exercises (
    module_id, title, subtitle, description, instructions,
    exercise_type, order_index,
    config, content, solution,
    difficulty_level, max_points, passing_score,
    estimated_time_minutes, max_attempts,
    xp_reward, ml_coins_reward,
    is_active
) VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'Empareja los Conceptos Científicos',
    'Relaciona Términos con sus Definiciones',
    'Conecta cada término científico con su definición correcta relacionada con los descubrimientos de Marie Curie.',
    'Haz clic en una tarjeta de término y luego en su definición correspondiente para emparejarlas.',
    'emparejamiento', 3,
    '{"matchingType": "cards", "allowMultipleAttempts": true, "shuffleCards": true}'::jsonb,
    '{
        "scenarioText": "Marie Curie realizó descubrimientos fundamentales en el campo de la radiactividad. Los siguientes términos están relacionados con su trabajo pionero.",
        "pairs": [
            {"id": "pair-1", "left": {"id": "q1", "content": "Radio", "type": "term"}, "right": {"id": "a1", "content": "Elemento que brilla en la oscuridad", "type": "definition"}},
            {"id": "pair-2", "left": {"id": "q2", "content": "Polonio", "type": "term"}, "right": {"id": "a2", "content": "Elemento nombrado en honor a su país natal", "type": "definition"}},
            {"id": "pair-3", "left": {"id": "q3", "content": "Radioactividad", "type": "term"}, "right": {"id": "a3", "content": "Emisión espontánea de radiación", "type": "definition"}},
            {"id": "pair-4", "left": {"id": "q4", "content": "Pechblenda", "type": "term"}, "right": {"id": "a4", "content": "Mineral del que Marie extrajo el radio", "type": "definition"}}
        ]
    }'::jsonb,
    '{"correctPairs": [{"left": "q1", "right": "a1"}, {"left": "q2", "right": "a2"}, {"left": "q3", "right": "a3"}, {"left": "q4", "right": "a4"}]}'::jsonb,
    'beginner', 100, 70,
    10, 3,
    25, 12,
    true
);

-- ========================================================================
-- EXERCISE 4: COMPLETAR ESPACIOS
-- ========================================================================
INSERT INTO educational_content.exercises (
    module_id, title, subtitle, description, instructions,
    exercise_type, order_index,
    config, content, solution,
    difficulty_level, max_points, passing_score,
    estimated_time_minutes, max_attempts,
    xp_reward, ml_coins_reward,
    is_active
) VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'Completa el Texto sobre Marie Curie',
    'Rellena los Espacios en Blanco',
    'Completa las oraciones con las palabras correctas sobre la vida y descubrimientos de Marie Curie.',
    'Lee cada oración y completa los espacios en blanco con las palabras adecuadas.',
    'completar_espacios', 4,
    '{"allowHints": true, "caseSensitive": false}'::jsonb,
    '{
        "text": "Marie Curie descubrió dos elementos radiactivos: el ____ y el ____. Nació en ____, Polonia, en 1867. Se mudó a ____ para estudiar en la Sorbona. Ganó ____ Premios Nobel en su vida.",
        "blanks": [
            {"id": "blank-1", "position": 1, "answer": "polonio", "alternatives": ["Polonio"], "hint": "Nombrado por su país natal"},
            {"id": "blank-2", "position": 2, "answer": "radio", "alternatives": ["Radio"], "hint": "Brilla en la oscuridad"},
            {"id": "blank-3", "position": 3, "answer": "Varsovia", "alternatives": ["varsovia"], "hint": "Capital de Polonia"},
            {"id": "blank-4", "position": 4, "answer": "París", "alternatives": ["paris", "Francia"], "hint": "Ciudad donde está la Sorbona"},
            {"id": "blank-5", "position": 5, "answer": "dos", "alternatives": ["2", "Dos"], "hint": "Uno en Física, otro en Química"}
        ]
    }'::jsonb,
    '{"answers": ["polonio", "radio", "Varsovia", "París", "dos"]}'::jsonb,
    'beginner', 100, 70,
    8, 3,
    20, 10,
    true
);

-- ========================================================================
-- EXERCISE 5: CRUCIGRAMA
-- ========================================================================
INSERT INTO educational_content.exercises (
    module_id, title, subtitle, description, instructions,
    exercise_type, order_index,
    config, content, solution,
    difficulty_level, max_points, passing_score,
    estimated_time_minutes, max_attempts,
    xp_reward, ml_coins_reward,
    is_active
) VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'Crucigrama Científico: Descubrimientos de Marie Curie',
    'Vocabulario de Radioactividad',
    'Completa el crucigrama con términos científicos relacionados con los descubrimientos de Marie Curie.',
    'Lee las pistas horizontales y verticales. Haz clic en una casilla para comenzar a escribir.',
    'crucigrama', 5,
    '{"gridSize": {"rows": 10, "cols": 10}, "autoCheck": true, "showProgress": true}'::jsonb,
    '{
        "clues": [
            {"id": "h1", "number": 1, "direction": "horizontal", "clue": "Elemento químico descubierto por Marie Curie en 1898", "answer": "RADIO", "startRow": 0, "startCol": 0, "length": 5},
            {"id": "h2", "number": 3, "direction": "horizontal", "clue": "País natal de Marie Curie", "answer": "POLONIA", "startRow": 2, "startCol": 0, "length": 7},
            {"id": "h3", "number": 5, "direction": "horizontal", "clue": "Ciudad donde Marie estudió en la Sorbona", "answer": "PARIS", "startRow": 4, "startCol": 0, "length": 5},
            {"id": "v1", "number": 2, "direction": "vertical", "clue": "Fenómeno de emisión de radiación", "answer": "RADIOACTIVIDAD", "startRow": 0, "startCol": 2, "length": 14},
            {"id": "v2", "number": 4, "direction": "vertical", "clue": "Elemento nombrado por Polonia", "answer": "POLONIO", "startRow": 2, "startCol": 4, "length": 7}
        ]
    }'::jsonb,
    '{"solution": {"h1": "RADIO", "h2": "POLONIA", "h3": "PARIS", "v1": "RADIOACTIVIDAD", "v2": "POLONIO"}}'::jsonb,
    'beginner', 100, 70,
    15, 3,
    25, 12,
    true
);

-- Update module total_exercises
UPDATE educational_content.modules
SET total_exercises = 5
WHERE id = '11111111-1111-1111-1111-111111111111';

COMMIT;

-- Summary
DO $$
BEGIN
    RAISE NOTICE '✅ Módulo 1: 5 ejercicios cargados con datos completos';
END $$;
