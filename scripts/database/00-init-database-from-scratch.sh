#!/bin/bash

##############################################################################
# GAMILIT Platform - Database Initialization from Scratch (Production Ready)
#
# Este script inicializa la base de datos desde cero, ideal para:
# - Primer despliegue en servidor productivo
# - Servidor donde no existe el usuario de base de datos
# - Instalación limpia sin base de datos previa
#
# Características:
# 1. Pregunta ambiente (dev/prod)
# 2. Genera credenciales seguras automáticamente
# 3. Crea usuario y base de datos PostgreSQL
# 4. Ejecuta todos los DDL (esquemas, tablas, funciones, triggers, RLS)
# 5. Carga datos iniciales (seeds)
# 6. Actualiza el archivo .env correspondiente
# 7. Valida la instalación
#
# Uso:
#   ./00-init-database-from-scratch.sh
#   ./00-init-database-from-scratch.sh --env prod
#   ./00-init-database-from-scratch.sh --env dev --skip-env-update
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
BACKEND_DIR="$PROJECT_ROOT/../backend"

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
GAMILIT Platform - Inicialización de Base de Datos desde Cero

Uso: $0 [OPCIONES]

Opciones:
  --env [dev|prod]     Ambiente a configurar (si no se especifica, pregunta interactivamente)
  --skip-env-update    No actualizar archivo .env (útil para testing)
  --db-host HOST       Host de PostgreSQL (default: localhost)
  --db-port PORT       Puerto de PostgreSQL (default: 5432)
  --help               Mostrar esta ayuda

Descripción:
  Este script inicializa la base de datos GAMILIT desde cero:
  1. Selecciona ambiente (dev o prod)
  2. Genera credenciales seguras automáticamente
  3. Crea usuario PostgreSQL si no existe
  4. Crea base de datos
  5. Ejecuta todos los DDL (esquemas, tablas, funciones, triggers, RLS)
  6. Carga datos iniciales (seeds)
  7. Actualiza archivo .env correspondiente
  8. Valida la instalación

Ejemplos:
  $0                                 # Modo interactivo
  $0 --env dev                       # Desarrollo
  $0 --env prod                      # Producción
  $0 --env prod --skip-env-update    # Producción sin actualizar .env

Requisitos:
  - PostgreSQL instalado y corriendo
  - Cliente psql disponible
  - Acceso como usuario postgres (vía sudo o peer authentication)
  - OpenSSL para generar credenciales

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

    # Contraseña segura (32 caracteres base64, sin caracteres especiales problemáticos)
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)

    # JWT Secrets
    JWT_SECRET=$(openssl rand -base64 32)
    JWT_REFRESH_SECRET=$(openssl rand -base64 32)

    # Configuración de host/port
    DB_HOST="${DB_HOST:-localhost}"
    DB_PORT="${DB_PORT:-5432}"

    print_success "Credenciales generadas"
    print_info "Base de datos: $DB_NAME"
    print_info "Usuario: $DB_USER"
    print_info "Password: ${DB_PASSWORD:0:8}... (32 caracteres)"
    print_info "Host: $DB_HOST:$DB_PORT"
}

# ============================================================================
# SELECCIONAR AMBIENTE
# ============================================================================

select_environment() {
    if [ -n "$ENVIRONMENT" ]; then
        print_info "Ambiente seleccionado: $ENVIRONMENT"
        setup_env_file
        return
    fi

    print_step "Seleccionar ambiente"

    echo -e "${CYAN}¿En qué ambiente deseas configurar la base de datos?${NC}"
    echo ""
    echo "  1) Desarrollo (dev)   - Para testing local, desarrollo"
    echo "  2) Producción (prod)  - Para servidor productivo"
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
                print_warning "MODO PRODUCCIÓN: Se generarán credenciales seguras"
                echo ""
                read -p "¿Continuar con instalación en PRODUCCIÓN? (escribir 'yes'): " confirm
                if [ "$confirm" != "yes" ]; then
                    print_info "Cancelado por usuario"
                    exit 0
                fi
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

    print_info "Archivo de configuración: $(basename $ENV_FILE)"
}

# ============================================================================
# ACTUALIZAR .ENV
# ============================================================================

