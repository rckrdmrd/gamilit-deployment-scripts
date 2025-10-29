#!/bin/bash

##############################################################################
# GAMILIT Platform - Database Validation Script
#
# This script validates the GLIT database installation:
# - Checks database connectivity
# - Counts schemas, tables, functions, indexes
# - Validates RLS policies
# - Tests basic queries
# - Generates detailed report
##############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Database configuration
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-gamilit_platform}"
DB_USER="${DB_USER:-gamilit_user}"
DB_PASSWORD="${DB_PASSWORD:-glit_password}"

##############################################################################
# Helper Functions
##############################################################################

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
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
    echo -e "${BLUE}ℹ $1${NC}"
}

##############################################################################
# Load Environment
##############################################################################

load_env() {
    if [ -f "$PROJECT_ROOT/.env" ]; then
        export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)
    fi
}

##############################################################################
# Check Database Connection
##############################################################################

check_connection() {
    print_header "Database Connection Check"

    if PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -c "SELECT 1" &> /dev/null; then
        print_success "Connected to database successfully"
        echo -e "  Host: ${DB_HOST}:${DB_PORT}"
        echo -e "  Database: ${DB_NAME}"
        echo -e "  User: ${DB_USER}"
        return 0
    else
        print_error "Cannot connect to database"
        return 1
    fi
}

##############################################################################
# Validate Schemas
##############################################################################

validate_schemas() {
    print_header "Schema Validation"

    # Get all custom schemas
    schemas=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT schema_name
        FROM information_schema.schemata
        WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
        ORDER BY schema_name
    " 2>/dev/null)

    if [ -n "$schemas" ]; then
        schema_count=$(echo "$schemas" | wc -l)
        print_success "Found $schema_count custom schema(s)"
        echo "$schemas" | sed 's/^/  - /'
    else
        print_warning "No custom schemas found"
    fi
}

##############################################################################
# Validate Tables
##############################################################################

validate_tables() {
    print_header "Table Validation"

    # Count tables by schema
    table_info=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT
            table_schema,
            COUNT(*) as table_count
        FROM information_schema.tables
        WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
        AND table_type = 'BASE TABLE'
        GROUP BY table_schema
        ORDER BY table_schema
    " 2>/dev/null)

    if [ -n "$table_info" ]; then
        total_tables=$(echo "$table_info" | awk '{sum += $2} END {print sum}')
        print_success "Found $total_tables table(s)"
        echo "$table_info" | while read schema count; do
            echo -e "  ${schema}: ${count} tables"
        done
    else
        print_warning "No tables found"
    fi
}

##############################################################################
# Validate Functions
##############################################################################

validate_functions() {
    print_header "Function Validation"

    # Count functions by schema
    function_info=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT
            routine_schema,
            COUNT(*) as function_count
        FROM information_schema.routines
        WHERE routine_schema NOT IN ('pg_catalog', 'information_schema')
        GROUP BY routine_schema
        ORDER BY routine_schema
    " 2>/dev/null)

    if [ -n "$function_info" ]; then
        total_functions=$(echo "$function_info" | awk '{sum += $2} END {print sum}')
        print_success "Found $total_functions function(s)"
        echo "$function_info" | while read schema count; do
            echo -e "  ${schema}: ${count} functions"
        done
    else
        print_warning "No functions found"
    fi
}

##############################################################################
# Validate Indexes
##############################################################################

validate_indexes() {
    print_header "Index Validation"

    # Count indexes by schema
    index_info=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT
            schemaname,
            COUNT(*) as index_count
        FROM pg_indexes
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
        GROUP BY schemaname
        ORDER BY schemaname
    " 2>/dev/null)

    if [ -n "$index_info" ]; then
        total_indexes=$(echo "$index_info" | awk '{sum += $2} END {print sum}')
        print_success "Found $total_indexes index(es)"
        echo "$index_info" | while read schema count; do
            echo -e "  ${schema}: ${count} indexes"
        done
    else
        print_warning "No indexes found"
    fi
}

##############################################################################
# Validate RLS Policies
##############################################################################

validate_rls_policies() {
    print_header "Row Level Security (RLS) Validation"

    # Count RLS policies
    rls_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT COUNT(*)
        FROM pg_policies
    " 2>/dev/null | xargs)

    if [ "$rls_count" -gt 0 ]; then
        print_success "Found $rls_count RLS policy/policies"

        # Show tables with RLS enabled
        rls_tables=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
            SELECT DISTINCT tablename
            FROM pg_policies
            ORDER BY tablename
        " 2>/dev/null)

        if [ -n "$rls_tables" ]; then
            echo -e "  Tables with RLS:"
            echo "$rls_tables" | sed 's/^/    - /'
        fi
    else
        print_warning "No RLS policies found"
    fi
}

