#!/bin/bash

##############################################################################
# GAMILIT Platform - Full Database Recreation Script
#
# Descripción: Recreación COMPLETA de la base de datos desde cero
#              - Elimina base de datos existente
#              - Crea usuario y base de datos
#              - Ejecuta todos los DDL (schemas, tables, functions, triggers, etc.)
#              - Carga todos los seeds
#              - Valida la instalación
#
# Uso: ./full-recreate-database.sh
# Opciones:
#   --no-confirm    No pedir confirmación antes de eliminar la BD
#   --help          Mostrar ayuda
##############################################################################

set -e  # Exit on error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================================================
# CONFIGURACIÓN DE PATHS RELATIVOS
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WORKSPACE_ROOT="$(cd "$PROJECT_ROOT/../.." && pwd)"  # Subir dos niveles más para llegar a workspace-gamilit
DOCS_ROOT="$WORKSPACE_ROOT/docs"
DDL_ROOT="$DOCS_ROOT/03-desarrollo/base-de-datos/backup-ddl"
DDL_DIR="$DDL_ROOT/gamilit_platform"
SETUP_DIR="$DDL_ROOT/setup"
SEED_DIR="$DDL_DIR/seed-data"

# Backend para obtener configuración
BACKEND_DIR="$WORKSPACE_ROOT/projects/gamilit-platform-backend"

# ============================================================================
# CONFIGURACIÓN DE BASE DE DATOS
# ============================================================================

# Intentar cargar desde .env del backend
if [ -f "$BACKEND_DIR/.env" ]; then
    export $(grep -v '^#' "$BACKEND_DIR/.env" | grep -E '^(DB_|POSTGRES_)' | xargs)
fi

# Valores por defecto (si no están en .env)
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-gamilit_platform}"
DB_USER="${DB_USER:-gamilit_user}"
DB_PASSWORD="${DB_PASSWORD:-mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"

# ============================================================================
# FUNCIONES AUXILIARES
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

print_info() {
    echo -e "  $1"
}

show_help() {
    echo "GAMILIT Platform - Full Database Recreation Script"
    echo ""
    echo "Uso: $0 [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  --no-confirm    No pedir confirmación antes de eliminar la BD"
    echo "  --help          Mostrar esta ayuda"
    echo ""
    echo "Este script:"
    echo "  1. Elimina la base de datos existente (si existe)"
    echo "  2. Crea usuario y base de datos desde cero"
    echo "  3. Ejecuta todos los DDL (schemas, enums, tables, functions, triggers, views, RLS)"
    echo "  4. Carga todos los seeds de datos"
    echo "  5. Valida la instalación"
    echo ""
}

# ============================================================================
# VERIFICACIÓN DE PREREQUISITOS
# ============================================================================

check_prerequisites() {
    print_step "Verificando prerequisitos..."

    # Verificar que existe psql
    if ! command -v psql &> /dev/null; then
        print_error "PostgreSQL client (psql) no encontrado"
        print_info "Instalar con: sudo apt-get install postgresql-client"
        exit 1
    fi
    print_success "psql encontrado"

    # Verificar que existen los directorios necesarios
    if [ ! -d "$DDL_DIR" ]; then
        print_error "Directorio DDL no encontrado: $DDL_DIR"
        exit 1
    fi
    print_success "Directorio DDL encontrado"

    if [ ! -d "$SETUP_DIR" ]; then
        print_error "Directorio setup no encontrado: $SETUP_DIR"
        exit 1
    fi
    print_success "Directorio setup encontrado"

    if [ ! -d "$SEED_DIR" ]; then
        print_error "Directorio seeds no encontrado: $SEED_DIR"
        exit 1
    fi
    print_success "Directorio seeds encontrado"

    # Verificar conexión a PostgreSQL
    if command -v sudo &> /dev/null && sudo -n -u postgres psql -c "SELECT 1" &> /dev/null 2>&1; then
        USE_SUDO=true
        print_success "Conectado a PostgreSQL vía sudo"
    elif [ -n "$POSTGRES_PASSWORD" ] && PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$POSTGRES_USER" -c "SELECT 1" &> /dev/null 2>&1; then
        USE_SUDO=false
        print_success "Conectado a PostgreSQL vía TCP (usuario postgres)"
    elif PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "SELECT 1" &> /dev/null 2>&1; then
        USE_SUDO=false
        USE_DB_USER=true
        print_success "Conectado a PostgreSQL vía TCP (usuario $DB_USER)"
        print_warning "Usando usuario $DB_USER - debe tener permisos para crear/eliminar bases de datos"
    else
        print_error "No se puede conectar a PostgreSQL"
        print_info "Asegúrate de que PostgreSQL esté corriendo"
        print_info "Y que tengas permisos para conectarte"
        exit 1
    fi
}