update_env_file() {
    if [ "$SKIP_ENV_UPDATE" = true ]; then
        print_warning "Saltando actualización de .env (--skip-env-update)"
        return
    fi

    print_step "Actualizando archivo .env..."

    # Crear backup si existe
    if [ -f "$ENV_FILE" ]; then
        BACKUP_FILE="${ENV_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$ENV_FILE" "$BACKUP_FILE"
        print_info "Backup creado: $(basename $BACKUP_FILE)"
    else
        # Si no existe, copiar del example
        if [ -f "$ENV_EXAMPLE" ]; then
            cp "$ENV_EXAMPLE" "$ENV_FILE"
            print_info "Archivo .env creado desde ejemplo"
        else
            print_error "No se encontró $ENV_EXAMPLE"
            exit 1
        fi
    fi

    # Actualizar variables de base de datos
    update_or_add_env_var "DB_HOST" "$DB_HOST"
    update_or_add_env_var "DB_PORT" "$DB_PORT"
    update_or_add_env_var "DB_NAME" "$DB_NAME"
    update_or_add_env_var "DB_USER" "$DB_USER"
    update_or_add_env_var "DB_PASSWORD" "$DB_PASSWORD"

    # Actualizar JWT secrets
    update_or_add_env_var "JWT_SECRET" "$JWT_SECRET"
    update_or_add_env_var "JWT_REFRESH_SECRET" "$JWT_REFRESH_SECRET"
    update_or_add_env_var "VITE_JWT_SECRET" "$JWT_SECRET"

    # Actualizar NODE_ENV
    if [ "$ENVIRONMENT" = "prod" ]; then
        update_or_add_env_var "NODE_ENV" "production"
        update_or_add_env_var "APP_ENV" "production"
        update_or_add_env_var "VITE_APP_ENV" "production"
    else
        update_or_add_env_var "NODE_ENV" "development"
        update_or_add_env_var "APP_ENV" "development"
        update_or_add_env_var "VITE_APP_ENV" "development"
    fi

    print_success "Archivo .env actualizado: $(basename $ENV_FILE)"
    print_info "Ubicación: $ENV_FILE"
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
    print_success "psql encontrado: $(psql --version | head -1)"

    # Verificar openssl
    if ! command -v openssl &> /dev/null; then
        print_error "OpenSSL no encontrado"
        exit 1
    fi
    print_success "openssl encontrado"

    # Verificar directorios necesarios
    if [ ! -d "$DATABASE_DIR" ]; then
        print_error "Database dir no encontrado: $DATABASE_DIR"
        exit 1
    fi
    print_success "Database dir: $DATABASE_DIR"

    if [ ! -d "$SETUP_DIR" ]; then
        print_error "Setup dir no encontrado: $SETUP_DIR"
        exit 1
    fi
    print_success "Setup dir: $SETUP_DIR"

    if [ ! -d "$SEED_DIR" ]; then
        print_error "Seed dir no encontrado: $SEED_DIR"
        exit 1
    fi
    print_success "Seed dir: $SEED_DIR"

    # Verificar PostgreSQL está corriendo
    if ! pg_isready -h "$DB_HOST" -p "$DB_PORT" &> /dev/null; then
        print_error "PostgreSQL no está respondiendo en $DB_HOST:$DB_PORT"
        print_info "Verificar servicio: sudo systemctl status postgresql"
        print_info "Iniciar servicio: sudo systemctl start postgresql"
        exit 1
    fi
    print_success "PostgreSQL corriendo en $DB_HOST:$DB_PORT"

    # Determinar método de conexión a PostgreSQL
    if command -v sudo &> /dev/null && sudo -n -u postgres psql -c "SELECT 1" &> /dev/null 2>&1; then
        USE_SUDO=true
        CONNECTION_METHOD="sudo -u postgres"
        print_success "Conexión vía: sudo -u postgres"
    elif psql -U postgres -d postgres -c "SELECT 1" &> /dev/null 2>&1; then
        USE_SUDO=false
        CONNECTION_METHOD="peer authentication"
        print_success "Conexión vía: peer authentication"
    else
        print_error "No se puede conectar a PostgreSQL como superusuario"
        print_info "Este script necesita acceso como usuario 'postgres'"
        print_info "Opciones:"
        print_info "  1. Configurar sudo sin password para postgres"
        print_info "  2. Ejecutar como usuario postgres: sudo -u postgres $0"
        print_info "  3. Configurar peer authentication en pg_hba.conf"
        exit 1
    fi
}

# ============================================================================
# EJECUTAR SQL COMO POSTGRES
# ============================================================================

