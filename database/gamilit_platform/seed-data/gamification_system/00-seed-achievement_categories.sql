-- =====================================================
-- Seed Data: Achievement Categories
-- =====================================================
-- Description: Categorías de logros del sistema Maya
-- Date: 2025-10-28
-- =====================================================

-- Insertar categorías de logros
INSERT INTO gamification_system.achievement_categories (id, name, description, icon, sort_order) VALUES
    ('cat_explorador', 'Explorador', 'Logros relacionados con la exploración del conocimiento', '🔍', 1),
    ('cat_guerrero', 'Guerrero', 'Logros de combate y superación de desafíos', '⚔️', 2),
    ('cat_sabio', 'Sabio', 'Logros de conocimiento y sabiduría', '📚', 3),
    ('cat_constructor', 'Constructor', 'Logros de construcción y persistencia', '🏗️', 4),
    ('cat_social', 'Social', 'Logros de colaboración e interacción', '👥', 5)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon = EXCLUDED.icon,
    sort_order = EXCLUDED.sort_order;

-- Verificar inserción
SELECT 
    'Achievement Categories' AS table_name,
    COUNT(*) AS inserted_count
FROM gamification_system.achievement_categories;

\echo 'Achievement categories seeded successfully!';