# ============================================================================
# FUNCIÓN PARA EJECUTAR SQL COMO POSTGRES
# ============================================================================

execute_as_postgres() {
    local sql="$1"
    if [ "$USE_SUDO" = true ]; then
        echo "$sql" | sudo -u postgres psql
    elif [ "$USE_DB_USER" = true ]; then
        PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "$sql"
    else
        PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$POSTGRES_USER" -c "$sql"
    fi
}

query_as_postgres() {
    local sql="$1"
    if [ "$USE_SUDO" = true ]; then
        echo "$sql" | sudo -u postgres psql -t | xargs
    elif [ "$USE_DB_USER" = true ]; then
        PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -t -c "$sql" | xargs
    else
        PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$POSTGRES_USER" -t -c "$sql" | xargs
    fi
}

# ============================================================================
# PASO 1: ELIMINAR BASE DE DATOS EXISTENTE
# ============================================================================

drop_database() {
    print_step "PASO 1/6: Eliminando base de datos existente..."

    # Verificar si existe
    db_exists=$(query_as_postgres "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")

    if [ -z "$db_exists" ]; then
        print_info "Base de datos '$DB_NAME' no existe, se creará desde cero"
        return
    fi

    # Terminar conexiones activas
    print_info "Terminando conexiones activas..."
    execute_as_postgres "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();" &> /dev/null || true

    # Eliminar base de datos
    print_info "Eliminando base de datos '$DB_NAME'..."
    execute_as_postgres "DROP DATABASE IF EXISTS $DB_NAME;"
    print_success "Base de datos eliminada"
}

# ============================================================================
# PASO 2: CREAR USUARIO Y BASE DE DATOS
# ============================================================================

create_user_and_database() {
    print_step "PASO 2/6: Creando usuario y base de datos..."

    # Verificar/crear usuario
    user_exists=$(query_as_postgres "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'")

    if [ -z "$user_exists" ]; then
        print_info "Creando usuario '$DB_USER'..."
        execute_as_postgres "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
        print_success "Usuario creado"
    else
        print_info "Usuario '$DB_USER' ya existe"
        # Actualizar contraseña por si acaso
        execute_as_postgres "ALTER USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
    fi

    # Crear base de datos
    print_info "Creando base de datos '$DB_NAME'..."
    execute_as_postgres "CREATE DATABASE $DB_NAME OWNER $DB_USER ENCODING 'UTF8';"
    print_success "Base de datos creada"

    # Otorgar privilegios
    execute_as_postgres "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
    print_success "Privilegios otorgados"
}

# ============================================================================
# PASO 3: EJECUTAR INSTALL-ALL.SH
# ============================================================================

execute_install_all() {
    print_step "PASO 3/6: Ejecutando install-all.sh (DDL completo)..."

    # Guardar configuración en config.md para install-all.sh
    cat > "$SETUP_DIR/config.md" << EOF
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
EOF

    chmod 600 "$SETUP_DIR/config.md"

    # Ejecutar install-all.sh
    cd "$SETUP_DIR"

    if bash install-all.sh; then
        print_success "DDL ejecutado correctamente"
    else
        print_error "Error ejecutando DDL"
        exit 1
    fi

    cd "$SCRIPT_DIR"
}

# ============================================================================
# PASO 4: CARGAR SEEDS
# ============================================================================

load_seeds() {
    print_step "PASO 4/6: Cargando datos iniciales (seeds)..."

    export PGPASSWORD="$DB_PASSWORD"

    # Array de archivos seed en orden de ejecución
    local seed_files=(
        # Auth management (usuarios de prueba)
        "auth_management/01-seed-users.sql"

        # Educational content
        "educational_content/01-seed-modules.sql"
        "educational_content/05-seed-module1-complete.sql"
        "educational_content/06-seed-modules-2-3-4.sql"

        # Gamification system
        "gamification_system/00-seed-achievement_categories.sql"
        "gamification_system/01-seed-achievements.sql"
        "gamification_system/02-seed-leaderboard_metadata.sql"
        "gamification_system/03-seed-maya-ranks.sql"
        "gamification_system/01-initialize-user-gamification.sql"

        # System configuration (si existe)
        "system_configuration/01-seed-config.sql"
    )

    local loaded=0
    local skipped=0

    for seed_file in "${seed_files[@]}"; do
        local full_path="$SEED_DIR/$seed_file"

        if [ -f "$full_path" ]; then
            print_info "Cargando: $seed_file"

            if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$full_path" > /dev/null 2>&1; then
                echo -e "${GREEN}  ✓${NC}"
                ((loaded++))
            else
                echo -e "${YELLOW}  ⚠ Error (continuando...)${NC}"
            fi
        else
            print_warning "No encontrado: $seed_file (omitiendo)"
            ((skipped++))
        fi
    done

    unset PGPASSWORD

    print_success "Seeds cargados: $loaded archivos"
    if [ $skipped -gt 0 ]; then
        print_warning "Seeds omitidos: $skipped archivos"
    fi
}

