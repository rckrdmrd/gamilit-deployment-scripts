-- Cargar ejercicios básicos para Módulos 2, 3 y 4
-- Fecha: 2025-10-28

BEGIN;

-- ============================================================================
-- MÓDULO 2: COMPRENSIÓN INFERENCIAL
-- ============================================================================

DO $$
DECLARE
    mod2_id UUID;
BEGIN
    SELECT id INTO mod2_id FROM educational_content.modules WHERE order_index = 2 LIMIT 1;

    IF mod2_id IS NULL THEN
        RAISE EXCEPTION 'Módulo 2 no encontrado';
    END IF;

    -- Ejercicio 2.1: Detective Textual
    INSERT INTO educational_content.exercises (
        module_id, title, subtitle, description, instructions,
        exercise_type, order_index,
        config, content,
        difficulty_level, max_points, passing_score,
        estimated_time_minutes, max_attempts,
        xp_reward, ml_coins_reward,
        is_active
    ) VALUES (
        mod2_id,
        'Detective Textual: Pistas Ocultas',
        'Encuentra evidencias implícitas',
        'Analiza el texto para encontrar información que no está escrita directamente',
        'Lee cuidadosamente y selecciona las inferencias correctas basadas en las pistas del texto',
        'detective_textual', 1,
        '{"showHints": true, "timePerQuestion": 90}'::jsonb,
        '{
            "passage": "Marie Curie trabajaba largas horas en un laboratorio mal ventilado, rodeada de materiales radiactivos. A menudo llevaba tubos de ensayo con radio en los bolsillos de su bata. Sus cuadernos de investigación brillaban en la oscuridad.",
            "questions": [
                {
                    "id": "q1",
                    "question": "¿Por qué los cuadernos brillaban en la oscuridad?",
                    "options": [
                        "Usaba tinta especial fluorescente",
                        "Estaban contaminados con material radiactivo",
                        "Los escribía con lápiz luminoso",
                        "Era un efecto de la luz de la luna"
                    ],
                    "correctAnswer": 1,
                    "explanation": "La radiación del radio con el que trabajaba contaminó sus cuadernos, haciéndolos brillar"
                },
                {
                    "id": "q2",
                    "question": "¿Qué podemos inferir sobre las condiciones de seguridad en su laboratorio?",
                    "options": [
                        "Eran excelentes y muy estrictas",
                        "Eran inadecuadas y peligrosas",
                        "Seguían protocolos modernos",
                        "No trabajaba con materiales peligrosos"
                    ],
                    "correctAnswer": 1,
                    "explanation": "Llevar material radiactivo en los bolsillos y trabajar en un lugar mal ventilado indica falta de protocolos de seguridad"
                }
            ]
        }'::jsonb,
        'intermediate', 100, 70,
        15, 3,
        25, 15,
        true
    );

    -- Ejercicio 2.2: Construcción de Hipótesis
    INSERT INTO educational_content.exercises (
        module_id, title, subtitle, description, instructions,
        exercise_type, order_index,
        config, content,
        difficulty_level, max_points, passing_score,
        estimated_time_minutes, max_attempts,
        xp_reward, ml_coins_reward,
        is_active
    ) VALUES (
        mod2_id,
        'Construcción de Hipótesis Científicas',
        'Predice consecuencias',
        'Formula hipótesis sobre las consecuencias de los descubrimientos de Marie Curie',
        'Lee cada escenario y selecciona la hipótesis más probable',
        'construccion_hipotesis', 2,
        '{"allowMultiple": false, "showFeedback": true}'::jsonb,
        '{
            "scenarios": [
                {
                    "id": "s1",
                    "situation": "Marie Curie descubre que el radio emite energía constantemente sin aparente fuente externa",
                    "question": "¿Qué hipótesis podría formular sobre este fenómeno?",
                    "hypotheses": [
                        {
                            "id": "h1",
                            "text": "El radio absorbe energía del aire circundante",
                            "isCorrect": false,
                            "feedback": "Esta hipótesis no explica la emisión constante de energía"
                        },
                        {
                            "id": "h2",
                            "text": "El átomo de radio se desintegra liberando energía de su núcleo",
                            "isCorrect": true,
                            "feedback": "Correcto. Esto llevó al descubrimiento de la radioactividad y la desintegración atómica"
                        },
                        {
                            "id": "h3",
                            "text": "El radio tiene propiedades mágicas inexplicables",
                            "isCorrect": false,
                            "feedback": "Las hipótesis científicas deben basarse en explicaciones naturales"
                        }
                    ]
                },
                {
                    "id": "s2",
                    "situation": "Marie observa que los investigadores que trabajan con radio se enferman con frecuencia",
                    "question": "¿Qué relación podría inferir?",
                    "hypotheses": [
                        {
                            "id": "h1",
                            "text": "Las enfermedades son coincidenciales",
                            "isCorrect": false,
                            "feedback": "La frecuencia sugiere una relación causal"
                        },
                        {
                            "id": "h2",
                            "text": "La exposición al radio causa efectos nocivos en la salud",
                            "isCorrect": true,
                            "feedback": "Correcto. La radiación tiene efectos biológicos dañinos"
                        }
                    ]
                }
            ]
        }'::jsonb,
        'intermediate', 100, 70,
        12, 3,
        25, 15,
        true
    );

    RAISE NOTICE '✅ Módulo 2: 2 ejercicios cargados';
