-- =====================================================
-- Seed Data: gamification_system.achievements
-- Description: Logros predefinidos del sistema GAMILIT
-- Records: 49
-- Created: 2025-10-27
-- =====================================================

SET search_path TO gamification_system, public;

-- Truncate table (cuidado: elimina datos existentes)
TRUNCATE TABLE gamification_system.achievements RESTART IDENTITY CASCADE;

-- =====================================================
-- LOGROS DE PROGRESO (15 registros)
-- Logros relacionados con el avance general del estudiante
-- =====================================================

INSERT INTO gamification_system.achievements (
    id,
    tenant_id,
    name,
    description,
    icon,
    category,
    rarity,
    difficulty_level,
    conditions,
    rewards,
    is_secret,
    is_active,
    is_repeatable,
    order_index,
    points_value,
    unlock_message,
    instructions,
    tips,
    metadata,
    created_by,
    created_at,
    updated_at,
    ml_coins_reward
) VALUES
-- Logros básicos de primeros pasos
('a9672e47-94a4-4164-a06f-9055bade05fb', NULL, 'Primer Paso', 'Complete tu primer ejercicio', '🎯', 'progress', 'common', 'beginner', '{"type": "exercise_completed", "requirements": {"exercises_count": 1}}', '{"xp": 10, "ml_coins": 50}', false, true, false, 1, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('b6f15dd3-76c9-42e3-9ca0-6ace1c269f55', NULL, 'Detective Novato', 'Completa tu primer módulo completo', '🔍', 'progress', 'common', 'beginner', '{"type": "module_completed", "requirements": {"modules_count": 1}}', '{"xp": 50, "ml_coins": 100}', false, true, false, 2, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('8b4d1398-36e4-4248-81d4-42031e289458', NULL, 'Estudiante Dedicado', 'Alcanza 500 XP totales', '⭐', 'progress', 'common', 'beginner', '{"type": "xp_milestone", "requirements": {"total_xp": 500}}', '{"xp": 0, "ml_coins": 100}', false, true, false, 5, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),

-- Serie de ejercicios completados
('45943b3d-d3b9-4cc3-be85-7dca1228cda1', NULL, 'Primer Paso', 'Completa tu primer ejercicio', 'star', 'progress', 'common', 'beginner', '{"type": "exercise_completed", "requirements": {"exercises_count": 1}}', '{"xp": 10, "ml_coins": 50}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),
('edb455ec-67d4-4f0c-80de-42a1d5fdc802', NULL, 'Practicante', 'Completa 10 ejercicios', 'clipboard-check', 'progress', 'common', 'beginner', '{"type": "exercise_completed", "requirements": {"exercises_count": 10}}', '{"xp": 30, "ml_coins": 100}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),
('cb6ee45b-75d8-4b40-af09-9a3e71088d06', NULL, 'Dedicado', 'Completa 50 ejercicios', 'clipboard-check', 'progress', 'rare', 'intermediate', '{"type": "exercise_completed", "requirements": {"exercises_count": 50}}', '{"xp": 100, "ml_coins": 250}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),
('7a85a374-cbf5-4af0-beef-7303899da699', NULL, 'Incansable', 'Completa 100 ejercicios', 'clipboard-check', 'progress', 'epic', 'advanced', '{"type": "exercise_completed", "requirements": {"exercises_count": 100}}', '{"xp": 200, "ml_coins": 500}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),

-- Serie de XP acumulada
('00ed5f05-a77b-4e5d-9c28-d5e5004cd627', NULL, 'Aprendiz', 'Alcanza 100 XP totales', 'trending-up', 'progress', 'common', 'beginner', '{"type": "xp_milestone", "requirements": {"total_xp": 100}}', '{"xp": 20, "ml_coins": 50}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),
('95706ea4-94fc-49f1-8f64-644119d82790', NULL, 'Sabio', 'Alcanza 1000 XP totales', 'trending-up', 'progress', 'rare', 'intermediate', '{"type": "xp_milestone", "requirements": {"total_xp": 1000}}', '{"xp": 100, "ml_coins": 200}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),
('b01d9d33-9542-4f2f-a849-e6914931af3c', NULL, 'Maestro del Conocimiento', 'Alcanza 5000 XP totales', 'award', 'progress', 'epic', 'advanced', '{"type": "xp_milestone", "requirements": {"total_xp": 5000}}', '{"xp": 250, "ml_coins": 500}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),
('d6b3b9b4-322a-42c1-acf3-5feb76bb4a69', NULL, 'Leyenda', 'Alcanza 10000 XP totales', 'crown', 'progress', 'legendary', 'advanced', '{"type": "xp_milestone", "requirements": {"total_xp": 10000}}', '{"xp": 500, "ml_coins": 1000}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),

-- Serie de ML Coins acumulados
('7d42dada-5909-4991-8909-313d9304dc21', NULL, 'Ahorrador', 'Gana 100 ML Coins en total', 'dollar-sign', 'progress', 'common', 'beginner', '{"type": "coins_milestone", "requirements": {"ml_coins": 100}}', '{"xp": 20, "ml_coins": 50}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),
('05a516a6-a549-4b6e-a50d-afcab7e03772', NULL, 'Rico', 'Gana 500 ML Coins en total', 'dollar-sign', 'progress', 'rare', 'intermediate', '{"type": "coins_milestone", "requirements": {"ml_coins": 500}}', '{"xp": 50, "ml_coins": 100}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),
('77c13f9a-dbe1-478f-83c6-91cab668c0a5', NULL, 'Magnate', 'Gana 1000 ML Coins en total', 'dollar-sign', 'progress', 'epic', 'intermediate', '{"type": "coins_milestone", "requirements": {"ml_coins": 1000}}', '{"xp": 100, "ml_coins": 200}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),
('1332811d-db41-46b1-8e3d-f9c9b72bfc52', NULL, 'Completador de Módulos', 'Completa 3 módulos', 'book-open', 'progress', 'rare', 'intermediate', '{"type": "module_completed", "requirements": {"modules_count": 3}}', '{"xp": 150, "ml_coins": 300}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0)

ON CONFLICT (id) DO UPDATE SET
    tenant_id = EXCLUDED.tenant_id,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon = EXCLUDED.icon,
    category = EXCLUDED.category,
    rarity = EXCLUDED.rarity,
    difficulty_level = EXCLUDED.difficulty_level,
    conditions = EXCLUDED.conditions,
    rewards = EXCLUDED.rewards,
    is_secret = EXCLUDED.is_secret,
    is_active = EXCLUDED.is_active,
    is_repeatable = EXCLUDED.is_repeatable,
    order_index = EXCLUDED.order_index,
    points_value = EXCLUDED.points_value,
    unlock_message = EXCLUDED.unlock_message,
    instructions = EXCLUDED.instructions,
    tips = EXCLUDED.tips,
    metadata = EXCLUDED.metadata,
    updated_at = gamilit.now_mexico();

-- =====================================================
-- LOGROS DE RACHA (4 registros)
-- Logros relacionados con días consecutivos de actividad
-- =====================================================

INSERT INTO gamification_system.achievements (
    id,
    tenant_id,
    name,
    description,
    icon,
    category,
    rarity,
    difficulty_level,
    conditions,
    rewards,
    is_secret,
    is_active,
    is_repeatable,
    order_index,
    points_value,
    unlock_message,
    instructions,
    tips,
    metadata,
    created_by,
    created_at,
    updated_at,
    ml_coins_reward
) VALUES
('a7ba1ab7-bf70-4359-ad9d-5ea6e712807b', NULL, 'Lector Persistente', 'Mantén una racha de 7 días consecutivos', '🔥', 'streak', 'rare', 'beginner', '{"type": "streak", "requirements": {"days": 7}}', '{"xp": 75, "ml_coins": 150}', false, true, false, 3, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('e240d39f-cba1-455c-bbc0-211ab80bf38b', NULL, 'Racha Imparable', 'Mantén una racha de 30 días consecutivos', '🔥', 'streak', 'legendary', 'beginner', '{"type": "streak", "requirements": {"days": 30}}', '{"xp": 250, "ml_coins": 500}', false, true, false, 30, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('4ddc767d-8364-4599-b3b3-164e6360adcc', NULL, 'Racha Inicial', 'Mantén una racha de 3 días consecutivos', 'zap', 'streak', 'common', 'beginner', '{"type": "streak", "requirements": {"days": 3}}', '{"xp": 30, "ml_coins": 75}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),
('935602c1-dd19-4161-abc1-fac85658159d', NULL, 'Persistente', 'Mantén una racha de 14 días consecutivos', 'zap', 'streak', 'rare', 'intermediate', '{"type": "streak", "requirements": {"days": 14}}', '{"xp": 100, "ml_coins": 250}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0)

ON CONFLICT (id) DO UPDATE SET
    tenant_id = EXCLUDED.tenant_id,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon = EXCLUDED.icon,
    category = EXCLUDED.category,
    rarity = EXCLUDED.rarity,
    difficulty_level = EXCLUDED.difficulty_level,
    conditions = EXCLUDED.conditions,
    rewards = EXCLUDED.rewards,
    is_secret = EXCLUDED.is_secret,
    is_active = EXCLUDED.is_active,
    is_repeatable = EXCLUDED.is_repeatable,
    order_index = EXCLUDED.order_index,
    points_value = EXCLUDED.points_value,
    unlock_message = EXCLUDED.unlock_message,
    instructions = EXCLUDED.instructions,
    tips = EXCLUDED.tips,
    metadata = EXCLUDED.metadata,
    updated_at = gamilit.now_mexico();

-- =====================================================
-- LOGROS DE COMPLETACIÓN (8 registros)
-- Logros relacionados con finalización de módulos y ejercicios
-- =====================================================

INSERT INTO gamification_system.achievements (
    id,
    tenant_id,
    name,
    description,
    icon,
    category,
    rarity,
    difficulty_level,
    conditions,
    rewards,
    is_secret,
    is_active,
    is_repeatable,
    order_index,
    points_value,
    unlock_message,
    instructions,
    tips,
    metadata,
    created_by,
    created_at,
    updated_at,
    ml_coins_reward
) VALUES
-- Maestría por módulo específico
('4cc02c8e-bdd5-4bc8-aca0-98bf4d0b11d9', NULL, 'Graduado Literal', 'Completa todos los ejercicios del Módulo 1', '📖', 'completion', 'rare', 'beginner', '{"type": "module_mastery", "requirements": {"module_id": 1, "completion": 100}}', '{"xp": 100, "ml_coins": 200}', false, true, false, 6, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('15ab1073-8129-401a-b619-4efb07f047ec', NULL, 'Maestro Inferencial', 'Completa todos los ejercicios del Módulo 2', '🧠', 'completion', 'rare', 'beginner', '{"type": "module_mastery", "requirements": {"module_id": 2, "completion": 100}}', '{"xp": 125, "ml_coins": 250}', false, true, false, 7, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('fcfbb109-49cd-4616-b75b-f400bc81cc7a', NULL, 'Crítico Experto', 'Completa todos los ejercicios del Módulo 3', '🎓', 'completion', 'epic', 'beginner', '{"type": "module_mastery", "requirements": {"module_id": 3, "completion": 100}}', '{"xp": 150, "ml_coins": 300}', false, true, false, 8, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('cf97f026-a827-4f8d-a339-fb15b4c4a939', NULL, 'Lector Digital', 'Completa todos los ejercicios del Módulo 4', '💻', 'completion', 'epic', 'beginner', '{"type": "module_mastery", "requirements": {"module_id": 4, "completion": 100}}', '{"xp": 175, "ml_coins": 350}', false, true, false, 9, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('6c65eb4b-01b4-4f19-b986-f9f6e9186f18', NULL, 'Productor Creativo', 'Completa todos los ejercicios del Módulo 5', '🎨', 'completion', 'epic', 'beginner', '{"type": "module_mastery", "requirements": {"module_id": 5, "completion": 100}}', '{"xp": 200, "ml_coins": 400}', false, true, false, 10, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('89792caf-e702-4090-8023-15b7e7d0f059', NULL, 'Maestría Completa', 'Completa todos los 5 módulos', '👑', 'completion', 'legendary', 'beginner', '{"type": "all_modules", "requirements": {"modules_count": 5}}', '{"xp": 500, "ml_coins": 1000}', false, true, false, 11, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),

-- Perfección en ejercicios
('7aab881a-a50b-474a-8d3b-752e26ceee8d', NULL, 'Perfeccionista Novato', 'Obtén 5 calificaciones perfectas (100%)', 'target', 'completion', 'rare', 'intermediate', '{"type": "perfect_score", "requirements": {"perfect_count": 5}}', '{"xp": 50, "ml_coins": 100}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),
('f9c1a1de-6e60-4253-a436-6e1b7e949495', NULL, 'Excelencia Total', 'Obtén 10 calificaciones perfectas (100%)', 'target', 'completion', 'epic', 'intermediate', '{"type": "perfect_score", "requirements": {"perfect_count": 10}}', '{"xp": 100, "ml_coins": 200}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0)

ON CONFLICT (id) DO UPDATE SET
    tenant_id = EXCLUDED.tenant_id,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon = EXCLUDED.icon,
    category = EXCLUDED.category,
    rarity = EXCLUDED.rarity,
    difficulty_level = EXCLUDED.difficulty_level,
    conditions = EXCLUDED.conditions,
    rewards = EXCLUDED.rewards,
    is_secret = EXCLUDED.is_secret,
    is_active = EXCLUDED.is_active,
    is_repeatable = EXCLUDED.is_repeatable,
    order_index = EXCLUDED.order_index,
    points_value = EXCLUDED.points_value,
    unlock_message = EXCLUDED.unlock_message,
    instructions = EXCLUDED.instructions,
    tips = EXCLUDED.tips,
    metadata = EXCLUDED.metadata,
    updated_at = gamilit.now_mexico();

-- =====================================================
-- LOGROS DE MAESTRÍA (8 registros)
-- Logros relacionados con dominio y habilidades avanzadas
-- =====================================================

INSERT INTO gamification_system.achievements (
    id,
    tenant_id,
    name,
    description,
    icon,
    category,
    rarity,
    difficulty_level,
    conditions,
    rewards,
    is_secret,
    is_active,
    is_repeatable,
    order_index,
    points_value,
    unlock_message,
    instructions,
    tips,
    metadata,
    created_by,
    created_at,
    updated_at,
    ml_coins_reward
) VALUES
-- Rangos Maya
('6b088b5a-6278-41d6-97a3-17fed0949896', NULL, 'Ascenso Maya: BATAB', 'Alcanza el rango BATAB', '🏛️', 'mastery', 'rare', 'beginner', '{"type": "rank_achieved", "requirements": {"rank": "batab"}}', '{"xp": 50, "ml_coins": 100}', false, true, false, 12, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('5259f524-5327-47ad-948c-e037b9e895b2', NULL, 'Líder HOLCATTE', 'Alcanza el rango HOLCATTE', '🛡️', 'mastery', 'epic', 'beginner', '{"type": "rank_achieved", "requirements": {"rank": "holcatte"}}', '{"xp": 100, "ml_coins": 200}', false, true, false, 13, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('2365f7e3-001d-427f-a55a-cc552fdd89bb', NULL, 'Guerrero Maya', 'Alcanza el rango GUERRERO', '⚔️', 'mastery', 'epic', 'beginner', '{"type": "rank_achieved", "requirements": {"rank": "guerrero"}}', '{"xp": 250, "ml_coins": 500}', false, true, false, 14, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('641e9e4f-277f-429f-ad6d-6c851e1f09e2', NULL, 'Mercenario Legendario', 'Alcanza el rango máximo MERCENARIO', '👑', 'mastery', 'legendary', 'beginner', '{"type": "rank_achieved", "requirements": {"rank": "mercenario"}}', '{"xp": 500, "ml_coins": 1000}', false, true, false, 15, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),

-- Logros de habilidad
('60ab998b-befb-401e-91ed-dbae49e5f4bb', NULL, 'Perfeccionista', 'Obtén 10 puntuaciones perfectas (100%)', '💯', 'mastery', 'rare', 'beginner', '{"type": "perfect_scores", "requirements": {"count": 10}}', '{"xp": 100, "ml_coins": 200}', false, true, false, 17, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('6f5228a5-fd27-477a-b8c9-9ea13306cb59', NULL, 'Erudito', 'Completa todos los 27 tipos de ejercicios', '📚', 'mastery', 'legendary', 'beginner', '{"type": "exercise_variety", "requirements": {"unique_types": 27}}', '{"xp": 250, "ml_coins": 500}', false, true, false, 19, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('355d716a-1f08-4f5b-8ef5-ec1b3648875e', NULL, 'Sin Ayuda', 'Completa 20 ejercicios sin usar comodines', '🦾', 'mastery', 'epic', 'beginner', '{"type": "no_powerups", "requirements": {"exercises_count": 20}}', '{"xp": 150, "ml_coins": 300}', false, true, false, 20, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('48d73bc6-d392-4a4f-8cbb-cca626485871', NULL, 'Triple Corona', 'Completa 3 módulos con 100% en todos los ejercicios', '🏆', 'mastery', 'legendary', 'beginner', '{"type": "perfect_modules", "requirements": {"modules_count": 3}}', '{"xp": 375, "ml_coins": 750}', false, true, false, 21, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0)

ON CONFLICT (id) DO UPDATE SET
    tenant_id = EXCLUDED.tenant_id,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon = EXCLUDED.icon,
    category = EXCLUDED.category,
    rarity = EXCLUDED.rarity,
    difficulty_level = EXCLUDED.difficulty_level,
    conditions = EXCLUDED.conditions,
    rewards = EXCLUDED.rewards,
    is_secret = EXCLUDED.is_secret,
    is_active = EXCLUDED.is_active,
    is_repeatable = EXCLUDED.is_repeatable,
    order_index = EXCLUDED.order_index,
    points_value = EXCLUDED.points_value,
    unlock_message = EXCLUDED.unlock_message,
    instructions = EXCLUDED.instructions,
    tips = EXCLUDED.tips,
    metadata = EXCLUDED.metadata,
    updated_at = gamilit.now_mexico();

-- =====================================================
-- LOGROS DE EXPLORACIÓN (1 registro)
-- Logros relacionados con descubrimiento de contenido
-- =====================================================

INSERT INTO gamification_system.achievements (
    id,
    tenant_id,
    name,
    description,
    icon,
    category,
    rarity,
    difficulty_level,
    conditions,
    rewards,
    is_secret,
    is_active,
    is_repeatable,
    order_index,
    points_value,
    unlock_message,
    instructions,
    tips,
    metadata,
    created_by,
    created_at,
    updated_at,
    ml_coins_reward
) VALUES
('af6b9be5-e790-4825-a8db-250b4aa63a41', NULL, 'Explorador Curioso', 'Completa 10 ejercicios diferentes', '🗺️', 'exploration', 'common', 'beginner', '{"type": "exercise_variety", "requirements": {"unique_exercises": 10}}', '{"xp": 30, "ml_coins": 75}', false, true, false, 4, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0)

ON CONFLICT (id) DO UPDATE SET
    tenant_id = EXCLUDED.tenant_id,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon = EXCLUDED.icon,
    category = EXCLUDED.category,
    rarity = EXCLUDED.rarity,
    difficulty_level = EXCLUDED.difficulty_level,
    conditions = EXCLUDED.conditions,
    rewards = EXCLUDED.rewards,
    is_secret = EXCLUDED.is_secret,
    is_active = EXCLUDED.is_active,
    is_repeatable = EXCLUDED.is_repeatable,
    order_index = EXCLUDED.order_index,
    points_value = EXCLUDED.points_value,
    unlock_message = EXCLUDED.unlock_message,
    instructions = EXCLUDED.instructions,
    tips = EXCLUDED.tips,
    metadata = EXCLUDED.metadata,
    updated_at = gamilit.now_mexico();

-- =====================================================
-- LOGROS SOCIALES (3 registros)
-- Logros relacionados con interacción entre estudiantes
-- =====================================================

INSERT INTO gamification_system.achievements (
    id,
    tenant_id,
    name,
    description,
    icon,
    category,
    rarity,
    difficulty_level,
    conditions,
    rewards,
    is_secret,
    is_active,
    is_repeatable,
    order_index,
    points_value,
    unlock_message,
    instructions,
    tips,
    metadata,
    created_by,
    created_at,
    updated_at,
    ml_coins_reward
) VALUES
('3643878a-3c6d-4a29-b442-fa4c479415da', NULL, 'Líder de Equipo', 'Crea un equipo y recluta 5 miembros', '👥', 'social', 'common', 'beginner', '{"type": "team_leader", "requirements": {"team_members": 5}}', '{"xp": 50, "ml_coins": 100}', false, true, false, 22, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('5b412395-f090-4f4d-aa07-1e7a36ad4b66', NULL, 'Competidor', 'Gana tu primera competencia', '🥇', 'social', 'rare', 'beginner', '{"type": "competition_win", "requirements": {"wins": 1}}', '{"xp": 100, "ml_coins": 200}', false, true, false, 23, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('4b7a171d-8c87-4cbf-8852-35aaa3c6675b', NULL, 'Mentor', 'Ayuda a 5 estudiantes diferentes', '🤝', 'social', 'epic', 'beginner', '{"type": "mentor", "requirements": {"students_helped": 5}}', '{"xp": 75, "ml_coins": 150}', false, true, false, 24, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0)

ON CONFLICT (id) DO UPDATE SET
    tenant_id = EXCLUDED.tenant_id,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon = EXCLUDED.icon,
    category = EXCLUDED.category,
    rarity = EXCLUDED.rarity,
    difficulty_level = EXCLUDED.difficulty_level,
    conditions = EXCLUDED.conditions,
    rewards = EXCLUDED.rewards,
    is_secret = EXCLUDED.is_secret,
    is_active = EXCLUDED.is_active,
    is_repeatable = EXCLUDED.is_repeatable,
    order_index = EXCLUDED.order_index,
    points_value = EXCLUDED.points_value,
    unlock_message = EXCLUDED.unlock_message,
    instructions = EXCLUDED.instructions,
    tips = EXCLUDED.tips,
    metadata = EXCLUDED.metadata,
    updated_at = gamilit.now_mexico();

-- =====================================================
-- LOGROS ESPECIALES (10 registros)
-- Logros únicos, eventos especiales y condiciones especiales
-- =====================================================

INSERT INTO gamification_system.achievements (
    id,
    tenant_id,
    name,
    description,
    icon,
    category,
    rarity,
    difficulty_level,
    conditions,
    rewards,
    is_secret,
    is_active,
    is_repeatable,
    order_index,
    points_value,
    unlock_message,
    instructions,
    tips,
    metadata,
    created_by,
    created_at,
    updated_at,
    ml_coins_reward
) VALUES
-- Logros especiales de velocidad y tiempo
('080a514d-654c-458f-8b48-69d01daa9cc2', NULL, 'Ascenso Rápido', 'Alcanza BATAB en menos de 2 semanas', '⚡', 'special', 'rare', 'beginner', '{"type": "quick_rank", "requirements": {"days": 14, "rank": "batab"}}', '{"xp": 75, "ml_coins": 150}', false, true, false, 16, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('48ad7526-f040-491f-bba7-25d0a4c710bd', NULL, 'Velocista', 'Completa un ejercicio en el top 10% de velocidad', '🏃', 'special', 'rare', 'beginner', '{"type": "speed", "requirements": {"percentile": 10}}', '{"xp": 75, "ml_coins": 150}', false, true, false, 18, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('547dcbcd-0219-40a6-9f2d-fe157481f629', NULL, 'Madrugador', 'Completa un ejercicio antes de las 6 AM', '🌅', 'special', 'rare', 'beginner', '{"type": "time_based", "requirements": {"hour_before": 6}}', '{"xp": 50, "ml_coins": 100}', false, true, false, 28, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('514810b4-464a-40b2-8fd4-a1f3a32fd0a8', NULL, 'Noctámbulo', 'Completa un ejercicio después de las 11 PM', '🌙', 'special', 'rare', 'beginner', '{"type": "time_based", "requirements": {"hour_after": 23}}', '{"xp": 50, "ml_coins": 100}', false, true, false, 29, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('141028da-3cfc-4fb3-be9a-e6c064ec198c', NULL, 'Madrugador', 'Completa un ejercicio antes de las 6 AM', 'sunrise', 'special', 'rare', 'beginner', '{"type": "time_based", "requirements": {"hour_before": 6}}', '{"xp": 50, "ml_coins": 100}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),
('6ee12b8f-6cda-4614-8e2e-94c4f71358f3', NULL, 'Noctámbulo', 'Completa un ejercicio después de las 11 PM', 'moon', 'special', 'rare', 'beginner', '{"type": "time_based", "requirements": {"hour_after": 23}}', '{"xp": 50, "ml_coins": 100}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0),

-- Logros de colección y contenido especial
('b5717244-5248-4e2a-9a59-05435c287227', NULL, 'Científico Curie', 'Explora todo el contenido sobre Marie Curie', '🧪', 'special', 'epic', 'beginner', '{"type": "content_exploration", "requirements": {"topic": "marie_curie", "completion": 100}}', '{"xp": 150, "ml_coins": 300}', false, true, false, 25, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('a7a3441f-e4ab-4b15-a84b-bb0a9b7f93a9', NULL, 'Coleccionista', 'Desbloquea 10 logros diferentes', '🎖️', 'special', 'rare', 'beginner', '{"type": "achievement_count", "requirements": {"achievements": 10}}', '{"xp": 125, "ml_coins": 250}', false, true, false, 26, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('d4f56804-9e8c-407b-8557-4eb9b3875401', NULL, 'Millonario ML', 'Acumula 10,000 ML Coins totales ganados', '💰', 'special', 'legendary', 'beginner', '{"type": "coins_milestone", "requirements": {"total_earned": 10000}}', '{"xp": 500, "ml_coins": 1000}', false, true, false, 27, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-16 02:30:15.665915-06', '2025-10-16 02:30:15.665915-06', 0),
('db496177-f0b8-4ed2-8136-6013fc6527a6', NULL, 'Coleccionista Inicial', 'Desbloquea 5 logros diferentes', 'gift', 'special', 'rare', 'beginner', '{"type": "achievement_count", "requirements": {"achievements": 5}}', '{"xp": 75, "ml_coins": 150}', false, true, false, 0, 0, NULL, NULL, NULL, '{}', NULL, '2025-10-20 22:03:21.582332-06', '2025-10-20 22:03:21.582332-06', 0)

ON CONFLICT (id) DO UPDATE SET
    tenant_id = EXCLUDED.tenant_id,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon = EXCLUDED.icon,
    category = EXCLUDED.category,
    rarity = EXCLUDED.rarity,
    difficulty_level = EXCLUDED.difficulty_level,
    conditions = EXCLUDED.conditions,
    rewards = EXCLUDED.rewards,
    is_secret = EXCLUDED.is_secret,
    is_active = EXCLUDED.is_active,
    is_repeatable = EXCLUDED.is_repeatable,
    order_index = EXCLUDED.order_index,
    points_value = EXCLUDED.points_value,
    unlock_message = EXCLUDED.unlock_message,
    instructions = EXCLUDED.instructions,
    tips = EXCLUDED.tips,
    metadata = EXCLUDED.metadata,
    updated_at = gamilit.now_mexico();

-- =====================================================
-- Seed data para achievements completado
-- Total: 49 registros insertados/actualizados
-- =====================================================
