#!/bin/bash

# =====================================================
# Complete Database Installation Script
# Description: Installs all schemas, tables, functions, triggers, views, and RLS
# Created: 2025-10-27
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

# Function to execute SQL file
execute_sql() {
    local file=$1
    local description=$2

    if [ ! -f "${file}" ]; then
        print_warn "File not found: ${file}, skipping..."
        return
    fi

    print_info "${description}"
    psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f "${file}" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        print_info "✓ Success"
    else
        print_error "✗ Failed"
        exit 1
    fi
}

# Main installation
echo ""
echo "========================================="
echo "  GAMILIT Database Installation"
echo "========================================="
echo ""

print_info "Target Database: ${DB_NAME}"
print_info "User: ${DB_USER}"
print_info "Host: ${DB_HOST}:${DB_PORT}"
echo ""

# Step 1: Create schemas and ENUMs
print_info "Step 1/9: Creating schemas and ENUMs..."
execute_sql "${DDL_DIR}/01-create-schemas.sql" "  → Creating schemas"
execute_sql "${DDL_DIR}/02-create-enums.sql" "  → Creating ENUMs"
echo ""

# Step 2: Create tables by schema (respecting dependencies)
print_info "Step 2/9: Creating tables..."

# Order matters for FK dependencies!
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
                filename=$(basename "${table_file}")
                psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f "${table_file}" > /dev/null 2>&1
                echo -n "."
            fi
        done
        echo " ✓"
    fi
done
echo ""

# Step 3: Create functions (respecting dependencies)
print_info "Step 3/9: Creating functions..."