execute_as_postgres() {
    local sql="$1"

    if [ "$USE_SUDO" = true ]; then
        echo "$sql" | sudo -u postgres psql 2>&1
    else
        echo "$sql" | psql -U postgres 2>&1
    fi
}

query_as_postgres() {
    local sql="$1"

    if [ "$USE_SUDO" = true ]; then
        echo "$sql" | sudo -u postgres psql -t -A 2>&1
    else
        echo "$sql" | psql -U postgres -t -A 2>&1
    fi
}

# ============================================================================
# CREAR USUARIO Y BASE DE DATOS
# ============================================================================

create_user_and_database() {
    print_step "Creando usuario y base de datos..."

    # Verificar si usuario existe
    user_exists=$(query_as_postgres "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER';" | grep -c "1" || echo "0")

    if [ "$user_exists" = "0" ]; then
        print_info "Creando usuario '$DB_USER'..."
        execute_as_postgres "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' CREATEDB;" > /dev/null
        print_success "Usuario '$DB_USER' creado con permisos CREATEDB"
    else
        print_warning "Usuario '$DB_USER' ya existe"
        print_info "Actualizando contraseña..."
        execute_as_postgres "ALTER USER $DB_USER WITH PASSWORD '$DB_PASSWORD' CREATEDB;" > /dev/null
        print_success "Contraseña actualizada"
    fi

    # Verificar si base de datos existe
    db_exists=$(query_as_postgres "SELECT 1 FROM pg_database WHERE datname='$DB_NAME';" | grep -c "1" || echo "0")

    if [ "$db_exists" != "0" ]; then
        print_warning "Base de datos '$DB_NAME' ya existe"
        echo ""

        if [ "$FORCE_RECREATE" = true ]; then
            confirm="yes"
        else
            read -p "¿Eliminar y recrear? (escribir 'yes' para confirmar): " confirm
        fi

        if [ "$confirm" = "yes" ]; then
            print_info "Terminando conexiones activas..."
            execute_as_postgres "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();" > /dev/null 2>&1 || true

            print_info "Eliminando base de datos..."
            execute_as_postgres "DROP DATABASE IF EXISTS $DB_NAME;" > /dev/null
            print_success "Base de datos eliminada"
        else
            print_error "Operación cancelada por usuario"
            exit 1
        fi
    fi

    # Crear base de datos
    print_info "Creando base de datos '$DB_NAME'..."
    execute_as_postgres "CREATE DATABASE $DB_NAME OWNER $DB_USER ENCODING 'UTF8';" > /dev/null
    print_success "Base de datos creada"

    print_info "Otorgando privilegios..."
    execute_as_postgres "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" > /dev/null
    print_success "Privilegios otorgados"

    # Verificar creación
    created=$(query_as_postgres "SELECT 1 FROM pg_database WHERE datname='$DB_NAME';" | grep -c "1" || echo "0")
    if [ "$created" = "1" ]; then
        print_success "Base de datos '$DB_NAME' creada exitosamente"
    else
        print_error "Error verificando creación de base de datos"
        exit 1
    fi
}

# ============================================================================
# EJECUTAR DDL
# ============================================================================

execute_ddl() {
    print_step "Ejecutando DDL (esquemas, tablas, funciones, triggers, RLS)..."

    export PGPASSWORD="$DB_PASSWORD"

    # Crear archivo de configuración temporal para install-all.sh
    cat > "$SETUP_DIR/.db-config.env" << EOF
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
EOF

    chmod 600 "$SETUP_DIR/.db-config.env"

    # Cambiar al directorio setup y ejecutar install-all.sh
    cd "$SETUP_DIR"

    print_info "Ejecutando install-all.sh..."

    if bash install-all.sh > /tmp/gamilit_ddl_install.log 2>&1; then
        print_success "DDL ejecutado exitosamente"
    else
        print_error "Error ejecutando DDL"
        print_info "Ver detalles en: /tmp/gamilit_ddl_install.log"
        echo ""
        echo -e "${YELLOW}Últimas 30 líneas del log:${NC}"
        tail -30 /tmp/gamilit_ddl_install.log

        # Limpiar
        rm -f "$SETUP_DIR/.db-config.env"
        unset PGPASSWORD
        exit 1
    fi

    # Limpiar archivo temporal
    rm -f "$SETUP_DIR/.db-config.env"

    cd "$SCRIPT_DIR"
    unset PGPASSWORD
}

