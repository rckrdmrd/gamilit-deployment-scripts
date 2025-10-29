#!/bin/bash

##############################################################################
# GAMILIT Platform - Complete Database Setup & Deployment Script
#
# Este script:
# 1. Pregunta si es ambiente dev o prod
# 2. Genera credenciales seguras automáticamente
# 3. Crea/recrea la base de datos completa
# 4. Actualiza el .env correspondiente
# 5. Carga todos los seeds
# 6. Valida la instalación
##############################################################################

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# ============================================================================
# CONFIGURACIÓN DE PATHS RELATIVOS
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DATABASE_DIR="$PROJECT_ROOT/database"
DDL_DIR="$DATABASE_DIR/gamilit_platform"
SETUP_DIR="$DATABASE_DIR/setup"
SEED_DIR="$DDL_DIR/seed-data"
BACKEND_DIR="$PROJECT_ROOT/../gamilit-platform-backend"

# ============================================================================
# FUNCIONES DE UTILIDAD
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
    cat << EOF
GAMILIT Platform - Setup y Recreación de Base de Datos

Uso: $0 [OPCIONES]

Opciones:
  --env [dev|prod]    Ambiente (si no se especifica, pregunta)
  --skip-env-update   No actualizar archivo .env
  --help              Mostrar esta ayuda

Este script:
  1. Pregunta el ambiente (dev o prod)
  2. Genera credenciales seguras
  3. Crea/recrea la base de datos
  4. Actualiza el .env del backend
  5. Carga todos los seeds
  6. Valida la instalación

EOF
}

# ============================================================================
# GENERAR CREDENCIALES SEGURAS
# ============================================================================

generate_credentials() {
    print_step "Generando credenciales seguras..."

    # Nombre de base de datos
    DB_NAME="gamilit_platform"

    # Usuario de base de datos
    DB_USER="gamilit_user"

    # Contraseña segura (32 caracteres base64)
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)

    # JWT Secret
    JWT_SECRET=$(openssl rand -base64 32)

    # JWT Refresh Secret
    JWT_REFRESH_SECRET=$(openssl rand -base64 32)

    # Configuración de host/port
    DB_HOST="${DB_HOST:-localhost}"
    DB_PORT="${DB_PORT:-5432}"

    print_success "Credenciales generadas"
    print_info "DB: $DB_NAME"
    print_info "User: $DB_USER"
    print_info "Password: ${DB_PASSWORD:0:8}... (32 chars)"
}

# ============================================================================
# SELECCIONAR AMBIENTE
# ============================================================================

select_environment() {
    if [ -n "$ENVIRONMENT" ]; then
        setup_env_file
        return
    fi

    print_step "Seleccionar ambiente"

    echo -e "${CYAN}¿En qué ambiente deseas configurar la base de datos?${NC}"
    echo ""
    echo "  1) Desarrollo (dev)   - Actualiza .env.dev"
    echo "  2) Producción (prod)  - Actualiza .env.prod"
    echo ""

    while true; do
        read -p "Opción [1-2]: " env_choice
        case $env_choice in
            1)
                ENVIRONMENT="dev"
                break
                ;;
            2)
                ENVIRONMENT="prod"
                print_warning "MODO PRODUCCIÓN"
                break
                ;;
            *)
                echo -e "${RED}Opción inválida. Ingresa 1 o 2${NC}"
                ;;
        esac
    done

    print_success "Ambiente seleccionado: $ENVIRONMENT"
    setup_env_file
}

setup_env_file() {
    if [ "$ENVIRONMENT" = "prod" ]; then
        ENV_FILE="$PROJECT_ROOT/.env.prod"
        ENV_EXAMPLE="$PROJECT_ROOT/.env.prod.example"
    else
        ENV_FILE="$PROJECT_ROOT/.env.dev"
        ENV_EXAMPLE="$PROJECT_ROOT/.env.dev.example"
    fi

    print_info "Archivo: $(basename $ENV_FILE)"
}

# ============================================================================
# ACTUALIZAR .ENV
# ============================================================================

