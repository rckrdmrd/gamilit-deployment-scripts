#!/bin/bash

##############################################################################
# GAMILIT Platform - Clean and Recreate Database Objects
# Drops all schemas and recreates without dropping the database itself
##############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_step() {
    echo -e "${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.md"

# Check if config exists
if [ ! -f "${CONFIG_FILE}" ]; then
    print_error "config.md not found!"
    exit 1
fi

# Load config
DB_HOST=$(grep "^DB_HOST=" "${CONFIG_FILE}" | head -1 | cut -d'=' -f2)
DB_PORT=$(grep "^DB_PORT=" "${CONFIG_FILE}" | head -1 | cut -d'=' -f2)
DB_NAME=$(grep "^DB_NAME=" "${CONFIG_FILE}" | head -1 | cut -d'=' -f2)
DB_USER=$(grep "^DB_USER=" "${CONFIG_FILE}" | head -1 | cut -d'=' -f2)
DB_PASSWORD=$(grep "^DB_PASSWORD=" "${CONFIG_FILE}" | head -1 | cut -d'=' -f2)

export PGPASSWORD="${DB_PASSWORD}"

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}  GAMILIT - Recrear Base de Datos${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

# Step 1: Clean all schemas
print_step "1/3: Limpiando schemas existentes..."

# Get list of schemas to drop (exclude system schemas AND public)
SCHEMAS=$(psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -tAc "
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast', 'pg_temp_1', 'pg_toast_temp_1', 'public')
ORDER BY schema_name;
")

if [ -n "$SCHEMAS" ]; then
    for schema in $SCHEMAS; do
        echo -n "  Dropping schema: $schema..."
        psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -c "DROP SCHEMA IF EXISTS $schema CASCADE;" > /dev/null 2>&1
        echo " ✓"
    done
    print_success "Schemas limpiados"
else
    print_success "No hay schemas que limpiar"
fi

# Clean all objects from public schema (but keep the schema itself)
print_step "2/3: Limpiando schema public..."
psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} <<EOF > /dev/null 2>&1
-- Drop all tables
DO \$\$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END \$\$;

-- Drop all functions
DO \$\$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT proname, oidvectortypes(proargtypes) as argtypes
              FROM pg_proc INNER JOIN pg_namespace ns ON (pg_proc.pronamespace = ns.oid)
              WHERE ns.nspname = 'public') LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS public.' || quote_ident(r.proname) || '(' || r.argtypes || ') CASCADE';
    END LOOP;
END \$\$;

-- Drop all types
DO \$\$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT typname FROM pg_type t JOIN pg_namespace n ON t.typnamespace = n.oid
              WHERE n.nspname = 'public' AND t.typtype = 'e') LOOP
        EXECUTE 'DROP TYPE IF EXISTS public.' || quote_ident(r.typname) || ' CASCADE';
    END LOOP;
END \$\$;
EOF
print_success "Schema public limpiado"

# Step 3: Run install-all.sh
print_step "3/3: Instalando schemas, tablas, funciones y cargando datos..."
cd "${SCRIPT_DIR}"
bash install-all.sh 2>&1 | grep -E "(Step|Installing|→|✓|✗|Schemas created|Tables created|Functions created)"

# Load seeds
echo ""
cd "${SCRIPT_DIR}/../../scripts/database"
bash load-seeds-production.sh 2>&1 | grep -E "(▶|✓|✗|Cargando|seed|SEED DATA)"

echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  ✓ BASE DE DATOS LISTA${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""

# Verification
print_step "Verificando instalación..."
TABLE_COUNT=$(psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -tAc "SELECT COUNT(*) FROM pg_tables WHERE schemaname NOT IN ('pg_catalog', 'information_schema');")
print_success "Tablas creadas: ${TABLE_COUNT}"

USER_COUNT=$(psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -tAc "SELECT COUNT(*) FROM auth.users;" 2>/dev/null || echo "0")
print_success "Usuarios creados: ${USER_COUNT}"

echo ""
print_success "¡Deployment completado!"
echo ""
