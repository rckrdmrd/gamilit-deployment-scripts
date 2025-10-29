#!/bin/bash

##############################################################################
# GAMILIT Platform - Full Database Recreation Script (Using DB Owner)
#
# Este script recrea la base de datos usando el usuario dueño (gamilit_user)
# No requiere permisos de superusuario (postgres)
##############################################################################

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================================================
# CONFIGURACIÓN DE PATHS RELATIVOS
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WORKSPACE_ROOT="$(cd "$PROJECT_ROOT/../.." && pwd)"
DOCS_ROOT="$WORKSPACE_ROOT/docs"
DDL_ROOT="$DOCS_ROOT/03-desarrollo/base-de-datos/backup-ddl"
DDL_DIR="$DDL_ROOT/gamilit_platform"
SETUP_DIR="$DDL_ROOT/setup"
SEED_DIR="$DDL_DIR/seed-data"
BACKEND_DIR="$WORKSPACE_ROOT/projects/gamilit-platform-backend"

# ============================================================================
# CONFIGURACIÓN DE BASE DE DATOS
# ============================================================================

if [ -f "$BACKEND_DIR/.env" ]; then
    export $(grep -v '^#' "$BACKEND_DIR/.env" | grep -E '^DB_' | xargs)
fi

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-gamilit_platform}"
DB_USER="${DB_USER:-gamilit_user}"
DB_PASSWORD="${DB_PASSWORD:-mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj}"

# ============================================================================
# FUNCIONES
# ============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_step() {
    echo ""
    echo -e "${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# ============================================================================
# MAIN
# ============================================================================

print_header "GAMILIT - Recreación de Base de Datos (como owner)"

echo -e "${YELLOW}Este script:${NC}"
echo "  1. Eliminará TODOS los datos de: ${RED}$DB_NAME${NC}"
echo "  2. Recreará la estructura completa"
echo "  3. Cargará los datos iniciales (seeds)"
echo ""

read -p "¿Continuar? (escribir 'yes'): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Cancelado"
    exit 0
fi

export PGPASSWORD="$DB_PASSWORD"

# ============================================================================
# PASO 1: LIMPIAR DATOS EXISTENTES
# ============================================================================

print_step "PASO 1/5: Limpiando datos existentes..."

# Truncar tablas principales (en orden de dependencias)
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << 'EOSQL' || true
-- Deshabilitar triggers temporalmente
SET session_replication_role = replica;

-- Limpiar datos de gamificación
TRUNCATE TABLE gamification_system.daily_mission_progress CASCADE;
TRUNCATE TABLE gamification_system.user_achievements CASCADE;
TRUNCATE TABLE gamification_system.user_ranks CASCADE;
TRUNCATE TABLE gamification_system.user_stats CASCADE;

-- Limpiar progreso educativo
TRUNCATE TABLE progress_tracking.exercise_attempts CASCADE;
TRUNCATE TABLE progress_tracking.user_module_progress CASCADE;

-- Limpiar contenido educativo
TRUNCATE TABLE educational_content.exercises CASCADE;
TRUNCATE TABLE educational_content.modules CASCADE;

-- Limpiar usuarios y perfiles
TRUNCATE TABLE auth_management.profiles CASCADE;
TRUNCATE TABLE auth.users CASCADE;

-- Re-habilitar triggers
SET session_replication_role = DEFAULT;

SELECT '✅ Datos limpiados' as status;
EOSQL

print_success "Datos limpiados"

# ============================================================================
# PASO 2: EJECUTAR install-all.sh
# ============================================================================

print_step "PASO 2/5: Verificando estructura de DDL..."

# Crear config para install-all.sh
cat > "$SETUP_DIR/config.md" << EOF
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
EOF

chmod 600 "$SETUP_DIR/config.md"

# El install-all.sh solo crea objetos que no existen, no necesitamos ejecutarlo
# si ya tenemos la estructura creada. Verificar si necesitamos ejecutarlo:

table_count=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -tAc \
    "SELECT COUNT(*) FROM pg_tables WHERE schemaname NOT IN ('pg_catalog', 'information_schema');" 2>/dev/null || echo "0")

if [ "$table_count" -lt 10 ]; then
    print_warning "Estructura incompleta, ejecutando install-all.sh..."
    cd "$SETUP_DIR"
    bash install-all.sh
    cd "$SCRIPT_DIR"
    print_success "Estructura DDL actualizada"
else
    print_success "Estructura DDL ya existe ($table_count tablas)"
fi

# ============================================================================
# PASO 3: CARGAR SEEDS
# ============================================================================

print_step "PASO 3/5: Cargando datos iniciales..."

seed_files=(
    "auth_management/01-seed-test-users.sql"
    "educational_content/01-seed-modules.sql"
    "educational_content/05-seed-module1-complete.sql"
    "educational_content/06-seed-modules-2-3-4.sql"
    "gamification_system/00-seed-achievement_categories.sql"
    "gamification_system/01-seed-achievements.sql"
    "gamification_system/02-seed-leaderboard_metadata.sql"
    "gamification_system/03-seed-maya-ranks.sql"
    "gamification_system/01-initialize-user-gamification.sql"
)

for seed_file in "${seed_files[@]}"; do
    full_path="$SEED_DIR/$seed_file"

    if [ -f "$full_path" ]; then
        echo -n "  Loading: $seed_file ... "
        if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$full_path" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${YELLOW}⚠${NC}"
        fi
    fi
done

print_success "Seeds cargados"

# ============================================================================
# PASO 4: VALIDACIÓN
# ============================================================================

print_step "PASO 4/5: Validando instalación..."

user_count=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -tAc \
    "SELECT COUNT(*) FROM auth.users WHERE deleted_at IS NULL;" 2>/dev/null || echo "0")
echo "  Usuarios: $user_count"

module_count=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -tAc \
    "SELECT COUNT(*) FROM educational_content.modules;" 2>/dev/null || echo "0")
echo "  Módulos: $module_count"

exercise_count=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -tAc \
    "SELECT COUNT(*) FROM educational_content.exercises;" 2>/dev/null || echo "0")
echo "  Ejercicios: $exercise_count"

print_success "Validación completada"

# ============================================================================
# PASO 5: RESUMEN
# ============================================================================

print_step "PASO 5/5: Resumen"

print_header "✅ BASE DE DATOS RECREADA"

echo -e "${CYAN}Conexión:${NC}"
echo "  postgresql://$DB_USER:****@$DB_HOST:$DB_PORT/$DB_NAME"
echo ""

echo -e "${CYAN}Próximos pasos:${NC}"
echo "  1. Iniciar backend: cd $BACKEND_DIR && npm run dev"
echo "  2. Test health: curl http://localhost:3006/api/health"
echo "  3. Login: student@gamilit.com / Test1234"
echo ""

print_success "¡Base de datos lista!"

unset PGPASSWORD