update_env_file() {
    if [ "$SKIP_ENV_UPDATE" = true ]; then
        print_warning "Saltando actualización de .env"
        return
    fi

    print_step "Actualizando archivo .env..."

    # Crear backup del .env actual
    if [ -f "$ENV_FILE" ]; then
        BACKUP_FILE="${ENV_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$ENV_FILE" "$BACKUP_FILE"
        print_info "Backup creado: $(basename $BACKUP_FILE)"
    else
        # Si no existe, copiar del example correspondiente
        if [ -f "$ENV_EXAMPLE" ]; then
            cp "$ENV_EXAMPLE" "$ENV_FILE"
            print_info "Archivo .env creado desde ejemplo"
        else
            print_error "No se encontró $ENV_EXAMPLE"
            exit 1
        fi
    fi

    # Actualizar o agregar variables de base de datos
    update_or_add_env_var "DB_HOST" "$DB_HOST"
    update_or_add_env_var "DB_PORT" "$DB_PORT"
    update_or_add_env_var "DB_NAME" "$DB_NAME"
    update_or_add_env_var "DB_USER" "$DB_USER"
    update_or_add_env_var "DB_PASSWORD" "$DB_PASSWORD"

    # Actualizar JWT secrets
    update_or_add_env_var "JWT_SECRET" "$JWT_SECRET"
    update_or_add_env_var "JWT_REFRESH_SECRET" "$JWT_REFRESH_SECRET"

    # Actualizar NODE_ENV
    if [ "$ENVIRONMENT" = "prod" ]; then
        update_or_add_env_var "NODE_ENV" "production"
    else
        update_or_add_env_var "NODE_ENV" "development"
    fi

    print_success "Archivo .env actualizado: $(basename $ENV_FILE)"
}

update_or_add_env_var() {
    local key="$1"
    local value="$2"

    if grep -q "^${key}=" "$ENV_FILE"; then
        # Variable existe, actualizar
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
        else
            # Linux
            sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
        fi
    else
        # Variable no existe, agregar
        echo "${key}=${value}" >> "$ENV_FILE"
    fi
}

# ============================================================================
# VERIFICAR PREREQUISITOS
# ============================================================================

check_prerequisites() {
    print_step "Verificando prerequisitos..."

    # Verificar psql
    if ! command -v psql &> /dev/null; then
        print_error "PostgreSQL client (psql) no encontrado"
        print_info "Instalar con: sudo apt-get install postgresql-client"
        exit 1
    fi
    print_success "psql encontrado"

    # Verificar openssl
    if ! command -v openssl &> /dev/null; then
        print_error "OpenSSL no encontrado"
        exit 1
    fi
    print_success "openssl encontrado"

    # Verificar directorios
    [ -d "$DDL_DIR" ] || { print_error "DDL dir no encontrado: $DDL_DIR"; exit 1; }
    [ -d "$SETUP_DIR" ] || { print_error "Setup dir no encontrado: $SETUP_DIR"; exit 1; }
    [ -d "$SEED_DIR" ] || { print_error "Seed dir no encontrado: $SEED_DIR"; exit 1; }
    print_success "Directorios encontrados"

    # Verificar conexión a PostgreSQL
    if command -v sudo &> /dev/null && sudo -n -u postgres psql -c "SELECT 1" &> /dev/null 2>&1; then
        USE_SUDO=true
        USE_POSTGRES=true
        print_success "Conectado a PostgreSQL vía sudo"
    elif PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "SELECT 1" &> /dev/null 2>&1; then
        USE_SUDO=false
        USE_DB_USER=true
        print_success "Conectado a PostgreSQL vía TCP (usuario existente)"
    else
        # Intentar con postgres user por defecto (peer authentication)
        if psql -U postgres -d postgres -c "SELECT 1" &> /dev/null 2>&1; then
            USE_POSTGRES=true
            print_success "Conectado a PostgreSQL (peer authentication)"
        else
            print_error "No se puede conectar a PostgreSQL"
            print_info "Asegúrate de que PostgreSQL esté corriendo:"
            print_info "  pg_isready -h localhost -p 5432"
            exit 1
        fi
    fi
}

