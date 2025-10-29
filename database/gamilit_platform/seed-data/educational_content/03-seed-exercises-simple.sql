-- ============================================================================
-- File: 08_module1_marie_curie_exercises_update.sql
-- Description: Module 1 - Marie Curie Exercises (All 5 exercises corrected)
-- Based on: /home/isem/workspace/docs/projects/glit/05-educational-modules/
-- Created: 2025-10-17
-- ============================================================================

BEGIN;

-- ============================================================================
-- MODULE 1: COMPRENSIÓN LITERAL - MARIE CURIE
-- Based on Daniel Cassany's comprehension levels
-- 5 exercises: timeline, true_false, matching, fill_in_blank, crossword
-- ============================================================================

-- First, ensure module exists
INSERT INTO educational_content.modules (
    title, subtitle, description, summary,
    order_index, module_code,
    difficulty_level, grade_levels, subjects,
    estimated_duration_minutes, estimated_sessions,
    learning_objectives, competencies, skills_developed,
    maya_rank_required, xp_reward, ml_coins_reward,
    status, is_published, is_featured, published_at
) VALUES (
    'Comprensión Literal - Marie Curie',
    'Descubre los Hechos Básicos de la Vida de Marie Curie',
    'Aprende a identificar información explícita en textos biográficos sobre Marie Curie. Desarrolla habilidades para reconocer fechas, nombres, lugares y eventos específicos.',
    'Módulo introductorio que trabaja la comprensión literal mediante 5 mecánicas interactivas: línea de tiempo, verdadero/falso, emparejamiento, completar espacios y crucigrama.',
    1, 'MOD-01-MARIE-CURIE',
    'beginner', ARRAY['6', '7', '8'], ARRAY['Literatura', 'Ciencias', 'Historia'],
    180, 5,
    ARRAY[
        'Identificar información explícita en textos biográficos',
        'Reconocer fechas y eventos importantes en la vida de Marie Curie',
        'Localizar nombres propios y lugares mencionados',
        'Recordar detalles específicos sobre sus descubrimientos científicos'
    ],
    ARRAY[
        'Competencia lectora nivel literal',
        'Comprensión de textos científicos',
        'Memoria y retención de información'
    ],
    ARRAY[
        'Lectura comprensiva',
        'Identificación de datos explícitos',
        'Organización cronológica',
        'Vocabulario científico'
    ],
    NULL, 100, 50,
    'published', true, true, now()
)
ON CONFLICT (module_code) DO UPDATE SET
    title = EXCLUDED.title,
    subtitle = EXCLUDED.subtitle,
    description = EXCLUDED.description,
    summary = EXCLUDED.summary,
    learning_objectives = EXCLUDED.learning_objectives,
    updated_at = now();

-- Get Module 1 ID
DO $$
DECLARE
    mod1_id UUID;
