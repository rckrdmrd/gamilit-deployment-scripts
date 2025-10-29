#!/bin/bash

##############################################################################
# GAMILIT Platform - Recreate Database (Simple Version)
# No requiere usuario postgres, solo gamilit_user
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

# Step 1: Drop and recreate database
print_step "1/3: Recreando base de datos..."
psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d postgres -c "DROP DATABASE IF EXISTS ${DB_NAME};" 2>&1 | grep -v "does not exist" || true
psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d postgres -c "CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};"
print_success "Base de datos recreada"

# Step 2: Run install-all.sh
print_step "2/3: Instalando schemas, tablas, funciones..."
cd "${SCRIPT_DIR}"
bash install-all.sh 2>&1 | tee /tmp/gamilit_ddl.log

# Step 3: Load seeds
print_step "3/3: Cargando datos iniciales..."
cd "${SCRIPT_DIR}/../../scripts/database"
bash load-seeds-production.sh

echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  ✓ BASE DE DATOS LISTA${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""

# Summary
print_success "Usuarios de prueba creados:"
psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -c "SELECT email, role FROM auth.users ORDER BY email;" -t

echo ""
print_success "¡Deployment completado!"
echo ""
