#!/bin/bash

##############################################################################
# GAMILIT Platform - Verificación de Setup (Sin Ejecutar)
#
# Este script verifica que todos los archivos y rutas estén correctos
# SIN ejecutar la creación de la base de datos
##############################################################################

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DATABASE_DIR="$PROJECT_ROOT/database"
DDL_DIR="$DATABASE_DIR/gamilit_platform"
SETUP_DIR="$DATABASE_DIR/setup"
SEED_DIR="$DDL_DIR/seed-data"
BACKEND_DIR="$PROJECT_ROOT/../gamilit-platform-backend"

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "  ${CYAN}$1${NC}"
}

print_header "🔍 VERIFICACIÓN DE SETUP GAMILIT"

echo -e "${CYAN}Rutas Calculadas:${NC}"
echo -e "  SCRIPT_DIR:    $SCRIPT_DIR"
echo -e "  PROJECT_ROOT:  $PROJECT_ROOT"
echo -e "  DATABASE_DIR:  $DATABASE_DIR"
echo -e "  DDL_DIR:       $DDL_DIR"
echo -e "  SETUP_DIR:     $SETUP_DIR"
echo -e "  SEED_DIR:      $SEED_DIR"
echo -e "  BACKEND_DIR:   $BACKEND_DIR"
echo ""

# Verificar directorios
print_header "📁 Verificación de Directorios"

if [ -d "$DATABASE_DIR" ]; then
    print_success "DATABASE_DIR existe"
else
    print_error "DATABASE_DIR NO existe: $DATABASE_DIR"
    exit 1
fi

if [ -d "$DDL_DIR" ]; then
    print_success "DDL_DIR existe"
else
    print_error "DDL_DIR NO existe: $DDL_DIR"
    exit 1
fi

if [ -d "$SETUP_DIR" ]; then
    print_success "SETUP_DIR existe"
else
    print_error "SETUP_DIR NO existe: $SETUP_DIR"
    exit 1
fi

if [ -d "$SEED_DIR" ]; then
    print_success "SEED_DIR existe"
else
    print_error "SEED_DIR NO existe: $SEED_DIR"
    exit 1
fi

if [ -d "$BACKEND_DIR" ]; then
    print_success "BACKEND_DIR existe"
else
    print_error "BACKEND_DIR NO existe: $BACKEND_DIR"
fi

# Contar archivos
print_header "📊 Conteo de Archivos"

sql_count=$(find "$DATABASE_DIR" -name "*.sql" | wc -l)
echo -e "  Total archivos SQL: ${GREEN}$sql_count${NC}"

if [ $sql_count -ge 350 ]; then
    print_success "Número suficiente de archivos SQL (esperados: ~354)"
else
    print_error "Pocos archivos SQL encontrados (encontrados: $sql_count, esperados: ~354)"
fi

# Verificar esquemas
print_header "🗄️ Verificación de Esquemas"

schemas=(
    "auth"
    "auth_management"
    "gamification_system"
    "educational_content"
    "progress_tracking"
    "content_management"
    "social_features"
    "system_configuration"
    "audit_logging"
    "gamilit"
)

for schema in "${schemas[@]}"; do
    schema_dir="$DDL_DIR/schemas/$schema"
    if [ -d "$schema_dir" ]; then
        tables_count=$(find "$schema_dir/tables" -name "*.sql" 2>/dev/null | wc -l)
        functions_count=$(find "$schema_dir/functions" -name "*.sql" 2>/dev/null | wc -l)
        print_success "$schema (tablas: $tables_count, funciones: $functions_count)"
    else
        print_error "$schema NO encontrado"
    fi
done

# Verificar seeds
print_header "🌱 Verificación de Seeds"

seed_schemas=(
    "auth_management"
    "educational_content"
    "gamification_system"
    "system_configuration"
)

for schema in "${seed_schemas[@]}"; do
    seed_schema_dir="$SEED_DIR/$schema"
    if [ -d "$seed_schema_dir" ]; then
        seed_count=$(find "$seed_schema_dir" -name "*.sql" | wc -l)
        print_success "$schema ($seed_count archivos)"
    else
        print_error "$schema NO encontrado"
    fi
done

# Verificar script de instalación
print_header "🔧 Verificación de Scripts de Instalación"

if [ -f "$SETUP_DIR/install-all.sh" ]; then
    print_success "install-all.sh encontrado"
else
    print_error "install-all.sh NO encontrado"
fi

if [ -f "$SETUP_DIR/db-setup.sh" ]; then
    print_success "db-setup.sh encontrado"
else
    print_error "db-setup.sh NO encontrado"
fi

# Verificar archivos .env.example
print_header "⚙️ Verificación de Archivos de Configuración"

if [ -f "$PROJECT_ROOT/.env.dev.example" ]; then
    print_success ".env.dev.example encontrado"
else
    print_error ".env.dev.example NO encontrado"
fi

if [ -f "$PROJECT_ROOT/.env.prod.example" ]; then
    print_success ".env.prod.example encontrado"
else
    print_error ".env.prod.example NO encontrado"
fi

# Resumen final
print_header "✅ RESUMEN DE VERIFICACIÓN"

echo -e "${GREEN}Todo está listo para ejecutar:${NC}"
echo ""
echo -e "  ${YELLOW}./setup-and-recreate-db.sh --env prod${NC}"
echo -e "  ${YELLOW}./00-init-database-from-scratch.sh --env prod${NC}"
echo ""
echo -e "${CYAN}Nota: Estos comandos están listos para funcionar tanto en:${NC}"
echo -e "  - Local: /home/isem/workspace/workspace-gamilit/projects/"
echo -e "  - Servidor: /home/gamilit/"
echo ""
