-- =====================================================
-- ENUMs and Custom Types for gamilit_platform
-- Description: Definición de todos los tipos enumerados
-- Created: 2025-10-27
-- =====================================================

-- Drop existing ENUMs if they exist (in reverse dependency order)
DROP TYPE IF EXISTS achievement_category CASCADE;
DROP TYPE IF EXISTS achievement_type CASCADE;
DROP TYPE IF EXISTS aggregation_period CASCADE;
DROP TYPE IF EXISTS alert_severity CASCADE;
DROP TYPE IF EXISTS attempt_result CASCADE;
DROP TYPE IF EXISTS classroom_role CASCADE;
DROP TYPE IF EXISTS comodin_type CASCADE;
DROP TYPE IF EXISTS content_status CASCADE;
DROP TYPE IF EXISTS content_type CASCADE;
DROP TYPE IF EXISTS difficulty_level CASCADE;
DROP TYPE IF EXISTS exercise_type CASCADE;
DROP TYPE IF EXISTS gamilit_role CASCADE;
DROP TYPE IF EXISTS maya_rank CASCADE;
DROP TYPE IF EXISTS media_type CASCADE;
DROP TYPE IF EXISTS metric_type CASCADE;
DROP TYPE IF EXISTS module_status CASCADE;
DROP TYPE IF EXISTS notification_channel CASCADE;
DROP TYPE IF EXISTS notification_type CASCADE;
DROP TYPE IF EXISTS processing_status CASCADE;
DROP TYPE IF EXISTS progress_status CASCADE;
DROP TYPE IF EXISTS rango_maya CASCADE;
DROP TYPE IF EXISTS social_event_type CASCADE;
DROP TYPE IF EXISTS transaction_type CASCADE;
DROP TYPE IF EXISTS user_status CASCADE;

-- =====================================================
-- ENUM: achievement_category
-- Description: Categorías de logros en el sistema de gamificación
-- =====================================================
CREATE TYPE achievement_category AS ENUM (
    'progress',
    'streak',
    'completion',
    'social',
    'special',
    'mastery',
    'exploration'
);

COMMENT ON TYPE achievement_category IS 'Categorías de logros: progreso, rachas, completitud, social, especial, maestría y exploración';

-- =====================================================
-- ENUM: achievement_type
-- Description: Tipos de logros que pueden obtenerse
-- =====================================================
CREATE TYPE achievement_type AS ENUM (
    'badge',
    'milestone',
    'special',
    'rank_promotion'
);

COMMENT ON TYPE achievement_type IS 'Tipos de logros: insignias, hitos, especiales y promociones de rango';

-- =====================================================
-- ENUM: aggregation_period
-- Description: Períodos de agregación para métricas y estadísticas
-- =====================================================
CREATE TYPE aggregation_period AS ENUM (
    'daily',
    'weekly',
    'monthly',
    'quarterly',
    'yearly'
);

COMMENT ON TYPE aggregation_period IS 'Períodos de agregación temporal para análisis de datos';

-- =====================================================
-- ENUM: alert_severity
-- Description: Niveles de severidad para alertas del sistema
-- =====================================================
CREATE TYPE alert_severity AS ENUM (
    'info',
    'warning',
    'error',
    'critical'
);

COMMENT ON TYPE alert_severity IS 'Niveles de severidad de alertas: información, advertencia, error y crítico';

-- =====================================================
-- ENUM: attempt_result
-- Description: Resultados posibles de un intento de ejercicio
-- =====================================================
CREATE TYPE attempt_result AS ENUM (
    'correct',
    'incorrect',
    'partial',
    'skipped'
);

COMMENT ON TYPE attempt_result IS 'Resultados de intentos: correcto, incorrecto, parcial y omitido';

-- =====================================================
-- ENUM: classroom_role
-- Description: Roles dentro de un aula virtual
-- =====================================================
CREATE TYPE classroom_role AS ENUM (
    'teacher',
    'student',
    'assistant'
);

COMMENT ON TYPE classroom_role IS 'Roles en aulas: profesor, estudiante y asistente';