# First: Install gamilit schema functions (base dependencies for all other functions)
if [ -d "${DDL_DIR}/schemas/gamilit/functions" ]; then
    print_info "  → Installing gamilit functions (base dependencies)..."
    for func_file in "${DDL_DIR}/schemas/gamilit/functions"/*.sql; do
        if [ -f "${func_file}" ]; then
            psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f "${func_file}" > /dev/null 2>&1
            echo -n "."
        fi
    done
    echo " ✓"
fi

# Second: Install audit_logging functions (needed by other schemas)
if [ -d "${DDL_DIR}/schemas/audit_logging/functions" ]; then
    print_info "  → Installing audit_logging functions (audit dependencies)..."
    for func_file in "${DDL_DIR}/schemas/audit_logging/functions"/*.sql; do
        if [ -f "${func_file}" ]; then
            psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f "${func_file}" > /dev/null 2>&1
            echo -n "."
        fi
    done
    echo " ✓"
fi

# Third: Install remaining schema functions
for schema in "${schemas[@]}"; do
    # Skip gamilit and audit_logging (already installed)
    if [ "${schema}" == "gamilit" ] || [ "${schema}" == "audit_logging" ]; then
        continue
    fi

    if [ -d "${DDL_DIR}/schemas/${schema}/functions" ]; then
        print_info "  → Installing ${schema} functions..."
        for func_file in "${DDL_DIR}/schemas/${schema}/functions"/*.sql; do
            if [ -f "${func_file}" ]; then
                psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f "${func_file}" > /dev/null 2>&1
                echo -n "."
            fi
        done
        echo " ✓"
    fi
done
echo ""

# Step 4: Create triggers
print_info "Step 4/9: Creating triggers..."
for schema in "${schemas[@]}"; do
    if [ -d "${DDL_DIR}/schemas/${schema}/triggers" ]; then
        print_info "  → Installing ${schema} triggers..."
        for trigger_file in "${DDL_DIR}/schemas/${schema}/triggers"/*.sql; do
            if [ -f "${trigger_file}" ]; then
                psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f "${trigger_file}" > /dev/null 2>&1
                echo -n "."
            fi
        done
        echo " ✓"
    fi
done
echo ""

# Step 5: Create views
print_info "Step 5/9: Creating views..."
for schema in "${schemas[@]}"; do
    if [ -d "${DDL_DIR}/schemas/${schema}/views" ]; then
        print_info "  → Installing ${schema} views..."
        for view_file in "${DDL_DIR}/schemas/${schema}/views"/*.sql; do
            if [ -f "${view_file}" ]; then
                psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f "${view_file}" > /dev/null 2>&1
                echo -n "."
            fi
        done
        echo " ✓"
    fi
done
echo ""

# Step 6: Create indexes
print_info "Step 6/9: Creating indexes..."

# Standard B-tree indexes are created with tables
# Here we create specialized GIN indexes for JSONB and array columns
execute_sql "${DDL_DIR}/missing-objects/01-create-gin-indexes.sql" "  → Creating GIN indexes for JSONB/array optimization"
echo ""

# Step 7: Enable RLS and create policies
print_info "Step 7/9: Configuring Row Level Security..."
for schema in "${schemas[@]}"; do
    if [ -d "${DDL_DIR}/schemas/${schema}/rls-policies" ]; then
        print_info "  → Configuring RLS for ${schema}..."

        # Enable RLS
        if [ -f "${DDL_DIR}/schemas/${schema}/rls-policies/01-enable-rls.sql" ]; then
            psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f "${DDL_DIR}/schemas/${schema}/rls-policies/01-enable-rls.sql" > /dev/null 2>&1
        fi

        # Create policies
        if [ -f "${DDL_DIR}/schemas/${schema}/rls-policies/02-policies.sql" ]; then
            psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f "${DDL_DIR}/schemas/${schema}/rls-policies/02-policies.sql" > /dev/null 2>&1
        fi

        echo " ✓"
    fi
done

# Install additional critical RLS policies
execute_sql "${DDL_DIR}/schemas/auth_management/rls-policies/04-user_roles-rls.sql" "  → Enabling RLS on user_roles"
execute_sql "${DDL_DIR}/schemas/auth_management/rls-policies/05-tenants-rls.sql" "  → Enabling RLS on tenants"
echo ""

# Step 8: Grant permissions
print_info "Step 8/9: Granting permissions..."
for schema in "${schemas[@]}"; do
    if [ -f "${DDL_DIR}/schemas/${schema}/rls-policies/03-grants.sql" ]; then
        print_info "  → Granting permissions for ${schema}..."
        psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f "${DDL_DIR}/schemas/${schema}/rls-policies/03-grants.sql" > /dev/null 2>&1
        echo " ✓"
    fi
done
echo ""

# Step 8: Verification
print_info "Step 8/8: Verifying installation..."

# Count schemas
schema_count=$(psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -tAc "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast');")
print_info "  → Schemas created: ${schema_count}"

# Count tables
table_count=$(psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -tAc "SELECT COUNT(*) FROM pg_tables WHERE schemaname NOT IN ('pg_catalog', 'information_schema');")
print_info "  → Tables created: ${table_count}"

# Count functions
function_count=$(psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -tAc "SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname NOT IN ('pg_catalog', 'information_schema');")
print_info "  → Functions created: ${function_count}"

# Count triggers
trigger_count=$(psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -tAc "SELECT COUNT(*) FROM pg_trigger t JOIN pg_class c ON t.tgrelid = c.oid JOIN pg_namespace n ON c.relnamespace = n.oid WHERE NOT t.tgisinternal AND n.nspname NOT IN ('pg_catalog', 'information_schema');")
print_info "  → Triggers created: ${trigger_count}"

# Count RLS policies
policy_count=$(psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -tAc "SELECT COUNT(*) FROM pg_policies WHERE schemaname NOT IN ('pg_catalog', 'information_schema');")
print_info "  → RLS policies created: ${policy_count}"

echo ""
echo "========================================="
echo "  Installation Complete!"
echo "========================================="
echo ""
print_info "Database ${DB_NAME} is ready to use"
print_info "Next step: Load seed data (if needed)"
echo ""

unset PGPASSWORD
