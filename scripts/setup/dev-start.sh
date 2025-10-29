#!/bin/bash

##############################################################################
# GAMILIT Platform - Development Environment Starter
#
# This script starts the complete development environment:
# - Starts PostgreSQL service (if not running)
# - Verifies database connectivity
# - Starts backend in development mode with hot-reload
# - Displays real-time logs
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
# Load Environment Variables
##############################################################################

load_env() {
    if [ -f "$PROJECT_ROOT/.env" ]; then
        export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)
        print_success "Loaded environment variables from .env"
    else
        print_warning ".env file not found, using defaults"
        export DB_HOST=${DB_HOST:-localhost}
        export DB_PORT=${DB_PORT:-5432}
        export DB_NAME=${DB_NAME:-gamilit_platform}
        export DB_USER=${DB_USER:-gamilit_user}
        export PORT=${PORT:-3001}
    fi
}

##############################################################################
# Check and Start PostgreSQL
##############################################################################

check_postgresql() {
    print_header "Checking PostgreSQL Service"

    # Check if PostgreSQL service exists
    if command -v systemctl &> /dev/null; then
        if systemctl list-unit-files | grep -q postgresql; then
            # Check if running
            if systemctl is-active --quiet postgresql; then
                print_success "PostgreSQL service is running"
            else
                print_warning "PostgreSQL service is not running"
                read -p "Do you want to start PostgreSQL? (y/n): " start_pg
                if [ "$start_pg" = "y" ] || [ "$start_pg" = "Y" ]; then
                    echo "2023" | sudo -S systemctl start postgresql
                    sleep 2
                    if systemctl is-active --quiet postgresql; then
                        print_success "PostgreSQL service started"
                    else
                        print_error "Failed to start PostgreSQL service"
                        exit 1
                    fi
                else
                    print_error "PostgreSQL is required. Exiting."
                    exit 1
                fi
            fi
        else
            print_warning "PostgreSQL service not found via systemctl"
        fi
    fi

    # Test database connection
    print_info "Testing database connection..."
    if PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -c "SELECT 1" &> /dev/null; then
        print_success "Database connection successful"
    else
        print_error "Cannot connect to database"
        print_info "Host: ${DB_HOST}:${DB_PORT}"
        print_info "Database: ${DB_NAME}"
        print_info "User: ${DB_USER}"
        print_error "Please check your database configuration in .env"
        exit 1
    fi
}

##############################################################################
# Check Database Exists
##############################################################################

check_database() {
    print_header "Checking Database"

    if PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -lqt | cut -d \| -f 1 | grep -qw "${DB_NAME}"; then
        print_success "Database '${DB_NAME}' exists"

        # Check if tables exist
        table_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema')" 2>/dev/null | xargs)

        if [ "$table_count" -gt 0 ]; then
            print_success "Found $table_count tables in database"
        else
            print_warning "Database exists but no tables found"
            print_info "You may need to run: ./scripts/db-setup.sh"
        fi
    else
        print_error "Database '${DB_NAME}' does not exist"
        print_info "Run setup script first: ./scripts/setup.sh"
        exit 1
    fi
}

##############################################################################
# Start Backend
##############################################################################

start_backend() {
    print_header "Starting Backend Server"

    cd "$PROJECT_ROOT/backend"

    # Check if package.json exists
    if [ ! -f "package.json" ]; then
        print_error "package.json not found in backend directory"
        exit 1
    fi

    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        print_warning "node_modules not found, installing dependencies..."
        npm install
    fi

    print_info "Starting backend in development mode..."
    print_info "API will be available at: http://localhost:${PORT}"
    print_info "Press Ctrl+C to stop"
    echo ""

    # Start with nodemon if available, otherwise use npm start
    if [ -f "node_modules/.bin/nodemon" ]; then
        npm run dev
    else
        npm start
    fi
}

##############################################################################
# Cleanup Handler
##############################################################################

cleanup() {
    echo ""
    print_info "Shutting down gracefully..."
    # Kill any child processes
    jobs -p | xargs -r kill 2>/dev/null || true
    print_success "Development environment stopped"
    exit 0
}

trap cleanup SIGINT SIGTERM

##############################################################################
# Main
##############################################################################

show_help() {
    echo "GAMILIT Platform Development Starter"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --skip-checks     Skip database checks"
    echo "  --help            Show this help message"
    echo ""
}

main() {
    local skip_checks=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-checks)
                skip_checks=true
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

    print_header "GAMILIT Platform Development Environment"

    load_env

    if [ "$skip_checks" = false ]; then
        check_postgresql
        check_database
    else
        print_info "Skipping database checks"
    fi

    start_backend
}

# Run main function
main "$@"
