-- =====================================================
-- Enable RLS for gamification_system tables
-- Created: 2025-10-27
-- Updated: 2025-10-28 (Agent 3 - Comprehensive RLS Integration)
-- Description: Habilita Row Level Security en todas las tablas
--              del sistema de gamificación
-- =====================================================

-- Enable Row Level Security on all gamification_system tables
-- Schema: gamification_system
-- Tables: 9 tables with RLS protection

ALTER TABLE gamification_system.ml_coins_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE gamification_system.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE gamification_system.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE gamification_system.comodines_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE gamification_system.user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE gamification_system.user_ranks ENABLE ROW LEVEL SECURITY;
ALTER TABLE gamification_system.missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE gamification_system.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE gamification_system.leaderboard_metadata ENABLE ROW LEVEL SECURITY;

-- Comentarios
COMMENT ON TABLE gamification_system.ml_coins_transactions IS 'RLS enabled: Transacciones de ML coins - lectura propia + teacher + admin';
COMMENT ON TABLE gamification_system.achievements IS 'RLS enabled: Logros del sistema - lectura pública de activos';
COMMENT ON TABLE gamification_system.user_achievements IS 'RLS enabled: Logros de usuarios - lectura propia + amigos + teacher';
COMMENT ON TABLE gamification_system.comodines_inventory IS 'RLS enabled: Inventario de comodines - gestión propia';
COMMENT ON TABLE gamification_system.user_stats IS 'RLS enabled: Estadísticas de usuario - lectura propia + amigos + teacher';
COMMENT ON TABLE gamification_system.user_ranks IS 'RLS enabled: Rankings de usuarios - lectura pública';
COMMENT ON TABLE gamification_system.missions IS 'RLS enabled: Misiones activas - lectura propia + admin';
COMMENT ON TABLE gamification_system.notifications IS 'RLS enabled: Notificaciones - gestión propia';
COMMENT ON TABLE gamification_system.leaderboard_metadata IS 'RLS enabled: Metadata de leaderboards - lectura pública';