# ============================================================================
# EJECUTAR SQL COMO POSTGRES
# ============================================================================

execute_as_postgres() {
    local sql="$1"

    if [ "$USE_SUDO" = true ]; then
        echo "$sql" | sudo -u postgres psql
    elif [ "$USE_POSTGRES" = true ]; then
        echo "$sql" | psql -U postgres
    elif [ "$USE_DB_USER" = true ]; then
        PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "$sql"
    else
        PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -c "$sql"
    fi
}

query_as_postgres() {
    local sql="$1"

    if [ "$USE_SUDO" = true ]; then
        echo "$sql" | sudo -u postgres psql -t | xargs
    elif [ "$USE_POSTGRES" = true ]; then
        echo "$sql" | psql -U postgres -t | xargs
    elif [ "$USE_DB_USER" = true ]; then
        PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -t -c "$sql" | xargs
    else
        PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -t -c "$sql" | xargs
    fi
}

# ============================================================================
# CREAR USUARIO Y BASE DE DATOS
# ============================================================================

create_user_and_database() {
    print_step "Creando usuario y base de datos..."

    # Verificar/crear usuario
    user_exists=$(query_as_postgres "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'")

    if [ -z "$user_exists" ]; then
        print_info "Creando usuario '$DB_USER'..."
        execute_as_postgres "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' CREATEDB;"
        print_success "Usuario creado con permisos CREATEDB"
    else
        print_info "Usuario '$DB_USER' ya existe, actualizando contraseña..."
        execute_as_postgres "ALTER USER $DB_USER WITH PASSWORD '$DB_PASSWORD' CREATEDB;"
        print_success "Usuario actualizado"
    fi

    # Verificar si base de datos existe
    db_exists=$(query_as_postgres "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")

    if [ -n "$db_exists" ]; then
        print_warning "Base de datos '$DB_NAME' ya existe"
        echo ""
        read -p "¿Eliminar y recrear? (escribir 'yes' para confirmar): " confirm

        if [ "$confirm" = "yes" ]; then
            print_info "Terminando conexiones activas..."
            execute_as_postgres "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();" &> /dev/null || true

            print_info "Eliminando base de datos..."
            execute_as_postgres "DROP DATABASE IF EXISTS $DB_NAME;"
            print_success "Base de datos eliminada"
        else
            print_info "Cancelado. Usando base de datos existente."
            return
        fi
    fi

    # Crear base de datos
    print_info "Creando base de datos '$DB_NAME'..."
    execute_as_postgres "CREATE DATABASE $DB_NAME OWNER $DB_USER ENCODING 'UTF8';"
    execute_as_postgres "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
    print_success "Base de datos creada"
}

# ============================================================================
# EJECUTAR DDL
# ============================================================================

execute_ddl() {
    print_step "Ejecutando DDL (esquemas, tablas, funciones, triggers, RLS)..."

    export PGPASSWORD="$DB_PASSWORD"

    # Guardar config para install-all.sh
    cat > "$SETUP_DIR/.db-config.env" << EOF
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
EOF

    chmod 600 "$SETUP_DIR/.db-config.env"

    # Ejecutar install-all.sh
    cd "$SETUP_DIR"

    if bash install-all.sh > /tmp/gamilit_ddl.log 2>&1; then
        print_success "DDL ejecutado exitosamente"
    else
        print_error "Error ejecutando DDL"
        print_info "Ver detalles en: /tmp/gamilit_ddl.log"
        tail -20 /tmp/gamilit_ddl.log
        exit 1
    fi

    cd "$SCRIPT_DIR"
    unset PGPASSWORD
}

# ============================================================================
# CARGAR SEEDS
# ============================================================================