# ============================================================================
# PASO 5: VALIDACIÓN
# ============================================================================

validate_installation() {
    print_step "PASO 5/6: Validando instalación..."

    export PGPASSWORD="$DB_PASSWORD"

    # Contar schemas
    local schema_count=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast');")
    print_info "Schemas: $schema_count"

    # Contar tablas
    local table_count=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM pg_tables WHERE schemaname NOT IN ('pg_catalog', 'information_schema');")
    print_info "Tablas: $table_count"

    # Contar funciones
    local function_count=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname NOT IN ('pg_catalog', 'information_schema');")
    print_info "Funciones: $function_count"

    # Contar usuarios
    local user_count=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM auth.users WHERE deleted_at IS NULL;" 2>/dev/null || echo "0")
    print_info "Usuarios: $user_count"

    # Contar módulos educativos
    local module_count=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM educational_content.modules;" 2>/dev/null || echo "0")
    print_info "Módulos educativos: $module_count"

    # Contar ejercicios
    local exercise_count=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM educational_content.exercises;" 2>/dev/null || echo "0")
    print_info "Ejercicios: $exercise_count"

    unset PGPASSWORD

    # Validaciones mínimas
    if [ "$schema_count" -lt 5 ]; then
        print_error "Muy pocos schemas creados"
        return 1
    fi

    if [ "$table_count" -lt 10 ]; then
        print_error "Muy pocas tablas creadas"
        return 1
    fi

    print_success "Validación completada"
}

# ============================================================================
# PASO 6: RESUMEN
# ============================================================================

show_summary() {
    print_step "PASO 6/6: Resumen de la instalación"

    print_header "✅ BASE DE DATOS RECREADA EXITOSAMENTE"

    echo -e "${CYAN}Información de conexión:${NC}"
    echo -e "  Host:     $DB_HOST:$DB_PORT"
    echo -e "  Database: $DB_NAME"
    echo -e "  User:     $DB_USER"
    echo ""

    echo -e "${CYAN}Connection String:${NC}"
    echo -e "  postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME"
    echo ""

    echo -e "${CYAN}Próximos pasos:${NC}"
    echo -e "  1. Verificar configuración del backend (.env):"
    echo -e "     ${YELLOW}$BACKEND_DIR/.env${NC}"
    echo -e ""
    echo -e "  2. Iniciar el backend:"
    echo -e "     ${YELLOW}cd $BACKEND_DIR && npm run dev${NC}"
    echo -e ""
    echo -e "  3. Probar el endpoint de salud:"
    echo -e "     ${YELLOW}curl http://localhost:3006/api/health${NC}"
    echo -e ""
    echo -e "  4. Login de prueba:"
    echo -e "     Usuario: ${YELLOW}student@gamilit.com${NC}"
    echo -e "     Password: ${YELLOW}Test1234${NC}"
    echo ""

    print_success "¡Base de datos lista para usar!"
    echo ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local no_confirm=false

    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-confirm)
                no_confirm=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_error "Opción desconocida: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Header
    print_header "GAMILIT Platform - Recreación Completa de Base de Datos"

    echo -e "${YELLOW}ADVERTENCIA:${NC} Este script eliminará TODOS los datos de la base de datos:"
    echo -e "  Base de datos: ${RED}$DB_NAME${NC}"
    echo -e "  Host: $DB_HOST:$DB_PORT"
    echo ""

    # Pedir confirmación
    if [ "$no_confirm" = false ]; then
        read -p "¿Estás seguro de que deseas continuar? (escribir 'yes' para confirmar): " confirm
        if [ "$confirm" != "yes" ]; then
            print_info "Operación cancelada"
            exit 0
        fi
    fi

    # Ejecutar pasos
    check_prerequisites
    drop_database
    create_user_and_database
    execute_install_all
    load_seeds
    validate_installation
    show_summary
}

# Ejecutar main
main "$@"
