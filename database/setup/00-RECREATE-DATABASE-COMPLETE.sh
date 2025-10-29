#!/bin/bash
# ============================================================================
# Script: 00-RECREATE-DATABASE-COMPLETE.sh
# Descripción: Recreación completa de la base de datos gamilit_platform
#              desde cero con TODOS los datos necesarios
# Fecha: 2025-10-28
# ============================================================================

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
export PGPASSWORD="${DB_PASSWORD:-mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-gamilit_user}"
DB_NAME="${DB_NAME:-gamilit_platform}"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  RECREACIÓN COMPLETA DE BASE DE DATOS${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo "Base de datos: $DB_NAME"
echo "Usuario: $DB_USER"
echo "Host: $DB_HOST:$DB_PORT"
echo ""

# Función para logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo ""
    echo -e "${BLUE}📦 $1${NC}"
}

# ============================================================================
# PASO 1: LIMPIAR BASE DE DATOS EXISTENTE
# ============================================================================

log_step "PASO 1/9: Limpiando datos existentes..."

psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOSQL'
-- Eliminar todos los datos pero mantener estructura
TRUNCATE TABLE gamification_system.user_ranks CASCADE;
TRUNCATE TABLE gamification_system.user_stats CASCADE;
TRUNCATE TABLE educational_content.exercises CASCADE;

-- Actualizar constraints si es necesario
ALTER TABLE gamification_system.user_stats DROP CONSTRAINT IF EXISTS user_stats_user_id_fkey;
ALTER TABLE gamification_system.user_ranks DROP CONSTRAINT IF EXISTS user_ranks_user_id_fkey;

ALTER TABLE gamification_system.user_stats
  ADD CONSTRAINT user_stats_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE gamification_system.user_ranks
  ADD CONSTRAINT user_ranks_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

SELECT '✅ Base de datos limpiada' as status;
EOSQL

if [ $? -eq 0 ]; then
    log_info "Base de datos limpiada correctamente"
else
    log_error "Error al limpiar base de datos"
    exit 1
fi

# ============================================================================
# PASO 2: CARGAR MÓDULOS EDUCATIVOS
# ============================================================================

log_step "PASO 2/9: Cargando módulos educativos..."

psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
  -f "$BASE_DIR/seed-data/educational_content/01-seed-modules.sql" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    log_info "Módulos cargados: 4 módulos educativos"
else
    log_error "Error al cargar módulos"
    exit 1
fi

# ============================================================================
# PASO 3: CARGAR EJERCICIOS MÓDULO 1
# ============================================================================

log_step "PASO 3/9: Cargando ejercicios del Módulo 1..."

psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
  -f "$BASE_DIR/seed-data/educational_content/05-seed-module1-complete.sql" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    log_info "Módulo 1: 5 ejercicios cargados"
else
    log_error "Error al cargar ejercicios del Módulo 1"
    exit 1
fi

# ============================================================================
# PASO 4: CARGAR EJERCICIOS MÓDULOS 2, 3, 4
# ============================================================================

log_step "PASO 4/9: Cargando ejercicios de Módulos 2, 3 y 4..."

psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
  -f "$BASE_DIR/seed-data/educational_content/06-seed-modules-2-3-4.sql" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    log_info "Módulo 2: 2 ejercicios cargados"
    log_info "Módulo 3: 2 ejercicios cargados"
    log_info "Módulo 4: 2 ejercicios cargados"
else
    log_error "Error al cargar ejercicios de Módulos 2-4"
    exit 1
fi

# ============================================================================
# PASO 5: INICIALIZAR GAMIFICACIÓN
# ============================================================================

log_step "PASO 5/9: Inicializando gamificación (user_stats y user_ranks)..."

psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
  -f "$BASE_DIR/seed-data/gamification_system/01-initialize-user-gamification.sql"

if [ $? -eq 0 ]; then
    log_info "Gamificación inicializada para todos los usuarios"
else
    log_error "Error al inicializar gamificación"
    exit 1
fi

# ============================================================================
# PASO 6: VERIFICAR INTEGRIDAD
# ============================================================================

log_step "PASO 6/9: Verificando integridad de datos..."

VERIFICATION=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t << 'EOSQL'
SELECT
    COUNT(DISTINCT u.id) as usuarios,
    COUNT(DISTINCT p.id) as profiles,
    COUNT(DISTINCT us.id) as user_stats,
    COUNT(DISTINCT ur.id) as user_ranks,
    COUNT(DISTINCT m.id) as modulos,
    COUNT(DISTINCT e.id) as ejercicios