load_seeds() {
    print_step "Cargando datos iniciales (seeds)..."

    export PGPASSWORD="$DB_PASSWORD"

    local seed_files=(
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

    local loaded=0
    local failed=0

    for seed_file in "${seed_files[@]}"; do
        local full_path="$SEED_DIR/$seed_file"

        if [ -f "$full_path" ]; then
            echo -n "  $(basename $seed_file) ... "

            if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$full_path" > /dev/null 2>&1; then
                echo -e "${GREEN}✓${NC}"
                ((loaded++))
            else
                echo -e "${RED}✗${NC}"
                ((failed++))
            fi
        else
            echo -e "  ${YELLOW}⊘ $(basename $seed_file) (no encontrado)${NC}"
        fi
    done

    unset PGPASSWORD

    print_success "Seeds cargados: $loaded"
    if [ $failed -gt 0 ]; then
        print_warning "Seeds fallidos: $failed"
    fi
}

# ============================================================================
# VALIDACIÓN
# ============================================================================

validate_installation() {
    print_step "Validando instalación..."

    export PGPASSWORD="$DB_PASSWORD"

    local users=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM auth.users WHERE deleted_at IS NULL;" 2>/dev/null || echo "0")

    local modules=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM educational_content.modules;" 2>/dev/null || echo "0")

    local exercises=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM educational_content.exercises;" 2>/dev/null || echo "0")

    local stats=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM gamification_system.user_stats;" 2>/dev/null || echo "0")

    unset PGPASSWORD

    echo ""
    echo -e "${MAGENTA}📊 Resultados:${NC}"
    echo -e "  Usuarios:   $users"
    echo -e "  Módulos:    $modules"
    echo -e "  Ejercicios: $exercises"
    echo -e "  Stats:      $stats"
    echo ""

    if [ "$users" -ge 1 ] && [ "$modules" -ge 1 ] && [ "$exercises" -ge 1 ]; then
        print_success "Validación exitosa"
        return 0
    else
        print_error "Validación falló"
        return 1
    fi
}

# ============================================================================
# RESUMEN FINAL
# ============================================================================

show_summary() {
    print_header "✅ INSTALACIÓN COMPLETADA"

    echo -e "${CYAN}Ambiente:${NC} $ENVIRONMENT"
    echo -e "${CYAN}Base de Datos:${NC} $DB_NAME"
    echo -e "${CYAN}Usuario:${NC} $DB_USER"
    echo -e "${CYAN}Host:${NC} $DB_HOST:$DB_PORT"
    echo ""

    echo -e "${CYAN}Archivo de configuración:${NC}"
    echo -e "  $(basename $ENV_FILE)"
    echo ""

    echo -e "${CYAN}Connection String:${NC}"
    echo -e "  postgresql://$DB_USER:****@$DB_HOST:$DB_PORT/$DB_NAME"
    echo ""

    echo -e "${MAGENTA}📝 Credenciales de Prueba:${NC}"
    echo -e "  student@gamilit.com / Test1234 (student)"
    echo -e "  teacher@gamilit.com / Test1234 (admin_teacher)"
    echo -e "  admin@gamilit.com   / Test1234 (super_admin)"
    echo ""

    echo -e "${CYAN}Próximos pasos:${NC}"
    echo -e "  1. Iniciar backend:"
    echo -e "     ${YELLOW}cd $BACKEND_DIR && npm run dev${NC}"
    echo ""
    echo -e "  2. Probar health:"
    echo -e "     ${YELLOW}curl http://localhost:3006/api/health${NC}"
    echo ""
    echo -e "  3. Login:"
    echo -e "     ${YELLOW}curl -X POST http://localhost:3006/api/auth/login \\${NC}"
    echo -e "     ${YELLOW}  -H 'Content-Type: application/json' \\${NC}"
    echo -e "     ${YELLOW}  -d '{\"email\":\"student@gamilit.com\",\"password\":\"Test1234\"}'${NC}"
    echo ""

    print_success "¡Base de datos lista para usar!"
    echo ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local SKIP_ENV_UPDATE=false
    local ENVIRONMENT=""

    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --env)
                ENVIRONMENT="$2"
                shift 2
                ;;
            --skip-env-update)
                SKIP_ENV_UPDATE=true
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
    print_header "GAMILIT - Setup y Recreación de Base de Datos"

    # Proceso
    select_environment
    generate_credentials
    check_prerequisites
    create_user_and_database
    update_env_file
    execute_ddl
    load_seeds
    validate_installation
    show_summary
}

# Ejecutar
main "$@"
