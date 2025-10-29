#!/bin/bash

# ============================================================================
# Script: apply_enum_fix.sh
# Description: Apply ENUM critical fixes migration
# Usage: ./apply_enum_fix.sh [OPTIONS]
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DB_NAME="${DB_NAME:-gamilit_platform}"
DB_USER="${DB_USER:-gamilit_user}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
VALIDATE_ONLY=false
ROLLBACK=false

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATABASE_DIR="$(dirname "$SCRIPT_DIR")"

# ============================================================================
# Functions
# ============================================================================

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
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
    echo -e "${BLUE}→ $1${NC}"
}

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Apply ENUM critical fixes migration to GLIT database

OPTIONS:
    -h, --help              Show this help message
    -d, --database NAME     Database name (default: gamilit_db)
    -U, --user USER         Database user (default: postgres)
    -H, --host HOST         Database host (default: localhost)
    -p, --port PORT         Database port (default: 5432)
    -v, --validate          Only validate ENUMs (no migration)
    -r, --rollback          Rollback migration (revert changes)

EXAMPLES:
    # Apply migration
    $0

    # Apply migration to specific database
    $0 -d my_database -U myuser

    # Validate only
    $0 --validate

    # Rollback migration
    $0 --rollback

ENVIRONMENT VARIABLES:
    DB_NAME                 Database name
    DB_USER                 Database user
    DB_HOST                 Database host
    DB_PORT                 Database port
    PGPASSWORD              Database password

EOF
}

check_psql() {
    if ! command -v psql &> /dev/null; then
        print_error "psql not found. Please install PostgreSQL client."
        exit 1
    fi
}

check_connection() {
    print_info "Checking database connection..."
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" > /dev/null 2>&1; then
        print_success "Database connection successful"
        return 0
    else
        print_error "Cannot connect to database"
        echo "  Database: $DB_NAME"
        echo "  User: $DB_USER"
        echo "  Host: $DB_HOST"
        echo "  Port: $DB_PORT"
        exit 1
    fi
}

validate_enums() {
    print_header "VALIDATING ENUMS"
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SCRIPT_DIR/validate_enums.sql"
}

apply_migration() {
    print_header "APPLYING ENUM FIX MIGRATION"

    print_info "Running migration script..."
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SCRIPT_DIR/00_fix_enums_critical.sql"

    if [ $? -eq 0 ]; then
        print_success "Migration applied successfully"
        echo ""
        validate_enums
    else
        print_error "Migration failed"
        exit 1
    fi
}

rollback_migration() {
    print_header "ROLLING BACK ENUM FIX MIGRATION"

    print_warning "This will revert all ENUM changes"
    print_warning "WARNING: This will CASCADE to dependent tables!"
    echo ""
    read -p "Are you sure you want to continue? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        print_info "Rollback cancelled"
        exit 0
    fi

    print_info "Running rollback script..."
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SCRIPT_DIR/00_fix_enums_critical_DOWN.sql"

    if [ $? -eq 0 ]; then
        print_success "Rollback completed successfully"
        echo ""
        validate_enums
    else
        print_error "Rollback failed"
        exit 1
    fi
}

# ============================================================================
# Parse arguments
# ============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--database)
            DB_NAME="$2"
            shift 2
            ;;
        -U|--user)
            DB_USER="$2"
            shift 2
            ;;
        -H|--host)
            DB_HOST="$2"
            shift 2
            ;;
        -p|--port)
            DB_PORT="$2"
            shift 2
            ;;
        -v|--validate)
            VALIDATE_ONLY=true
            shift
            ;;
        -r|--rollback)
            ROLLBACK=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# Main execution
# ============================================================================

print_header "GLIT DATABASE - ENUM FIX MIGRATION"
echo ""
echo "Database Configuration:"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo ""

check_psql
check_connection

echo ""

if [ "$VALIDATE_ONLY" = true ]; then
    validate_enums
elif [ "$ROLLBACK" = true ]; then
    rollback_migration
else
    apply_migration
fi

echo ""
print_success "Operation completed successfully"
echo ""
