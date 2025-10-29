#!/bin/bash

##############################################################################
# GAMILIT Platform - Database Setup Script
#
# This script sets up the complete GLIT database:
# - Creates database if not exists
# - Creates database user
# - Executes all DDL scripts in correct order
# - Validates installation
# - Optionally loads seed data
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
DDL_DIR="/home/isem/workspace/workspace-gamilit/docs/03-desarrollo/base-de-datos/backup-ddl/gamilit_platform"

# Database configuration
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-gamilit_platform}"
DB_USER="${DB_USER:-gamilit_user}"
DB_PASSWORD="${DB_PASSWORD:-glit_password}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"

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
        print_success "Loaded environment variables from .env"
    else
        print_warning "Using default database configuration"
    fi
}

##############################################################################
# Check PostgreSQL Connection
##############################################################################

check_postgres_connection() {
    print_header "Checking PostgreSQL Connection"

    if ! command -v psql &> /dev/null; then
        print_error "PostgreSQL client (psql) not found"
        print_info "Install it with: sudo apt-get install postgresql-client"
        exit 1
    fi

    # Test connection to PostgreSQL (using postgres user)
    if PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -U "${POSTGRES_USER}" -c "SELECT 1" &> /dev/null; then
        print_success "Connected to PostgreSQL server"
    else
        print_error "Cannot connect to PostgreSQL server"
        print_info "Trying with sudo and local connection..."

        # Try local connection with sudo
        if echo "SELECT 1" | sudo -u postgres psql -t &> /dev/null; then
            print_success "Connected via local socket"
            POSTGRES_USER="postgres"
            USE_SUDO=true
        else
            print_error "Cannot connect to PostgreSQL"
            exit 1
        fi
    fi
}

##############################################################################
# Create Database and User
##############################################################################

create_database_and_user() {
    print_header "Creating Database and User"

    # Function to execute SQL as postgres user
    execute_sql() {
        local sql="$1"
        if [ "$USE_SUDO" = true ]; then
            echo "$sql" | sudo -u postgres psql
        else
            PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -U "${POSTGRES_USER}" -c "$sql"
        fi
    }

    # Check if user exists
    if [ "$USE_SUDO" = true ]; then
        user_exists=$(echo "SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}'" | sudo -u postgres psql -t | xargs)
    else
        user_exists=$(PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -U "${POSTGRES_USER}" -t -c "SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}'" | xargs)
    fi

    if [ -z "$user_exists" ]; then
        print_info "Creating database user '${DB_USER}'..."
        execute_sql "CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';"
        print_success "User created"
    else
        print_info "User '${DB_USER}' already exists"
    fi

    # Check if database exists
    if [ "$USE_SUDO" = true ]; then
        db_exists=$(echo "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'" | sudo -u postgres psql -t | xargs)
    else
        db_exists=$(PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -U "${POSTGRES_USER}" -t -c "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'" | xargs)
    fi

    if [ -z "$db_exists" ]; then
        print_info "Creating database '${DB_NAME}'..."
        execute_sql "CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};"
        print_success "Database created"
    else
        print_info "Database '${DB_NAME}' already exists"
    fi

    # Grant privileges
    execute_sql "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};"
    print_success "Privileges granted"
}

##############################################################################
# Execute DDL Scripts
##############################################################################

execute_ddl_scripts() {
    print_header "Executing DDL Scripts"

    if [ ! -d "$DDL_DIR" ]; then
        print_error "DDL directory not found: $DDL_DIR"
        exit 1
    fi

    # DDL files in execution order
    local ddl_files=(
        "01-schemas.sql"
        "02-types.sql"
        "03-tables.sql"
        "04-functions.sql"
        "05-triggers.sql"
        "06-indexes.sql"
        "07-rls-policies.sql"
        "08-views.sql"
        "09-sequences.sql"
    )

    local success_count=0
    local error_count=0

    for ddl_file in "${ddl_files[@]}"; do
        local file_path="$DDL_DIR/$ddl_file"

        if [ -f "$file_path" ]; then
            print_info "Executing $ddl_file..."

            # Check if file is empty
            if [ ! -s "$file_path" ]; then
                print_warning "$ddl_file is empty, skipping..."
                continue
            fi

            # Execute the DDL file
            if PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -f "$file_path" &> /tmp/ddl_output.log; then
                print_success "$ddl_file executed successfully"
                ((success_count++))
            else
                print_error "$ddl_file failed"
                print_info "Error details:"
                tail -20 /tmp/ddl_output.log | sed 's/^/  /'
                ((error_count++))

                # Ask if we should continue
                read -p "Continue with remaining scripts? (y/n): " continue_execution
                if [ "$continue_execution" != "y" ] && [ "$continue_execution" != "Y" ]; then
                    exit 1
                fi
            fi
        else
            print_warning "$ddl_file not found, skipping..."
        fi
    done

    echo ""
    print_info "Execution Summary:"
    echo -e "  Success: ${GREEN}$success_count${NC}"
    echo -e "  Errors:  ${RED}$error_count${NC}"

    if [ $error_count -eq 0 ]; then
        print_success "All DDL scripts executed successfully!"
    else
        print_warning "Some scripts failed. Please review the errors above."
    fi
}

