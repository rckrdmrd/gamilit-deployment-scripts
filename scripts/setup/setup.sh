#!/bin/bash

##############################################################################
# GAMILIT Platform - Complete Setup Script
#
# This script performs a complete setup of the GAMILIT Platform including:
# - Prerequisites checks (Node.js, PostgreSQL, Docker)
# - Dependencies installation
# - Database setup
# - Environment configuration
# - Initial migrations
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
# Check Prerequisites
##############################################################################

check_prerequisites() {
    print_header "Checking Prerequisites"

    local all_ok=true

    # Check Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)
        if [ "$NODE_VERSION" -ge 18 ]; then
            print_success "Node.js $(node -v) found"
        else
            print_error "Node.js version must be >= 18 (found: $(node -v))"
            all_ok=false
        fi
    else
        print_error "Node.js not found. Please install Node.js >= 18"
        all_ok=false
    fi

    # Check npm
    if command -v npm &> /dev/null; then
        print_success "npm $(npm -v) found"
    else
        print_error "npm not found"
        all_ok=false
    fi

    # Check PostgreSQL
    if command -v psql &> /dev/null; then
        print_success "PostgreSQL $(psql --version | awk '{print $3}') found"
    else
        print_warning "PostgreSQL client not found (optional for development)"
    fi

    # Check if PostgreSQL service is available
    if command -v systemctl &> /dev/null; then
        if systemctl is-active --quiet postgresql 2>/dev/null; then
            print_success "PostgreSQL service is running"
        else
            print_warning "PostgreSQL service is not running"
            print_info "You can start it with: sudo systemctl start postgresql"
        fi
    fi

    # Check Docker
    if command -v docker &> /dev/null; then
        print_success "Docker $(docker --version | awk '{print $3}' | tr -d ',') found"
    else
        print_warning "Docker not found (optional, needed for containerized deployment)"
    fi

    # Check Docker Compose
    if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
        print_success "Docker Compose found"
    else
        print_warning "Docker Compose not found (optional)"
    fi

    if [ "$all_ok" = false ]; then
        print_error "Some prerequisites are missing. Please install them and try again."
        exit 1
    fi

    print_success "All required prerequisites are met!"
}

##############################################################################
# Install Dependencies
##############################################################################

install_dependencies() {
    print_header "Installing Dependencies"

    # Backend dependencies
    if [ -f "$PROJECT_ROOT/backend/package.json" ]; then
        print_info "Installing backend dependencies..."
        cd "$PROJECT_ROOT/backend"
        npm install
        print_success "Backend dependencies installed"
    else
        print_warning "Backend package.json not found, skipping..."
    fi

    cd "$PROJECT_ROOT"
}

##############################################################################
# Setup Environment Files
##############################################################################

setup_env_files() {
    print_header "Setting Up Environment Files"

    # Root .env
    if [ ! -f "$PROJECT_ROOT/.env" ]; then
        if [ -f "$PROJECT_ROOT/.env.example" ]; then
            cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
            print_success "Created .env from .env.example"

            # Prompt for database credentials
            read -p "Enter database password for gamilit_user (or press Enter for default): " db_password
            if [ -n "$db_password" ]; then
                sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$db_password/" "$PROJECT_ROOT/.env"
            fi

            # Generate random JWT secret
            jwt_secret=$(openssl rand -base64 32 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
            sed -i "s/JWT_SECRET=.*/JWT_SECRET=$jwt_secret/" "$PROJECT_ROOT/.env"
            print_success "Generated JWT secret"

        else
            print_warning ".env.example not found, skipping environment setup"
        fi
    else
        print_info ".env already exists, skipping..."
    fi

    # Backend .env
    if [ -f "$PROJECT_ROOT/backend/package.json" ]; then
        if [ ! -f "$PROJECT_ROOT/backend/.env" ]; then
            if [ -f "$PROJECT_ROOT/.env" ]; then
                cp "$PROJECT_ROOT/.env" "$PROJECT_ROOT/backend/.env"
                print_success "Created backend/.env"
            fi
        else
            print_info "backend/.env already exists, skipping..."
        fi
    fi
}

##############################################################################
# Setup Database
##############################################################################

setup_database() {
    print_header "Setting Up Database"

    if [ -f "$SCRIPT_DIR/db-setup.sh" ]; then
        print_info "Running database setup script..."
        bash "$SCRIPT_DIR/db-setup.sh"
    else
        print_warning "db-setup.sh not found, skipping database setup"
        print_info "You can run it manually later: ./scripts/db-setup.sh"
    fi
}

##############################################################################
# Display Next Steps
##############################################################################

show_next_steps() {
    print_header "Setup Complete!"

    echo -e "${GREEN}✓ GAMILIT Platform setup completed successfully!${NC}\n"

    echo -e "${BLUE}Next Steps:${NC}"
    echo -e "  1. Review and update .env file with your configuration"
    echo -e "     ${YELLOW}nano $PROJECT_ROOT/.env${NC}"
    echo -e ""
    echo -e "  2. Start the development environment:"
    echo -e "     ${YELLOW}cd $PROJECT_ROOT${NC}"
    echo -e "     ${YELLOW}./scripts/dev-start.sh${NC}"
    echo -e ""
    echo -e "  3. Or use Docker Compose:"
    echo -e "     ${YELLOW}docker-compose up${NC}"
    echo -e ""
    echo -e "  4. Run tests:"
    echo -e "     ${YELLOW}./scripts/test.sh${NC}"
    echo -e ""
    echo -e "  5. Check system health:"
    echo -e "     ${YELLOW}./scripts/health-check.sh${NC}"
    echo -e ""
    echo -e "${BLUE}Documentation:${NC}"
    echo -e "  - Setup Guide: $PROJECT_ROOT/SETUP.md"
    echo -e "  - Infrastructure: $PROJECT_ROOT/INFRASTRUCTURE.md"
    echo -e "  - Main README: $PROJECT_ROOT/README.md"
    echo -e ""
}

##############################################################################
# Main
##############################################################################

show_help() {
    echo "GAMILIT Platform Setup Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --skip-deps       Skip dependency installation"
    echo "  --skip-db         Skip database setup"
    echo "  --help            Show this help message"
    echo ""
}

main() {
    local skip_deps=false
    local skip_db=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-deps)
                skip_deps=true
                shift
                ;;
            --skip-db)
                skip_db=true
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

    print_header "GAMILIT Platform Setup"
    print_info "Project Root: $PROJECT_ROOT"

    check_prerequisites

    if [ "$skip_deps" = false ]; then
        install_dependencies
    else
        print_info "Skipping dependency installation"
    fi

    setup_env_files

    if [ "$skip_db" = false ]; then
        setup_database
    else
        print_info "Skipping database setup"
    fi

    show_next_steps
}

# Run main function
main "$@"
