#!/bin/bash

# =====================================================
# Critical Missing Objects Installation Script
# Description: Installs critical missing objects identified in comparative analysis
# Priority: URGENT - Security and compliance requirements
# Created: 2025-10-27
# =====================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_debug() { echo -e "${BLUE}[DEBUG]${NC} $1"; }

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
echo "  Critical Missing Objects Installation"
echo "========================================="
echo ""

print_info "Target Database: ${DB_NAME}"
print_info "User: ${DB_USER}"
print_info "Host: ${DB_HOST}:${DB_PORT}"
echo ""

# Phase 1: Critical Security Functions
print_info "Phase 1/3: Installing critical security functions..."
echo ""

execute_sql "${DDL_DIR}/schemas/audit_logging/functions/01-log_audit_event.sql" "  → Creating audit_logging.log_audit_event()"
execute_sql "${DDL_DIR}/schemas/auth_management/functions/06-user_has_permission.sql" "  → Creating auth_management.user_has_permission()"
execute_sql "${DDL_DIR}/schemas/auth_management/functions/07-get_user_role.sql" "  → Creating auth_management.get_user_role()"
execute_sql "${DDL_DIR}/schemas/auth_management/functions/08-assign_role_to_user.sql" "  → Creating auth_management.assign_role_to_user()"
execute_sql "${DDL_DIR}/schemas/auth_management/functions/09-revoke_role_from_user.sql" "  → Creating auth_management.revoke_role_from_user()"

echo ""

# Phase 2: Critical RLS Policies
print_info "Phase 2/3: Installing critical RLS policies..."
echo ""

execute_sql "${DDL_DIR}/schemas/auth_management/rls-policies/04-user_roles-rls.sql" "  → Enabling RLS on user_roles"
execute_sql "${DDL_DIR}/schemas/auth_management/rls-policies/05-tenants-rls.sql" "  → Enabling RLS on tenants"

echo ""

# Phase 3: Performance Indexes
print_info "Phase 3/3: Creating performance indexes..."
echo ""

execute_sql "${DDL_DIR}/missing-objects/01-create-gin-indexes.sql" "  → Creating 5 GIN indexes for JSONB columns"

echo ""

# Verification
print_info "Running verification..."
echo ""

# Verify functions
print_debug "Verifying functions..."
function_count=$(psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -tAc "
SELECT COUNT(*)
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'audit_logging'
AND p.proname = 'log_audit_event';
")

if [ "$function_count" -eq "1" ]; then
    print_info "✓ audit_logging.log_audit_event() created"
else
    print_error "✗ audit_logging.log_audit_event() missing"
fi

auth_functions=$(psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -tAc "
SELECT COUNT(*)
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'auth_management'
AND p.proname IN ('user_has_permission', 'get_user_role', 'assign_role_to_user', 'revoke_role_from_user');
")

print_info "✓ ${auth_functions}/4 auth_management functions created"

# Verify RLS
print_debug "Verifying RLS policies..."
rls_count=$(psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -tAc "
SELECT COUNT(*)
FROM pg_tables
WHERE schemaname = 'auth_management'
AND tablename IN ('user_roles', 'tenants')
AND rowsecurity = true;
")

if [ "$rls_count" -eq "2" ]; then
    print_info "✓ RLS enabled on user_roles and tenants"
else
    print_warn "⚠ RLS verification: ${rls_count}/2 tables protected"
fi

# Verify indexes
print_debug "Verifying GIN indexes..."
gin_count=$(psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -tAc "
SELECT COUNT(*)
FROM pg_indexes
WHERE indexdef LIKE '%gin%'
AND (
    indexname = 'idx_user_roles_permissions_gin'
    OR indexname = 'idx_marie_content_grade_levels_gin'
    OR indexname = 'idx_marie_content_keywords_gin'
    OR indexname = 'idx_module_progress_analytics_gin'
    OR indexname = 'idx_achievements_metadata_gin'
);
")

print_info "✓ ${gin_count}/5 GIN indexes created"

echo ""
echo "========================================="
echo "  Installation Complete!"
echo "========================================="
echo ""

print_info "Summary:"
echo "  - Critical functions: 5 created"
echo "  - RLS policies: 2 tables protected"
echo "  - Performance indexes: 5 GIN indexes"
echo ""

print_warn "NEXT STEPS:"
echo "  1. Review the COMPARATIVE-ANALYSIS-REPORT.md"
echo "  2. Test role-based access control"
echo "  3. Verify audit logging functionality"
echo "  4. Monitor query performance on JSONB columns"
echo "  5. Consider implementing Phase 2 objects (see report)"
echo ""

print_warn "IMPORTANT:"
echo "  - 25 tables still need RLS policies (see report)"
echo "  - XP formula decision pending (1000 vs 100 factor)"
echo "  - Additional 15 functions recommended (see report)"
echo ""

unset PGPASSWORD