# ============================================================================
# CARGAR SEEDS
# ============================================================================

load_seeds() {
    print_step "Cargando datos iniciales (seeds)..."

    export PGPASSWORD="$DB_PASSWORD"

    # Lista de seeds en orden de carga
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
    local skipped=0

    for seed_file in "${seed_files[@]}"; do
        local full_path="$SEED_DIR/$seed_file"
        local filename=$(basename "$seed_file")

        if [ ! -f "$full_path" ]; then
            echo -e "  ${YELLOW}⊘ $filename (no encontrado)${NC}"
            ((skipped++))
            continue
        fi

        echo -n "  $filename ... "

        if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$full_path" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
            ((loaded++))
        else
            echo -e "${RED}✗${NC}"
            ((failed++))
        fi
    done

    unset PGPASSWORD

    echo ""
    print_success "Seeds cargados: $loaded"
    if [ $failed -gt 0 ]; then
        print_warning "Seeds fallidos: $failed"
    fi
    if [ $skipped -gt 0 ]; then
        print_info "Seeds omitidos: $skipped"
    fi
}

# ============================================================================
# VALIDACIÓN
# ============================================================================

validate_installation() {
    print_step "Validando instalación..."

    export PGPASSWORD="$DB_PASSWORD"

    # Contar usuarios
    local users=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM auth.users WHERE deleted_at IS NULL;" 2>/dev/null || echo "0")

    # Contar módulos
    local modules=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM educational_content.modules;" 2>/dev/null || echo "0")

    # Contar ejercicios
    local exercises=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM educational_content.exercises;" 2>/dev/null || echo "0")

    # Contar stats
    local stats=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM gamification_system.user_stats;" 2>/dev/null || echo "0")

    # Contar esquemas
    local schemas=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
        "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name IN ('auth', 'auth_management', 'gamification_system', 'educational_content', 'progress_tracking', 'content_management', 'social_features', 'system_configuration', 'audit_logging');" 2>/dev/null || echo "0")

    unset PGPASSWORD

    echo ""
    echo -e "${MAGENTA}📊 Resultados de Validación:${NC}"
    echo -e "  Esquemas:   $schemas / 9"
    echo -e "  Usuarios:   $users"
    echo -e "  Módulos:    $modules"
    echo -e "  Ejercicios: $exercises"
    echo -e "  Stats:      $stats"
    echo ""

    local validation_passed=true

    if [ "$schemas" -lt 9 ]; then
        print_error "Faltan esquemas (esperado: 9, encontrado: $schemas)"
        validation_passed=false
    fi

    if [ "$users" -lt 1 ]; then
        print_warning "No hay usuarios cargados"
    fi

    if [ "$modules" -lt 1 ]; then
        print_warning "No hay módulos cargados"
    fi

    if [ "$exercises" -lt 1 ]; then
        print_warning "No hay ejercicios cargados"
    fi

    if [ "$validation_passed" = true ]; then
        print_success "Validación de estructura exitosa"
        return 0
    else
        print_error "Validación falló"
        return 1
    fi
}

# ============================================================================
# GUARDAR CREDENCIALES
# ============================================================================

save_credentials() {
    print_step "Guardando credenciales..."

    local creds_file="$PROJECT_ROOT/database-credentials-$ENVIRONMENT.txt"

    cat > "$creds_file" << EOF
=============================================================================
GAMILIT Platform - Database Credentials
=============================================================================
Environment: $ENVIRONMENT
Generated: $(date '+%Y-%m-%d %H:%M:%S')

Database Configuration:
  Host:     $DB_HOST
  Port:     $DB_PORT
  Database: $DB_NAME
  User:     $DB_USER
  Password: $DB_PASSWORD

JWT Configuration:
  Secret:         $JWT_SECRET
  Refresh Secret: $JWT_REFRESH_SECRET

Connection String:
  postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME

psql Command:
  PGPASSWORD='$DB_PASSWORD' psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME

Environment File:
  $ENV_FILE

Test Users:
  student@gamilit.com / Test1234 (role: student)
  teacher@gamilit.com / Test1234 (role: admin_teacher)
  admin@gamilit.com   / Test1234 (role: super_admin)

=============================================================================
SECURITY WARNING: Protege este archivo! Contiene credenciales sensibles.
=============================================================================
EOF

    chmod 600 "$creds_file"

    print_success "Credenciales guardadas en: $(basename $creds_file)"
    print_warning "IMPORTANTE: Este archivo contiene información sensible!"
}