END $$;

-- ============================================================================
-- MÓDULO 3: COMPRENSIÓN CRÍTICA
-- ============================================================================

DO $$
DECLARE
    mod3_id UUID;
BEGIN
    SELECT id INTO mod3_id FROM educational_content.modules WHERE order_index = 3 LIMIT 1;

    IF mod3_id IS NULL THEN
        RAISE EXCEPTION 'Módulo 3 no encontrado';
    END IF;

    -- Ejercicio 3.1: Análisis de Fuentes
    INSERT INTO educational_content.exercises (
        module_id, title, subtitle, description, instructions,
        exercise_type, order_index,
        config, content,
        difficulty_level, max_points, passing_score,
        estimated_time_minutes, max_attempts,
        xp_reward, ml_coins_reward,
        is_active
    ) VALUES (
        mod3_id,
        'Análisis de Fuentes Históricas',
        'Evalúa la credibilidad',
        'Analiza diferentes fuentes sobre Marie Curie y evalúa su confiabilidad',
        'Lee cada fuente y ordénalas según su credibilidad',
        'analisis_fuentes', 1,
        '{"dragAndDrop": true, "showCriteria": true}'::jsonb,
        '{
            "sources": [
                {
                    "id": "src1",
                    "title": "Artículo académico revisado por pares",
                    "author": "Dr. Jean-Pierre Lumière",
                    "date": "2020",
                    "excerpt": "Marie Curie revolucionó la física nuclear con sus descubrimientos del radio y polonio...",
                    "credibility": "alta"
                },
                {
                    "id": "src2",
                    "title": "Blog personal anónimo",
                    "author": "Anónimo",
                    "date": "2023",
                    "excerpt": "Marie Curie fue sobrevalorada...",
                    "credibility": "baja"
                },
                {
                    "id": "src3",
                    "title": "Biografía académica",
                    "author": "Dra. Eve Curie",
                    "date": "1937",
                    "excerpt": "Mi madre trabajaba incansablemente...",
                    "credibility": "media-alta"
                }
            ]
        }'::jsonb,
        'advanced', 100, 70,
        20, 3,
        35, 18,
        true
    );

    -- Ejercicio 3.2: Debate Digital
    INSERT INTO educational_content.exercises (
        module_id, title, subtitle, description, instructions,
        exercise_type, order_index,
        config, content,
        difficulty_level, max_points, passing_score,
        estimated_time_minutes, max_attempts,
        xp_reward, ml_coins_reward,
        is_active
    ) VALUES (
        mod3_id,
        'Debate: Ética en la Investigación Científica',
        'Argumenta tu posición',
        'Participa en un debate sobre los dilemas éticos de la investigación de Marie Curie',
        'Elige una postura y construye argumentos sólidos',
        'debate_digital', 2,
        '{"allowCounterarguments": true, "timeLimit": 900}'::jsonb,
        '{
            "topic": "¿Debería Marie Curie haber sido más cautelosa con la radiación sabiendo sus riesgos?",
            "positions": [
                {
                    "id": "pos1",
                    "stance": "A favor - Debió priorizar la seguridad",
                    "arguments": [
                        "La salud es más importante que la ciencia",
                        "Podría haber vivido más tiempo y contribuido más",
                        "Su ejemplo llevó a otros científicos a tomar riesgos innecesarios"
                    ]
                },
                {
                    "id": "pos2",
                    "stance": "En contra - Su sacrificio fue necesario",
                    "arguments": [
                        "En su época no se conocían bien los riesgos",
                        "Sus descubrimientos salvaron millones de vidas",
                        "La ciencia requiere pioneros valientes"
                    ]
                }
            ]
        }'::jsonb,
        'advanced', 100, 70,
        25, 3,
        40, 20,
        true
    );

    RAISE NOTICE '✅ Módulo 3: 2 ejercicios cargados';