##############################################################################
# Validate Installation
##############################################################################

validate_installation() {
    print_header "Validating Database Installation"

    local validation_errors=0

    # Count schemas
    schema_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')" 2>/dev/null | xargs)
    if [ "$schema_count" -gt 0 ]; then
        print_success "Schemas: $schema_count found"
    else
        print_error "No custom schemas found"
        ((validation_errors++))
    fi

    # Count tables
    table_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema')" 2>/dev/null | xargs)
    if [ "$table_count" -gt 0 ]; then
        print_success "Tables: $table_count found"
    else
        print_warning "No tables found"
    fi

    # Count functions
    function_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema NOT IN ('pg_catalog', 'information_schema')" 2>/dev/null | xargs)
    if [ "$function_count" -gt 0 ]; then
        print_success "Functions: $function_count found"
    else
        print_warning "No functions found"
    fi

    # Count indexes
    index_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "SELECT COUNT(*) FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')" 2>/dev/null | xargs)
    if [ "$index_count" -gt 0 ]; then
        print_success "Indexes: $index_count found"
    else
        print_warning "No indexes found"
    fi

    # Test basic query
    if PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -c "SELECT 1" &> /dev/null; then
        print_success "Database is accessible and functional"
    else
        print_error "Cannot query database"
        ((validation_errors++))
    fi

    if [ $validation_errors -eq 0 ]; then
        print_success "Database validation passed!"
    else
        print_error "Database validation failed with $validation_errors errors"
        return 1
    fi
}

##############################################################################
# Display Summary
##############################################################################

show_summary() {
    print_header "Database Setup Complete!"

    echo -e "${GREEN}✓ Database setup completed successfully!${NC}\n"

    echo -e "${BLUE}Database Information:${NC}"
    echo -e "  Host:     ${DB_HOST}:${DB_PORT}"
    echo -e "  Database: ${DB_NAME}"
    echo -e "  User:     ${DB_USER}"
    echo ""

    echo -e "${BLUE}Next Steps:${NC}"
    echo -e "  1. Validate database: ./scripts/db-validate.sh"
    echo -e "  2. Start development: ./scripts/dev-start.sh"
    echo ""

    echo -e "${BLUE}Connection String:${NC}"
    echo -e "  postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
    echo ""
}

##############################################################################
# Main
##############################################################################

show_help() {
    echo "GAMILIT Platform Database Setup Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --drop-existing   Drop existing database before setup (DESTRUCTIVE!)"
    echo "  --skip-validate   Skip validation after setup"
    echo "  --help            Show this help message"
    echo ""
}

main() {
    local drop_existing=false
    local skip_validate=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --drop-existing)
                drop_existing=true
                shift
                ;;
            --skip-validate)
                skip_validate=true
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

    print_header "GAMILIT Platform Database Setup"

    load_env
    check_postgres_connection

    if [ "$drop_existing" = true ]; then
        print_warning "Dropping existing database..."
        read -p "Are you sure? This will delete all data! (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            if [ "$USE_SUDO" = true ]; then
                echo "DROP DATABASE IF EXISTS ${DB_NAME};" | sudo -u postgres psql
            else
                PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -U "${POSTGRES_USER}" -c "DROP DATABASE IF EXISTS ${DB_NAME};"
            fi
            print_success "Database dropped"
        else
            print_info "Skipping drop"
        fi
    fi

    create_database_and_user
    execute_ddl_scripts

    if [ "$skip_validate" = false ]; then
        validate_installation
    fi

    show_summary
}

# Run main function
main "$@"
