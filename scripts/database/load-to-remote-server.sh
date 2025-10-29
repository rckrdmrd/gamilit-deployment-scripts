#!/bin/bash

##############################################################################
# GAMILIT Platform - Load DDL to Remote Server
#
# Este script carga todos los DDL y seeds al servidor remoto de producción
# sin necesidad de acceso SSH
##############################################################################

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DATABASE_DIR="$PROJECT_ROOT/database"
SETUP_DIR="$DATABASE_DIR/setup"

# Configuración servidor remoto
DB_HOST="74.208.126.102"
DB_PORT="5432"
DB_NAME="gamilit_platform"
DB_USER="gamilit_user"
DB_PASSWORD="mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj"

export PGPASSWORD="$DB_PASSWORD"

print_step() {
    echo -e "${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}GAMILIT - Carga de DDL a Servidor Remoto${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

print_step "Servidor: $DB_HOST"
print_step "Base de datos: $DB_NAME"
echo ""

# Ejecutar install-all.sh modificado para servidor remoto
cd "$SETUP_DIR"

# Crear configuración temporal
cat > .db-config-remote.env << EOF
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
EOF

print_step "Cargando funciones de auth..."
cd ../gamilit_platform/schemas/auth/functions
for f in *.sql; do
    [ -f "$f" ] || continue
    echo -n "  $f ... "
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$f" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
done

print_step "Cargando funciones de auth_management..."
cd ../../auth_management/functions
for f in *.sql; do
    [ -f "$f" ] || continue
    echo -n "  $f ... "
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$f" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
done

print_step "Cargando funciones de gamilit..."
cd ../../gamilit/functions
for f in *.sql; do
    [ -f "$f" ] || continue
    echo -n "  $f ... "
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$f" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
done

cd "$SCRIPT_DIR"
unset PGPASSWORD

echo ""
print_success "DDL cargado al servidor remoto"
echo ""