END $$;

-- ============================================================================
-- MÓDULO 4: LECTURA DIGITAL
-- ============================================================================

DO $$
DECLARE
    mod4_id UUID;
BEGIN
    SELECT id INTO mod4_id FROM educational_content.modules WHERE order_index = 4 LIMIT 1;

    IF mod4_id IS NULL THEN
        RAISE EXCEPTION 'Módulo 4 no encontrado';
    END IF;

    -- Ejercicio 4.1: Verificador de Noticias Falsas
    INSERT INTO educational_content.exercises (
        module_id, title, subtitle, description, instructions,
        exercise_type, order_index,
        config, content,
        difficulty_level, max_points, passing_score,
        estimated_time_minutes, max_attempts,
        xp_reward, ml_coins_reward,
        is_active
    ) VALUES (
        mod4_id,
        'Verificador de Fake News sobre Científicos',
        'Identifica información falsa',
        'Analiza noticias sobre Marie Curie y determina cuáles son falsas',
        'Lee cada afirmación y marca si es verdadera o falsa',
        'verificador_fake_news', 1,
        '{"showSources": true, "requireJustification": true}'::jsonb,
        '{
            "claims": [
                {
                    "id": "c1",
                    "text": "Marie Curie fue la primera mujer en ganar un Premio Nobel",
                    "isTrue": true,
                    "sources": ["Nobel Prize Foundation"],
                    "explanation": "Ganó el Nobel de Física en 1903"
                },
                {
                    "id": "c2",
                    "text": "Marie Curie robó el trabajo de su esposo Pierre",
                    "isTrue": false,
                    "sources": [],
                    "explanation": "Falso. Trabajaron juntos y Marie continuó investigando después de su muerte"
                },
                {
                    "id": "c3",
                    "text": "Marie Curie ganó dos Premios Nobel en diferentes campos",
                    "isTrue": true,
                    "sources": ["Nobel Prize Foundation"],
                    "explanation": "Física (1903) y Química (1911)"
                }
            ]
        }'::jsonb,
        'intermediate', 100, 70,
        15, 3,
        30, 15,
        true
    );

    -- Ejercicio 4.2: Análisis de Memes Educativos
    INSERT INTO educational_content.exercises (
        module_id, title, subtitle, description, instructions,
        exercise_type, order_index,
        config, content,
        difficulty_level, max_points, passing_score,
        estimated_time_minutes, max_attempts,
        xp_reward, ml_coins_reward,
        is_active
    ) VALUES (
        mod4_id,
        'Decodificando Memes Científicos',
        'Comprende el mensaje',
        'Analiza memes sobre Marie Curie e identifica su mensaje y exactitud',
        'Observa cada meme y responde las preguntas sobre su significado',
        'analisis_memes', 2,
        '{"showContext": true, "allowSharing": false}'::jsonb,
        '{
            "memes": [
                {
                    "id": "meme1",
                    "description": "Meme mostrando a Marie Curie brillando en la oscuridad con texto: Cuando estudiabas tan duro que literalmente brillabas",
                    "question": "¿Qué fenómeno real referencia este meme?",
                    "options": [
                        "Marie estudiaba de noche con velas",
                        "La radiación la hacía brillar literalmente",
                        "Es completamente ficticio",
                        "Usaba ropa reflectante"
                    ],
                    "correctAnswer": 1,
                    "explanation": "La exposición a materiales radiactivos causaba que ella y sus pertenencias brillaran"
                }
            ]
        }'::jsonb,
        'intermediate', 100, 70,
        12, 3,
        30, 15,
        true
    );

    RAISE NOTICE '✅ Módulo 4: 2 ejercicios cargados';
END $$;

COMMIT;

-- Verificar resultado final
SELECT
    m.title as modulo,
    COUNT(e.id) as num_ejercicios,
    STRING_AGG(e.title, ', ' ORDER BY e.order_index) as ejercicios
FROM educational_content.modules m
LEFT JOIN educational_content.exercises e ON m.id = e.module_id
GROUP BY m.id, m.title, m.order_index
ORDER BY m.order_index;