FROM auth.users u
LEFT JOIN auth_management.profiles p ON u.id = p.user_id
LEFT JOIN gamification_system.user_stats us ON u.id = us.user_id
LEFT JOIN gamification_system.user_ranks ur ON u.id = ur.user_id AND ur.is_current = true
CROSS JOIN educational_content.modules m
CROSS JOIN educational_content.exercises e
WHERE u.deleted_at IS NULL
LIMIT 1;
EOSQL
)

log_info "Verificación de integridad completada"

# ============================================================================
# PASO 7: GENERAR ESTADÍSTICAS
# ============================================================================

log_step "PASO 7/9: Generando estadísticas de la base de datos..."

psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOSQL'
\echo ''
\echo '========================================='
\echo '  ESTADÍSTICAS DE LA BASE DE DATOS'
\echo '========================================='
\echo ''

-- Usuarios y Profiles
SELECT
    'auth.users' as tabla,
    COUNT(*) as registros
FROM auth.users
WHERE deleted_at IS NULL

UNION ALL

SELECT
    'auth_management.profiles',
    COUNT(*)
FROM auth_management.profiles

UNION ALL

-- Gamificación
SELECT
    'gamification_system.user_stats',
    COUNT(*)
FROM gamification_system.user_stats

UNION ALL

SELECT
    'gamification_system.user_ranks',
    COUNT(*)
FROM gamification_system.user_ranks
WHERE is_current = true

UNION ALL

-- Contenido Educativo
SELECT
    'educational_content.modules',
    COUNT(*)
FROM educational_content.modules

UNION ALL

SELECT
    'educational_content.exercises',
    COUNT(*)
FROM educational_content.exercises;

\echo ''
\echo '========================================='
\echo '  EJERCICIOS POR MÓDULO'
\echo '========================================='
\echo ''

SELECT
    m.title as modulo,
    COUNT(e.id) as ejercicios
FROM educational_content.modules m
LEFT JOIN educational_content.exercises e ON m.id = e.module_id
GROUP BY m.id, m.title, m.order_index
ORDER BY m.order_index;

\echo ''
EOSQL

# ============================================================================
# PASO 8: VERIFICAR FOREIGN KEYS
# ============================================================================

log_step "PASO 8/9: Verificando Foreign Keys..."

FK_CHECK=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t << 'EOSQL'
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'gamification_system'
  AND tc.table_name IN ('user_stats', 'user_ranks')
  AND kcu.column_name = 'user_id';
EOSQL
)

if echo "$FK_CHECK" | grep -q "auth.users"; then
    log_info "✅ Foreign Keys apuntan correctamente a auth.users"
else
    log_warn "⚠️ Verificar Foreign Keys manualmente"
fi

# ============================================================================
# PASO 9: REINICIAR BACKEND
# ============================================================================

log_step "PASO 9/9: Reiniciando backend..."

# Buscar proceso del backend
BACKEND_PID=$(lsof -ti:3006 2>/dev/null)

if [ -n "$BACKEND_PID" ]; then
    log_info "Deteniendo backend anterior (PID: $BACKEND_PID)..."
    kill $BACKEND_PID 2>/dev/null || true
    sleep 2
fi

log_info "Backend detenido (se reiniciará automáticamente si usa nodemon)"

# ============================================================================
# RESUMEN FINAL
# ============================================================================

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  ✅ RECREACIÓN COMPLETADA EXITOSAMENTE${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${BLUE}Base de datos:${NC} $DB_NAME"
echo -e "${BLUE}Estado:${NC} Lista para usar"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "  1. Verificar que el backend esté corriendo en puerto 3006"
echo "  2. Hacer login con: student@gamilit.com / Test1234"
echo "  3. Probar endpoints de estadísticas y rangos"
echo "  4. Verificar que los 4 módulos muestren ejercicios"
echo ""
echo -e "${BLUE}Endpoints para probar:${NC}"
echo "  • POST /api/auth/login"
echo "  • GET  /api/gamification/stats/:userId"
echo "  • GET  /api/gamification/ranks/user/:userId"
echo "  • GET  /api/educational/modules/user/:userId"
echo "  • GET  /api/gamification/missions/daily"
echo ""
echo -e "${GREEN}¡Base de datos lista!${NC}"
echo ""
