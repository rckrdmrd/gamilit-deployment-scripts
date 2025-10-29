-- =====================================================
-- Seed Data: Maya Ranks
-- =====================================================
-- Description: Rangos de la civilización Maya
-- Date: 2025-10-28
-- =====================================================

-- Insertar rangos Maya en user_ranks
INSERT INTO gamification_system.user_ranks (id, rank_name, min_level, max_level, badge_url, description) VALUES
    ('rank_ajaw', 'Ajaw', 1, 10, '/badges/ranks/ajaw.svg', 'Gobernante aprendiz - Iniciando tu camino en el conocimiento Maya'),
    ('rank_nacom', 'Nacom', 11, 25, '/badges/ranks/nacom.svg', 'Guerrero del conocimiento - Dominas las bases del aprendizaje'),
    ('rank_ah_kin', 'Ah K''in', 26, 50, '/badges/ranks/ah_kin.svg', 'Sacerdote del saber - Profundizas en los misterios del conocimiento'),
    ('rank_halach_uinic', 'Halach Uinic', 51, 75, '/badges/ranks/halach_uinic.svg', 'Líder sabio - Guías a otros en su aprendizaje'),
    ('rank_kukulkan', 'K''uk''ulkan', 76, 100, '/badges/ranks/kukulkan.svg', 'Serpiente emplumada - Maestro supremo del conocimiento')
ON CONFLICT (id) DO UPDATE SET
    rank_name = EXCLUDED.rank_name,
    min_level = EXCLUDED.min_level,
    max_level = EXCLUDED.max_level,
    badge_url = EXCLUDED.badge_url,
    description = EXCLUDED.description;

-- Verificar inserción
SELECT 
    'Maya Ranks' AS table_name,
    COUNT(*) AS inserted_count
FROM gamification_system.user_ranks;

-- Mostrar rangos creados
SELECT 
    rank_name,
    min_level,
    max_level,
    description
FROM gamification_system.user_ranks
ORDER BY min_level;

\echo 'Maya ranks seeded successfully!';