# ============================================================================
# RESUMEN FINAL
# ============================================================================

show_summary() {
    print_header "✅ INSTALACIÓN COMPLETADA EXITOSAMENTE"

    echo -e "${CYAN}Ambiente:${NC} $ENVIRONMENT"
    echo -e "${CYAN}Base de Datos:${NC} $DB_NAME"
    echo -e "${CYAN}Usuario:${NC} $DB_USER"
    echo -e "${CYAN}Host:${NC} $DB_HOST:$DB_PORT"
    echo ""

    echo -e "${CYAN}Archivos de Configuración:${NC}"
    echo -e "  .env:         $(basename $ENV_FILE)"
    echo -e "  Credenciales: database-credentials-$ENVIRONMENT.txt"
    echo ""

    echo -e "${CYAN}Connection String:${NC}"
    echo -e "  postgresql://$DB_USER:****@$DB_HOST:$DB_PORT/$DB_NAME"
    echo ""

    echo -e "${MAGENTA}📝 Usuarios de Prueba:${NC}"
    echo -e "  student@gamilit.com / Test1234 ${YELLOW}(student)${NC}"
    echo -e "  teacher@gamilit.com / Test1234 ${YELLOW}(admin_teacher)${NC}"
    echo -e "  admin@gamilit.com   / Test1234 ${YELLOW}(super_admin)${NC}"
    echo ""

    echo -e "${CYAN}Próximos Pasos:${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} Verificar archivo .env:"
    echo -e "     ${YELLOW}cat $ENV_FILE${NC}"
    echo ""

    if [ -d "$BACKEND_DIR" ]; then
        echo -e "  ${GREEN}2.${NC} Iniciar backend:"
        echo -e "     ${YELLOW}cd $BACKEND_DIR && npm install && npm run dev${NC}"
        echo ""
        echo -e "  ${GREEN}3.${NC} Probar health endpoint:"
        echo -e "     ${YELLOW}curl http://localhost:3006/api/health${NC}"
        echo ""
        echo -e "  ${GREEN}4.${NC} Login de prueba:"
        echo -e "     ${YELLOW}curl -X POST http://localhost:3006/api/auth/login \\${NC}"
        echo -e "     ${YELLOW}  -H 'Content-Type: application/json' \\${NC}"
        echo -e "     ${YELLOW}  -d '{\"email\":\"student@gamilit.com\",\"password\":\"Test1234\"}'${NC}"
    else
        echo -e "  ${GREEN}2.${NC} Copiar archivo .env al backend:"
        echo -e "     ${YELLOW}cp $ENV_FILE <backend-directory>/.env${NC}"
        echo ""
        echo -e "  ${GREEN}3.${NC} Iniciar aplicación backend"
    fi

    echo ""
    print_success "¡Base de datos GAMILIT lista para usar!"
    echo ""

    if [ "$ENVIRONMENT" = "prod" ]; then
        echo -e "${RED}⚠️  RECORDATORIO DE PRODUCCIÓN:${NC}"
        echo -e "  • Asegurar que el archivo .env no se suba a git"
        echo -e "  • Configurar backups automáticos de la base de datos"
        echo -e "  • Revisar configuración de firewall"
        echo -e "  • Configurar SSL/TLS si es necesario"
        echo -e "  • Implementar monitoreo y alertas"
        echo ""
    fi
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local SKIP_ENV_UPDATE=false
    local ENVIRONMENT=""
    local FORCE_RECREATE=false

    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --env)
                ENVIRONMENT="$2"
                if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
                    print_error "Ambiente inválido: $ENVIRONMENT (debe ser 'dev' o 'prod')"
                    exit 1
                fi
                shift 2
                ;;
            --skip-env-update)
                SKIP_ENV_UPDATE=true
                shift
                ;;
            --db-host)
                DB_HOST="$2"
                shift 2
                ;;
            --db-port)
                DB_PORT="$2"
                shift 2
                ;;
            --force)
                FORCE_RECREATE=true
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

    # Banner principal
    print_header "🚀 GAMILIT Platform - Inicialización de Base de Datos"

    # Flujo principal
    select_environment
    generate_credentials
    check_prerequisites
    create_user_and_database
    update_env_file
    execute_ddl
    load_seeds
    validate_installation
    save_credentials
    show_summary
}

# Ejecutar
main "$@"