##############################################################################
# Validate Types
##############################################################################

validate_types() {
    print_header "Custom Type Validation"

    # Count custom types
    type_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT COUNT(*)
        FROM pg_type t
        JOIN pg_namespace n ON t.typnamespace = n.oid
        WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
        AND t.typtype = 'e'
    " 2>/dev/null | xargs)

    if [ "$type_count" -gt 0 ]; then
        print_success "Found $type_count custom type(s)"
    else
        print_warning "No custom types found"
    fi
}

##############################################################################
# Validate Triggers
##############################################################################

validate_triggers() {
    print_header "Trigger Validation"

    # Count triggers
    trigger_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT COUNT(*)
        FROM information_schema.triggers
        WHERE trigger_schema NOT IN ('pg_catalog', 'information_schema')
    " 2>/dev/null | xargs)

    if [ "$trigger_count" -gt 0 ]; then
        print_success "Found $trigger_count trigger(s)"
    else
        print_warning "No triggers found"
    fi
}

##############################################################################
# Test Basic Queries
##############################################################################

test_queries() {
    print_header "Query Testing"

    local test_passed=0
    local test_failed=0

    # Test 1: SELECT current database
    if PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "SELECT current_database()" &> /dev/null; then
        print_success "Query test 1: SELECT current_database() - PASSED"
        ((test_passed++))
    else
        print_error "Query test 1: SELECT current_database() - FAILED"
        ((test_failed++))
    fi

    # Test 2: SELECT version
    if PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "SELECT version()" &> /dev/null; then
        print_success "Query test 2: SELECT version() - PASSED"
        ((test_passed++))
    else
        print_error "Query test 2: SELECT version() - FAILED"
        ((test_failed++))
    fi

    # Test 3: SELECT now()
    if PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "SELECT now()" &> /dev/null; then
        print_success "Query test 3: SELECT now() - PASSED"
        ((test_passed++))
    else
        print_error "Query test 3: SELECT now() - FAILED"
        ((test_failed++))
    fi

    echo ""
    print_info "Query Test Summary: ${test_passed} passed, ${test_failed} failed"
}

##############################################################################
# Generate Summary Report
##############################################################################

generate_summary() {
    print_header "Validation Summary"

    # Get statistics
    local schema_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT COUNT(*) FROM information_schema.schemata
        WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
    " 2>/dev/null | xargs)

    local table_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT COUNT(*) FROM information_schema.tables
        WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
        AND table_type = 'BASE TABLE'
    " 2>/dev/null | xargs)

    local function_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT COUNT(*) FROM information_schema.routines
        WHERE routine_schema NOT IN ('pg_catalog', 'information_schema')
    " 2>/dev/null | xargs)

    local index_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT COUNT(*) FROM pg_indexes
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
    " 2>/dev/null | xargs)

    local rls_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT COUNT(*) FROM pg_policies
    " 2>/dev/null | xargs)

    local trigger_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT COUNT(*) FROM information_schema.triggers
        WHERE trigger_schema NOT IN ('pg_catalog', 'information_schema')
    " 2>/dev/null | xargs)

    echo -e "${BLUE}Database Statistics:${NC}"
    echo -e "  Schemas:   ${GREEN}$schema_count${NC}"
    echo -e "  Tables:    ${GREEN}$table_count${NC}"
    echo -e "  Functions: ${GREEN}$function_count${NC}"
    echo -e "  Indexes:   ${GREEN}$index_count${NC}"
    echo -e "  RLS Policies: ${GREEN}$rls_count${NC}"
    echo -e "  Triggers:  ${GREEN}$trigger_count${NC}"

    # Get database size
    db_size=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "
        SELECT pg_size_pretty(pg_database_size('${DB_NAME}'))
    " 2>/dev/null | xargs)

    echo -e "  Database Size: ${GREEN}$db_size${NC}"

    echo ""
    print_success "Database validation completed!"
}

##############################################################################
# Main
##############################################################################

show_help() {
    echo "GAMILIT Platform Database Validation Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --detailed        Show detailed validation information"
    echo "  --help            Show this help message"
    echo ""
}

main() {
    local detailed=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --detailed)
                detailed=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    print_header "GAMILIT Platform Database Validation"

    load_env

    # Run validations
    if ! check_connection; then
        exit 1
    fi

    validate_schemas
    validate_tables
    validate_functions
    validate_indexes
    validate_rls_policies
    validate_types
    validate_triggers
    test_queries
    generate_summary
}

# Run main function
main "$@"
