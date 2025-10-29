#!/bin/bash

##############################################################################
# GAMILIT Platform - Load Seed Data to Production
##############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SEED_DIR="$PROJECT_ROOT/database/gamilit_platform/seed-data"

# Load database configuration from config.md
CONFIG_FILE="$PROJECT_ROOT/database/setup/config.md"
if [ -f "$CONFIG_FILE" ]; then
    DB_HOST=$(grep "^DB_HOST=" "$CONFIG_FILE" | head -1 | cut -d'=' -f2)
    DB_PORT=$(grep "^DB_PORT=" "$CONFIG_FILE" | head -1 | cut -d'=' -f2)
    DB_NAME=$(grep "^DB_NAME=" "$CONFIG_FILE" | head -1 | cut -d'=' -f2)
    DB_USER=$(grep "^DB_USER=" "$CONFIG_FILE" | head -1 | cut -d'=' -f2)
    DB_PASSWORD=$(grep "^DB_PASSWORD=" "$CONFIG_FILE" | head -1 | cut -d'=' -f2)
    export PGPASSWORD="$DB_PASSWORD"
else
    echo "Error: config.md no encontrado en $CONFIG_FILE"
    exit 1
fi

print_step() {
    echo -e "${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

execute_sql() {
    local file=$1
    local description=$2

    print_step "$description"
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$file" > /tmp/seed_output.log 2>&1; then
        print_success "Completado"
    else
        print_error "Error al cargar: $file"
        cat /tmp/seed_output.log
        exit 1
    fi
}

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}  CARGANDO SEED DATA - PRODUCCIÓN${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

# 1. System Configuration
print_step "1/8: Cargando configuración del sistema..."
execute_sql "$SEED_DIR/system_configuration/01-seed-system_settings.sql" "  → System settings"
execute_sql "$SEED_DIR/system_configuration/02-seed-feature_flags.sql" "  → Feature flags"

# 2. Auth Management
print_step "2/8: Cargando usuarios de prueba..."
execute_sql "$SEED_DIR/auth_management/01-seed-test-users.sql" "  → Test users"

# 3. Educational Content - Modules
print_step "3/8: Cargando módulos educativos..."
execute_sql "$SEED_DIR/educational_content/01-seed-modules.sql" "  → Modules base"

# 4. Educational Content - Exercises
print_step "4/8: Cargando ejercicios..."
execute_sql "$SEED_DIR/educational_content/05-seed-module1-complete.sql" "  → Module 1 complete"
execute_sql "$SEED_DIR/educational_content/06-seed-modules-2-3-4.sql" "  → Modules 2-3-4"

# 5. Assessment Rubrics
print_step "5/8: Cargando rúbricas de evaluación..."
execute_sql "$SEED_DIR/educational_content/02-seed-assessment_rubrics.sql" "  → Assessment rubrics"

# 6. Gamification - Categories and Achievements
print_step "6/8: Cargando sistema de gamificación..."
execute_sql "$SEED_DIR/gamification_system/00-seed-achievement_categories.sql" "  → Achievement categories"
execute_sql "$SEED_DIR/gamification_system/01-seed-achievements.sql" "  → Achievements"
execute_sql "$SEED_DIR/gamification_system/03-seed-maya-ranks.sql" "  → Maya ranks"
execute_sql "$SEED_DIR/gamification_system/02-seed-leaderboard_metadata.sql" "  → Leaderboard metadata"

# 7. Initialize User Gamification
print_step "7/8: Inicializando gamificación de usuarios..."
execute_sql "$SEED_DIR/gamification_system/01-initialize-user-gamification.sql" "  → User gamification"

# 8. Content Management
print_step "8/8: Cargando contenido de Marie Curie..."
execute_sql "$SEED_DIR/content_management/01-seed-marie_curie_content.sql" "  → Marie Curie content"

echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  ✓ SEED DATA CARGADO EXITOSAMENTE${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""

# Verificar datos cargados
print_step "Verificando datos cargados..."

echo -e "${CYAN}Usuarios:${NC}"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT email, role FROM auth_management.users ORDER BY created_at;" -t

echo -e "${CYAN}Módulos educativos:${NC}"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) as total_modules FROM educational_content.modules;" -t

echo -e "${CYAN}Ejercicios:${NC}"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) as total_exercises FROM educational_content.exercises;" -t

echo -e "${CYAN}Achievements:${NC}"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) as total_achievements FROM gamification_system.achievements;" -t

echo -e "${CYAN}Ranks:${NC}"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) as total_ranks FROM gamification_system.ranks;" -t

echo ""
print_success "Base de datos lista para usar"
echo ""