-- =====================================================
-- ENUM: comodin_type
-- Description: Tipos de comodines disponibles en ejercicios
-- =====================================================
CREATE TYPE comodin_type AS ENUM (
    'pistas',
    'vision_lectora',
    'segunda_oportunidad'
);

COMMENT ON TYPE comodin_type IS 'Tipos de comodines: pistas, visión lectora y segunda oportunidad';

-- =====================================================
-- ENUM: content_status
-- Description: Estados del ciclo de vida del contenido
-- =====================================================
CREATE TYPE content_status AS ENUM (
    'draft',
    'published',
    'archived',
    'reviewing'
);

COMMENT ON TYPE content_status IS 'Estados de contenido: borrador, publicado, archivado y en revisión';

-- =====================================================
-- ENUM: content_type
-- Description: Tipos de contenido multimedia y educativo
-- =====================================================
CREATE TYPE content_type AS ENUM (
    'video',
    'text',
    'interactive',
    'quiz',
    'game',
    'simulation'
);

COMMENT ON TYPE content_type IS 'Tipos de contenido educativo disponibles en la plataforma';

-- =====================================================
-- ENUM: difficulty_level
-- Description: Niveles de dificultad para ejercicios y contenidos
-- =====================================================
CREATE TYPE difficulty_level AS ENUM (
    'beginner',
    'intermediate',
    'advanced',
    'very_easy',
    'easy',
    'medium',
    'hard',
    'very_hard'
);

COMMENT ON TYPE difficulty_level IS 'Niveles de dificultad: desde principiante hasta muy difícil';

-- =====================================================
-- ENUM: exercise_type
-- Description: Tipos de ejercicios disponibles en la plataforma
-- =====================================================
CREATE TYPE exercise_type AS ENUM (
    'crucigrama',
    'linea_tiempo',
    'mapa_conceptual',
    'emparejamiento',
    'sopa_letras',
    'detective_textual',
    'construccion_hipotesis',
    'prediccion_narrativa',
    'puzzle_contexto',
    'rueda_inferencias',
    'tribunal_opiniones',
    'debate_digital',
    'analisis_fuentes',
    'podcast_argumentativo',
    'matriz_perspectivas',
    'verificador_fake_news',
    'infografia_interactiva',
    'quiz_tiktok',
    'navegacion_hipertextual',
    'analisis_memes',
    'diario_interactivo',
    'resumen_visual',
    'capsula_tiempo',
    'comprension_auditiva',
    'collage_digital',
    'texto_movimiento',
    'call_to_action',
    'verdadero_falso',
    'completar_espacios'
);

COMMENT ON TYPE exercise_type IS 'Catálogo completo de tipos de ejercicios interactivos y pedagógicos';

-- =====================================================
-- ENUM: gamilit_role
-- Description: Roles principales del sistema Gamilit
-- =====================================================
CREATE TYPE gamilit_role AS ENUM (
    'student',
    'admin_teacher',
    'super_admin'
);

COMMENT ON TYPE gamilit_role IS 'Roles del sistema: estudiante, profesor administrador y super administrador';

-- =====================================================
-- ENUM: maya_rank
-- Description: Rangos de la jerarquía maya (en mayúsculas)
-- =====================================================
CREATE TYPE maya_rank AS ENUM (
    'NACOM',
    'BATAB',
    'HOLCATTE',
    'GUERRERO',
    'MERCENARIO'
);

COMMENT ON TYPE maya_rank IS 'Rangos jerárquicos mayas: NACOM (máximo), BATAB, HOLCATTE, GUERRERO, MERCENARIO (inicial)';

-- =====================================================
-- ENUM: media_type
-- Description: Tipos de archivos multimedia
-- =====================================================
CREATE TYPE media_type AS ENUM (
    'image',
    'video',
    'audio',
    'document',
    'interactive',
    'animation'
);

COMMENT ON TYPE media_type IS 'Tipos de archivos multimedia soportados';