BEGIN
    SELECT id INTO mod1_id FROM educational_content.modules WHERE module_code = 'MOD-01-MARIE-CURIE';

    -- ========================================================================
    -- EXERCISE 1: LÍNEA DE TIEMPO (Timeline)
    -- Based on: image 1 - 4 events from Marie Curie's life
    -- ========================================================================
    INSERT INTO educational_content.exercises (
        module_id, title, subtitle, description, instructions,
        exercise_type, order_index,
        config, content, solution,
        difficulty_level, max_points, passing_score,
        estimated_time_minutes, time_limit_minutes, max_attempts,
        hints, enable_hints, hint_cost_ml_coins,
        comodines_allowed, comodines_config,
        xp_reward, ml_coins_reward,
        is_active, version
    ) VALUES (
        mod1_id,
        'Línea de Tiempo de Marie Curie',
        'Ordena los Eventos Cronológicamente',
        'Organiza los eventos más importantes de la vida de Marie Curie en orden cronológico correcto.',
        'Arrastra los eventos a la línea de tiempo en el orden correcto. Comienza con el evento más antiguo.',
        'linea_tiempo', 1,
        '{
            "allowReordering": true,
            "showYears": true,
            "visualStyle": "horizontal",
            "snapToGrid": true
        }'::jsonb,
        '{
            "events": [
                {
                    "id": "event-1",
                    "year": 1867,
                    "title": "Nace en Varsovia, Polonia, como Maria Sklodowska",
                    "description": "Nace en Varsovia, Polonia, como Maria Sklodowska",
                    "category": "Personal"
                },
                {
                    "id": "event-2",
                    "year": 1891,
                    "title": "Se traslada a París para estudiar en la Sorbona",
                    "description": "Se traslada a París para estudiar en la Sorbona",
                    "category": "Educación"
                },
                {
                    "id": "event-3",
                    "year": 1903,
                    "title": "Recibe su primer Premio Nobel de Física",
                    "description": "Recibe su primer Premio Nobel de Física",
                    "category": "Reconocimiento"
                },
                {
                    "id": "event-4",
                    "year": 1911,
                    "title": "Recibe su segundo Premio Nobel, esta vez en Química",
                    "description": "Recibe su segundo Premio Nobel, esta vez en Química",
                    "category": "Reconocimiento"
                }
            ],
            "categories": ["Personal", "Educación", "Reconocimiento"]
        }'::jsonb,
        '{
            "correctOrder": ["event-1", "event-2", "event-3", "event-4"],
            "yearSequence": [1867, 1891, 1903, 1911]
        }'::jsonb,
        'easy', 100, 70,
        5, 8, 3,
        '[
            {"id": "hint-1", "text": "Marie nació en el siglo XIX", "cost": 15},
            {"id": "hint-2", "text": "Estudió en París antes de recibir premios", "cost": 15},
            {"id": "hint-3", "text": "Recibió dos Premios Nobel en diferentes años", "cost": 15}
        ]'::jsonb,
        true, 15,
        '["pista_reveladora", "verificar_parcial", "segunda_oportunidad"]'::jsonb,
        '{
            "pista_reveladora": {"uses": 1, "ml_cost": 25},
            "verificar_parcial": {"uses": 2, "ml_cost": 20},
            "segunda_oportunidad": {"uses": 1, "ml_cost": 30}
        }'::jsonb,
        20, 10,
        true, 1
    )
    ON CONFLICT (module_id, exercise_type, order_index)
    DO UPDATE SET
        content = EXCLUDED.content,
        solution = EXCLUDED.solution,
        updated_at = now();

    -- ========================================================================
    -- EXERCISE 2: VERDADERO/FALSO (True/False)
    -- Based on: image 2 - 4 statements about Marie Curie's early life
    -- ========================================================================
    INSERT INTO educational_content.exercises (
        module_id, title, subtitle, description, instructions,
        exercise_type, order_index,
        config, content, solution,
        difficulty_level, max_points, passing_score,
        estimated_time_minutes, time_limit_minutes, max_attempts,
        hints, enable_hints, hint_cost_ml_coins,
        comodines_allowed, comodines_config,
        xp_reward, ml_coins_reward,
        is_active, version
    ) VALUES (
        mod1_id,
        'Evalúa si estas afirmaciones sobre la juventud de Marie Curie son verdaderas o falsas',
        'Verdadero o Falso',
        'Lee cada afirmación y determina si es verdadera o falsa según el contexto histórico de Marie Curie.',
        'Lee cuidadosamente cada afirmación. Marca Verdadero o Falso según corresponda.',
        'verdadero_falso', 2,
        '{
            "showExplanations": true,
            "randomizeOrder": false,
            "allowReview": true
        }'::jsonb,
        '{
            "contextText": "Durante su infancia en Polonia, Marie era conocida por su insaciable curiosidad científica. Su padre le enseñó los primeros principios de las matemáticas y la física, mientras su madre la inspiró con su dedicación a la educación.",
            "statements": [
                {
                    "id": "stmt-1",
                    "statement": "Marie mostró curiosidad excepcional por las ciencias desde muy pequeña",
                    "correctAnswer": true,
                    "explanation": "Correcto. Desde su infancia, Marie mostró un gran interés por las ciencias, influenciada por su padre."
                },
                {
                    "id": "stmt-2",
                    "statement": "Su padre era profesor de química solamente",
                    "correctAnswer": false,
                    "explanation": "Falso. Su padre, Władysław Sklodowska, era profesor de matemáticas y física, no solo de química."
                },
                {
                    "id": "stmt-3",
                    "statement": "Marie nació en Francia",
                    "correctAnswer": false,
                    "explanation": "Falso. Marie Curie nació en Varsovia, Polonia, no en Francia. Se mudó a Francia más tarde para estudiar."
                },
                {
                    "id": "stmt-4",
                    "statement": "Su familia valoraba mucho la educación",
                    "correctAnswer": true,
                    "explanation": "Correcto. La familia Sklodowska tenía una fuerte tradición educativa y valoraba profundamente el conocimiento."
                }
            ]
        }'::jsonb,
        '{
            "answers": [
                {"id": "stmt-1", "value": true},
                {"id": "stmt-2", "value": false},
                {"id": "stmt-3", "value": false},
                {"id": "stmt-4", "value": true}
            ]
        }'::jsonb,
        'easy', 100, 75,
        5, 8, 3,
        '[
            {"id": "hint-vf1", "text": "Marie Curie nació en Polonia y vivió allí durante su infancia", "cost": 15},
            {"id": "hint-vf2", "text": "Su padre enseñaba tanto matemáticas como física", "cost": 15},
            {"id": "hint-vf3", "text": "La familia Sklodowska valoraba profundamente la educación", "cost": 15}
        ]'::jsonb,
        true, 15,
        '["eliminar_opcion", "verificar_parcial", "segunda_oportunidad"]'::jsonb,
        '{
            "eliminar_opcion": {"uses": 2, "ml_cost": 20},
            "verificar_parcial": {"uses": 2, "ml_cost": 20},
            "segunda_oportunidad": {"uses": 1, "ml_cost": 30}
        }'::jsonb,
        20, 10,
        true, 1
    )
    ON CONFLICT (module_id, exercise_type, order_index)
    DO UPDATE SET
        content = EXCLUDED.content,
        solution = EXCLUDED.solution,
        updated_at = now();

    -- ========================================================================
    -- EXERCISE 3: EMPAREJAMIENTO (Matching)
    -- Based on: image 3 - 4 pairs of scientific terms
    -- ========================================================================
    INSERT INTO educational_content.exercises (
        module_id, title, subtitle, description, instructions,
        exercise_type, order_index,
        config, content, solution,
        difficulty_level, max_points, passing_score,
        estimated_time_minutes, time_limit_minutes, max_attempts,
        hints, enable_hints, hint_cost_ml_coins,
        comodines_allowed, comodines_config,
        xp_reward, ml_coins_reward,
        is_active, version
    ) VALUES (
        mod1_id,
        'Empareja los Conceptos Científicos',
        'Relaciona Términos con sus Definiciones',
        'Conecta cada término científico con su definición correcta relacionada con los descubrimientos de Marie Curie.',
        'Haz clic en una tarjeta de término y luego en su definición correspondiente para emparejarlas.',
        'emparejamiento', 3,
        '{
            "matchingType": "cards",
            "allowMultipleAttempts": true,
            "showFeedbackImmediately": false,
            "shuffleCards": true
        }'::jsonb,
        '{
            "scenarioText": "Marie Curie realizó descubrimientos fundamentales en el campo de la radiactividad. Los siguientes términos están relacionados con su trabajo pionero.",
            "pairs": [
                {
                    "id": "pair-1",
                    "left": {
                        "id": "q1",
                        "content": "Radio",
                        "type": "term"
                    },
                    "right": {
                        "id": "a1",
                        "content": "Elemento que brilla en la oscuridad",
                        "type": "definition"
                    }
                },
                {
                    "id": "pair-2",
                    "left": {
                        "id": "q2",
                        "content": "Polonio",
                        "type": "term"
                    },
                    "right": {
                        "id": "a2",
                        "content": "Elemento nombrado en honor a su país natal",
                        "type": "definition"
                    }
                },
                {
                    "id": "pair-3",
                    "left": {
                        "id": "q3",
                        "content": "Radiactividad",
                        "type": "term"
                    },
                    "right": {
                        "id": "a3",
                        "content": "Término acuñado por Marie para describir la emisión de rayos",
                        "type": "definition"
                    }
                },
                {
                    "id": "pair-4",
                    "left": {
                        "id": "q4",
                        "content": "Pechblenda",
                        "type": "term"
                    },
                    "right": {
                        "id": "a4",
                        "content": "Mineral del cual extrajo elementos radiactivos",
                        "type": "definition"
                    }
                }
            ]
        }'::jsonb,
        '{
            "correctPairs": [
                {"leftId": "q1", "rightId": "a1"},
                {"leftId": "q2", "rightId": "a2"},
                {"leftId": "q3", "rightId": "a3"},
                {"leftId": "q4", "rightId": "a4"}
            ]
        }'::jsonb,
        'medium', 100, 75,
        6, 10, 3,
        '[
            {"id": "hint-match1", "text": "El Radio es conocido por su luminiscencia", "cost": 15},
            {"id": "hint-match2", "text": "Polonia es el país natal de Marie Curie", "cost": 15},
            {"id": "hint-match3", "text": "La Pechblenda es un mineral de uranio", "cost": 15}
        ]'::jsonb,
        true, 15,
        '["revelar_pareja", "verificar_parcial", "segunda_oportunidad"]'::jsonb,
        '{
            "revelar_pareja": {"uses": 1, "ml_cost": 25},
            "verificar_parcial": {"uses": 2, "ml_cost": 20},
            "segunda_oportunidad": {"uses": 1, "ml_cost": 30}
        }'::jsonb,
        20, 10,
        true, 1
    )
    ON CONFLICT (module_id, exercise_type, order_index)
    DO UPDATE SET
        content = EXCLUDED.content,
        solution = EXCLUDED.solution,
        updated_at = now();

    -- ========================================================================
    -- EXERCISE 4: COMPLETAR ESPACIOS (Fill in the Blanks)
    -- Based on: image 4 - Text with 6 blanks and word bank
    -- ========================================================================
    INSERT INTO educational_content.exercises (
        module_id, title, subtitle, description, instructions,
        exercise_type, order_index,
        config, content, solution,
        difficulty_level, max_points, passing_score,
        estimated_time_minutes, time_limit_minutes, max_attempts,
        hints, enable_hints, hint_cost_ml_coins,
        comodines_allowed, comodines_config,
        xp_reward, ml_coins_reward,
        is_active, version
    ) VALUES (
        mod1_id,
        'Completa los espacios en blanco',
        'Información sobre la Familia de Marie Curie',
        'Lee el texto y completa los espacios en blanco con las palabras correctas del banco de palabras.',
        'Selecciona una palabra del banco y haz clic en el espacio que deseas completar. Puedes cambiar tu respuesta antes de verificar.',
        'completar_espacios', 4,
        '{
            "caseSensitive": false,
            "allowTyping": false,
            "wordBankMode": "selection",
            "showWordBank": true
        }'::jsonb,
        '{
            "scenarioText": "Marie Curie provenía de una familia polaca muy dedicada a la educación y las ciencias. Sus padres fueron grandes influencias en su desarrollo intelectual.",
            "text": "Marie Sklodowska nació en ___, Polonia. Su padre ___ era profesor de matemáticas y física, mientras que su madre ___ dirigía una escuela prestigiosa. La familia valoraba mucho la ___ y Marie mostró desde pequeña gran curiosidad por las ___ y ___.",
            "blanks": [
                {
                    "id": "blank-1",
                    "position": 0,
                    "correctAnswer": "Varsovia",
                    "alternatives": ["varsovia"]
                },
                {
                    "id": "blank-2",
                    "position": 1,
                    "correctAnswer": "Władysław",
                    "alternatives": ["Wladyslaw", "władysław", "wladyslaw"]
                },
                {
                    "id": "blank-3",
                    "position": 2,
                    "correctAnswer": "Bronisława",
                    "alternatives": ["Bronislawa", "bronisława", "bronislawa"]
                },
                {
                    "id": "blank-4",
                    "position": 3,
                    "correctAnswer": "educación",
                    "alternatives": ["educacion"]
                },
                {
                    "id": "blank-5",
                    "position": 4,
                    "correctAnswer": "ciencias",
                    "alternatives": []
                },
                {
                    "id": "blank-6",
                    "position": 5,
                    "correctAnswer": "matemáticas",
                    "alternatives": ["matematicas"]
                }
            ],
            "wordBank": [
                "Varsovia",
                "Władysław",
                "Bronisława",
                "educación",
                "ciencias",
                "Polonia",
                "matemáticas",
                "física"
            ]
        }'::jsonb,
        '{
            "correctAnswers": [
                {"blankId": "blank-1", "answer": "Varsovia"},
                {"blankId": "blank-2", "answer": "Władysław"},
                {"blankId": "blank-3", "answer": "Bronisława"},
                {"blankId": "blank-4", "answer": "educación"},
                {"blankId": "blank-5", "answer": "ciencias"},
                {"blankId": "blank-6", "answer": "matemáticas"}
            ]
        }'::jsonb,
        'medium', 100, 70,
        6, 10, 3,
        '[
            {"id": "hint-ce1", "text": "Marie nació en la capital de Polonia", "cost": 15},
            {"id": "hint-ce2", "text": "El nombre del padre empieza con W", "cost": 15},
            {"id": "hint-ce3", "text": "La madre se llamaba Bronisława", "cost": 15}
        ]'::jsonb,
        true, 15,
        '["revelar_palabra", "verificar_parcial", "segunda_oportunidad"]'::jsonb,
        '{
            "revelar_palabra": {"uses": 2, "ml_cost": 20},
            "verificar_parcial": {"uses": 2, "ml_cost": 20},
            "segunda_oportunidad": {"uses": 1, "ml_cost": 30}
        }'::jsonb,
        20, 10,
        true, 1
    )
    ON CONFLICT (module_id, exercise_type, order_index)
    DO UPDATE SET
        content = EXCLUDED.content,
        solution = EXCLUDED.solution,
        updated_at = now();

    -- ========================================================================
    -- EXERCISE 5: CRUCIGRAMA 15x15 (Crossword)
    -- Based on: PDF specification - 15x15 grid with 6 words
    -- ========================================================================
    INSERT INTO educational_content.exercises (
        module_id, title, subtitle, description, instructions,
        exercise_type, order_index,
        config, content, solution,
        difficulty_level, max_points, passing_score,
        estimated_time_minutes, time_limit_minutes, max_attempts,
        hints, enable_hints, hint_cost_ml_coins,
        comodines_allowed, comodines_config,
        xp_reward, ml_coins_reward,
        is_active, version
    ) VALUES (
        mod1_id,
        'Crucigrama Científico: Marie Curie',
        'Vocabulario de Radioactividad',
        'Completa el crucigrama 15×15 con términos relacionados con Marie Curie y sus descubrimientos científicos.',
        'Lee las pistas horizontales y verticales. Haz clic en una casilla para comenzar a escribir. Usa las flechas del teclado para moverte.',
        'crucigrama', 5,
        '{
            "gridSize": {"rows": 15, "cols": 15},
            "autoCheck": true,
            "showProgress": true,
            "keyboardNav": true,
            "allowPencilMarks": true
        }'::jsonb,
        '{
            "clues": [
                {
                    "id": "h1",
                    "number": 1,
                    "direction": "horizontal",
                    "clue": "Fenómeno que Marie estudió toda su vida",
                    "answer": "RADIACTIVIDAD",
                    "startRow": 5,
                    "startCol": 1,
                    "length": 14
                },
                {
                    "id": "v1",
                    "number": 2,
                    "direction": "vertical",
                    "clue": "Elemento nombrado por su país natal",
                    "answer": "POLONIO",
                    "startRow": 2,
                    "startCol": 5,
                    "length": 7
                },
                {
                    "id": "h2",
                    "number": 3,
                    "direction": "horizontal",
                    "clue": "Elemento químico que brilla en la oscuridad",
                    "answer": "RADIO",
                    "startRow": 8,
                    "startCol": 3,
                    "length": 5
                },
                {
                    "id": "v2",
                    "number": 4,
                    "direction": "vertical",
                    "clue": "Premio internacional que ganó dos veces",
                    "answer": "NOBEL",
                    "startRow": 1,
                    "startCol": 10,
                    "length": 5
                },
                {
                    "id": "h3",
                    "number": 5,
                    "direction": "horizontal",
                    "clue": "Universidad de París donde estudió",
                    "answer": "SORBONA",
                    "startRow": 10,
                    "startCol": 4,
                    "length": 7
                },
                {
                    "id": "v3",
                    "number": 6,
                    "direction": "vertical",
                    "clue": "Apellido de casada de Marie",
                    "answer": "CURIE",
                    "startRow": 3,
                    "startCol": 12,
                    "length": 5
                }
            ]
        }'::jsonb,
        '{
            "grid": "R_______________A___N___O_____RADIACTIVIDADB___L_____E____RADIOL__________SORBONA________C___U__________U___R__________R___I__________I___E__________E___"
        }'::jsonb,
        'medium', 100, 70,
        10, 15, 3,
        '[
            {"id": "hint-cruz1", "text": "La palabra más larga cruza casi todo el tablero", "cost": 15},
            {"id": "hint-cruz2", "text": "Polonia es el país natal de Marie Curie", "cost": 15},
            {"id": "hint-cruz3", "text": "Marie estudió en la universidad más prestigiosa de París", "cost": 15}
        ]'::jsonb,
        true, 15,
        '["revelar_palabra", "verificar_parcial", "segunda_oportunidad"]'::jsonb,
        '{
            "revelar_palabra": {"uses": 1, "ml_cost": 30},
            "verificar_parcial": {"uses": 2, "ml_cost": 20},
            "segunda_oportunidad": {"uses": 1, "ml_cost": 30}
        }'::jsonb,
        20, 10,
        true, 1
    )
    ON CONFLICT (module_id, exercise_type, order_index)
    DO UPDATE SET
        content = EXCLUDED.content,
        solution = EXCLUDED.solution,
        updated_at = now();

    RAISE NOTICE '✓ Module 1: Marie Curie - 5 exercises created/updated successfully';
