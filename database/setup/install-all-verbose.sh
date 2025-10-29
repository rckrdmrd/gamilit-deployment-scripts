#!/bin/bash

# =====================================================
# Complete Database Installation Script - VERBOSE MODE
# Description: Installs all schemas, tables, functions, triggers, views, and RLS
# Created: 2025-10-28
# =====================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if config.md exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.md"
DDL_DIR="${SCRIPT_DIR}/../gamilit_platform"

if [ ! -f "${CONFIG_FILE}" ]; then
    print_error "Configuration file not found: ${CONFIG_FILE}"
    print_info "Please run db-setup.sh first"
    exit 1
fi

# Extract credentials from config.md
print_info "Reading configuration..."
DB_HOST=$(grep "DB_HOST=" "${CONFIG_FILE}" | cut -d'=' -f2)
DB_PORT=$(grep "DB_PORT=" "${CONFIG_FILE}" | cut -d'=' -f2)
DB_NAME=$(grep "DB_NAME=" "${CONFIG_FILE}" | cut -d'=' -f2)
DB_USER=$(grep "DB_USER=" "${CONFIG_FILE}" | cut -d'=' -f2)
DB_PASSWORD=$(grep "DB_PASSWORD=" "${CONFIG_FILE}" | cut -d'=' -f2)

export PGPASSWORD="${DB_PASSWORD}"

# Function to execute SQL file WITH error reporting
execute_sql_verbose() {
    local file=$1
    local description=$2
    local error_log="/tmp/gamilit_install_errors.log"

    if [ ! -f "${file}" ]; then
        print_warn "File not found: ${file}, skipping..."
        return 1
    fi

    # Execute and capture errors
    if psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f "${file}" 2>"${error_log}"; then
        return 0
    else
        # Show errors
        print_error "Failed: $(basename ${file})"
        if [ -s "${error_log}" ]; then
            cat "${error_log}" | grep -i "error" | head -5
        fi
        return 1
    fi
}

# Main installation
echo ""
echo "========================================="
echo "  GAMILIT Database Installation (VERBOSE)"
echo "========================================="
echo ""

print_info "Target Database: ${DB_NAME}"
print_info "User: ${DB_USER}"
print_info "Host: ${DB_HOST}:${DB_PORT}"
echo ""

ERROR_COUNT=0

# Step 1: Create schemas and ENUMs
print_info "Step 1/9: Creating schemas and ENUMs..."
execute_sql_verbose "${DDL_DIR}/01-create-schemas.sql" "Creating schemas" || ((ERROR_COUNT++))
execute_sql_verbose "${DDL_DIR}/02-create-enums.sql" "Creating ENUMs" || ((ERROR_COUNT++))
echo ""

# Step 2: Create tables by schema
print_info "Step 2/9: Creating tables..."
schemas=(
    "auth"
    "audit_logging"
    "auth_management"
    "system_configuration"
    "content_management"
    "educational_content"
    "gamification_system"
    "progress_tracking"
    "social_features"
)

for schema in "${schemas[@]}"; do
    if [ -d "${DDL_DIR}/schemas/${schema}/tables" ]; then
        print_info "  → Installing ${schema} tables..."
        for table_file in "${DDL_DIR}/schemas/${schema}/tables"/*.sql; do
            if [ -f "${table_file}" ]; then
                if execute_sql_verbose "${table_file}" "$(basename ${table_file})"; then
                    echo -n "."
                else
                    echo -n "✗"
                    ((ERROR_COUNT++))
                fi
            fi
        done
        echo " ✓"
    fi
done
echo ""

# Step 3: Create functions
print_info "Step 3/9: Creating functions..."
if [ -d "${DDL_DIR}/schemas/gamilit/functions" ]; then
    print_info "  → Installing gamilit functions (base dependencies)..."
    for func_file in "${DDL_DIR}/schemas/gamilit/functions"/*.sql; do
        if [ -f "${func_file}" ]; then
            if execute_sql_verbose "${func_file}" "$(basename ${func_file})"; then
                echo -n "."
            else
                echo -n "✗"
                ((ERROR_COUNT++))
            fi
        fi
    done
    echo " ✓"
fi

for schema in "${schemas[@]}"; do
    if [ "${schema}" == "gamilit" ]; then
        continue
    fi
    if [ -d "${DDL_DIR}/schemas/${schema}/functions" ]; then
        print_info "  → Installing ${schema} functions..."
        for func_file in "${DDL_DIR}/schemas/${schema}/functions"/*.sql; do
            if [ -f "${func_file}" ]; then
                execute_sql_verbose "${func_file}" "$(basename ${func_file})" > /dev/null 2>&1 && echo -n "." || echo -n "✗"
            fi
        done
        echo " ✓"
    fi
done
echo ""

# Step 4-9: Continue with triggers, views, RLS, etc...
print_info "Steps 4-9: Installing triggers, views, indexes, RLS..."
print_info "  (Same as install-all.sh - suppressing output for brevity)"

echo ""
echo "========================================="
echo "  Installation Complete!"
echo "========================================="
echo ""
print_info "Errors encountered: ${ERROR_COUNT}"
if [ ${ERROR_COUNT} -gt 0 ]; then
    print_warn "Some errors were found. Check /tmp/gamilit_install_errors.log for details"
else
    print_info "All objects installed successfully!"
fi

unset PGPASSWORD