-- =====================================================
-- ENUM: metric_type
-- Description: Tipos de métricas para análisis
-- =====================================================
CREATE TYPE metric_type AS ENUM (
    'engagement',
    'performance',
    'completion',
    'time_spent',
    'accuracy',
    'streak',
    'social_interaction'
);

COMMENT ON TYPE metric_type IS 'Tipos de métricas para análisis de aprendizaje y comportamiento';

-- =====================================================
-- ENUM: module_status
-- Description: Estados del ciclo de vida de módulos
-- =====================================================
CREATE TYPE module_status AS ENUM (
    'draft',
    'published',
    'archived',
    'under_review'
);

COMMENT ON TYPE module_status IS 'Estados de módulos educativos';

-- =====================================================
-- ENUM: notification_channel
-- Description: Canales de entrega de notificaciones
-- =====================================================
CREATE TYPE notification_channel AS ENUM (
    'in_app',
    'email',
    'push',
    'sms'
);

COMMENT ON TYPE notification_channel IS 'Canales de comunicación: aplicación, email, push y SMS';

-- =====================================================
-- ENUM: notification_type
-- Description: Tipos de notificaciones del sistema
-- =====================================================
CREATE TYPE notification_type AS ENUM (
    'info',
    'success',
    'warning',
    'error',
    'achievement',
    'progress',
    'social',
    'reminder'
);

COMMENT ON TYPE notification_type IS 'Tipos de notificaciones según su propósito y naturaleza';

-- =====================================================
-- ENUM: processing_status
-- Description: Estados de procesamiento de archivos multimedia
-- =====================================================
CREATE TYPE processing_status AS ENUM (
    'uploading',
    'processing',
    'ready',
    'error',
    'optimizing'
);

COMMENT ON TYPE processing_status IS 'Estados de procesamiento de archivos: carga, procesamiento, listo, error y optimización';

-- =====================================================
-- ENUM: progress_status
-- Description: Estados de progreso de aprendizaje
-- =====================================================
CREATE TYPE progress_status AS ENUM (
    'not_started',
    'in_progress',
    'completed',
    'reviewed',
    'mastered'
);

COMMENT ON TYPE progress_status IS 'Estados de progreso: no iniciado, en progreso, completado, revisado y dominado';

-- =====================================================
-- ENUM: rango_maya
-- Description: Rangos de la jerarquía maya (en minúsculas)
-- =====================================================
CREATE TYPE rango_maya AS ENUM (
    'nacom',
    'batab',
    'holcatte',
    'guerrero',
    'mercenario'
);

COMMENT ON TYPE rango_maya IS 'Rangos jerárquicos mayas en minúsculas: nacom (máximo), batab, holcatte, guerrero, mercenario (inicial)';

-- =====================================================
-- ENUM: social_event_type
-- Description: Tipos de eventos sociales en la plataforma
-- =====================================================
CREATE TYPE social_event_type AS ENUM (
    'competition',
    'collaboration',
    'challenge',
    'tournament',
    'workshop'
);

COMMENT ON TYPE social_event_type IS 'Tipos de eventos sociales: competencias, colaboraciones, desafíos, torneos y talleres';

-- =====================================================
-- ENUM: transaction_type
-- Description: Tipos de transacciones en el sistema de economía virtual
-- =====================================================
CREATE TYPE transaction_type AS ENUM (
    'earned_exercise',
    'earned_achievement',
    'earned_daily_bonus',
    'earned_rank_promotion',
    'spent_hint',
    'spent_unlock_content',
    'spent_customization',
    'refund',
    'admin_adjustment',
    'gift'
);

COMMENT ON TYPE transaction_type IS 'Tipos de transacciones de monedas virtuales: ganancias por ejercicios, logros, bonos, gastos y ajustes';

-- =====================================================
-- ENUM: user_status
-- Description: Estados de cuentas de usuario
-- =====================================================
CREATE TYPE user_status AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending'
);

COMMENT ON TYPE user_status IS 'Estados de usuario: activo, inactivo, suspendido y pendiente';

-- =====================================================
-- End of ENUMs definition
-- Total: 24 ENUMs created
-- =====================================================