END $$;

COMMIT;

-- ============================================================================
-- Verification Query
-- ============================================================================
DO $$
DECLARE
    module_exists BOOLEAN;
    exercise_count INTEGER;
BEGIN
    SELECT EXISTS(SELECT 1 FROM educational_content.modules WHERE module_code = 'MOD-01-MARIE-CURIE') INTO module_exists;
    SELECT COUNT(*) INTO exercise_count FROM educational_content.exercises e
    JOIN educational_content.modules m ON e.module_id = m.id
    WHERE m.module_code = 'MOD-01-MARIE-CURIE';

    IF module_exists THEN
        RAISE NOTICE '✓ Module 1 seed completed successfully';
        RAISE NOTICE '  - Module: Comprensión Literal - Marie Curie';
        RAISE NOTICE '  - Exercises created: %', exercise_count;
        RAISE NOTICE '';
        RAISE NOTICE 'Exercise breakdown:';
        RAISE NOTICE '  1. Timeline (Línea de Tiempo) - 4 events';
        RAISE NOTICE '  2. True/False (Verdadero/Falso) - 4 statements';
        RAISE NOTICE '  3. Matching (Emparejamiento) - 4 pairs';
        RAISE NOTICE '  4. Fill in Blanks (Completar Espacios) - 6 blanks';
        RAISE NOTICE '  5. Crossword (Crucigrama) - 15×15 grid, 6 words';
    ELSE
        RAISE WARNING '⚠ Module 1 was not created successfully';
    END IF;
END $$;
