#!/bin/bash

##############################################################################
# GAMILIT Platform - Test Runner Script
#
# This script runs all tests for the GLIT platform:
# - Backend unit tests
# - Integration tests
# - Coverage report generation
# - Test result summary
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
# Load Environment
##############################################################################

load_env() {
    # Load test environment
    if [ -f "$PROJECT_ROOT/.env.test" ]; then
        export $(grep -v '^#' "$PROJECT_ROOT/.env.test" | xargs)
        print_success "Loaded test environment from .env.test"
    elif [ -f "$PROJECT_ROOT/.env" ]; then
        export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)
        print_warning "Using .env (no .env.test found)"
    else
        print_warning "No environment file found, using defaults"
    fi

    # Override for test environment
    export NODE_ENV=test
}

##############################################################################
# Run Backend Unit Tests
##############################################################################

run_unit_tests() {
    print_header "Running Unit Tests"

    cd "$PROJECT_ROOT/backend"

    if [ ! -f "package.json" ]; then
        print_error "Backend package.json not found"
        return 1
    fi

    # Check if test script exists
    if ! npm run | grep -q "test"; then
        print_warning "No test script found in package.json"
        print_info "Skipping unit tests..."
        return 0
    fi

    print_info "Running unit tests..."

    if npm run test; then
        print_success "Unit tests passed"
        return 0
    else
        print_error "Unit tests failed"
        return 1
    fi
}

##############################################################################
# Run Integration Tests
##############################################################################

run_integration_tests() {
    print_header "Running Integration Tests"

    cd "$PROJECT_ROOT/backend"

    # Check if integration test script exists
    if npm run | grep -q "test:integration"; then
        print_info "Running integration tests..."

        if npm run test:integration; then
            print_success "Integration tests passed"
            return 0
        else
            print_error "Integration tests failed"
            return 1
        fi
    else
        print_warning "No integration test script found"
        print_info "Skipping integration tests..."
        return 0
    fi
}

##############################################################################
# Generate Coverage Report
##############################################################################

generate_coverage() {
    print_header "Generating Coverage Report"

    cd "$PROJECT_ROOT/backend"

    # Check if coverage script exists
    if npm run | grep -q "test:coverage"; then
        print_info "Generating coverage report..."

        if npm run test:coverage; then
            print_success "Coverage report generated"

            # Display coverage summary if available
            if [ -f "coverage/coverage-summary.json" ]; then
                print_info "Coverage Summary:"
                cat coverage/coverage-summary.json | grep -A 4 "total" || true
            fi

            print_info "Full coverage report: file://$PROJECT_ROOT/backend/coverage/index.html"
            return 0
        else
            print_error "Coverage generation failed"
            return 1
        fi
    else
        print_warning "No coverage script found"
        print_info "Skipping coverage report..."
        return 0
    fi
}

##############################################################################
# Run Linter
##############################################################################

run_linter() {
    print_header "Running Linter"

    cd "$PROJECT_ROOT/backend"

    # Check if lint script exists
    if npm run | grep -q "lint"; then
        print_info "Running ESLint..."

        if npm run lint; then
            print_success "Linting passed"
            return 0
        else
            print_error "Linting failed"
            return 1
        fi
    else
        print_warning "No lint script found"
        print_info "Skipping linting..."
        return 0
    fi
}

##############################################################################
# Run Type Checking
##############################################################################

run_type_check() {
    print_header "Running Type Check"

    cd "$PROJECT_ROOT/backend"

    # Check if TypeScript is configured
    if [ -f "tsconfig.json" ]; then
        print_info "Running TypeScript compiler..."

        if npx tsc --noEmit; then
            print_success "Type checking passed"
            return 0
        else
            print_error "Type checking failed"
            return 1
        fi
    else
        print_warning "No tsconfig.json found"
        print_info "Skipping type checking..."
        return 0
    fi
}

##############################################################################
# Test Database Connection
##############################################################################

test_database() {
    print_header "Testing Database Connection"

    load_env

    DB_HOST="${DB_HOST:-localhost}"
    DB_PORT="${DB_PORT:-5432}"
    DB_NAME="${DB_NAME:-gamilit_platform}"
    DB_USER="${DB_USER:-gamilit_user}"

    if command -v psql &> /dev/null; then
        if PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -c "SELECT 1" &> /dev/null; then
            print_success "Database connection successful"
            return 0
        else
            print_warning "Cannot connect to database"
            print_info "Integration tests may fail"
            return 1
        fi
    else
        print_warning "PostgreSQL client not found"
        print_info "Skipping database connection test..."
        return 0
    fi
}

##############################################################################
# Generate Test Summary
##############################################################################

generate_summary() {
    print_header "Test Summary"

    local total_tests=$1
    local passed_tests=$2
    local failed_tests=$3

    echo -e "${BLUE}Results:${NC}"
    echo -e "  Total:  $total_tests"
    echo -e "  Passed: ${GREEN}$passed_tests${NC}"
    echo -e "  Failed: ${RED}$failed_tests${NC}"

    if [ $failed_tests -eq 0 ]; then
        echo ""
        print_success "All tests passed!"
        return 0
    else
        echo ""
        print_error "Some tests failed!"
        return 1
    fi
}

##############################################################################
# Main
##############################################################################

show_help() {
    echo "GAMILIT Platform Test Runner"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --unit            Run only unit tests"
    echo "  --integration     Run only integration tests"
    echo "  --coverage        Run tests with coverage"
    echo "  --lint            Run only linter"
    echo "  --type-check      Run only type checking"
    echo "  --skip-db-check   Skip database connection check"
    echo "  --help            Show this help message"
    echo ""
}

main() {
    local run_unit=true
    local run_integration=true
    local run_coverage=false
    local run_lint=true
    local run_typecheck=true
    local check_db=true

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --unit)
                run_integration=false
                run_coverage=false
                run_lint=false
                run_typecheck=false
                shift
                ;;
            --integration)
                run_unit=false
                run_coverage=false
                run_lint=false
                run_typecheck=false
                shift
                ;;
            --coverage)
                run_coverage=true
                run_unit=false
                run_integration=false
                run_lint=false
                run_typecheck=false
                shift
                ;;
            --lint)
                run_unit=false
                run_integration=false
                run_coverage=false
                run_typecheck=false
                shift
                ;;
            --type-check)
                run_unit=false
                run_integration=false
                run_coverage=false
                run_lint=false
                shift
                ;;
            --skip-db-check)
                check_db=false
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

    print_header "GAMILIT Platform Test Runner"

    local total_tests=0
    local passed_tests=0
    local failed_tests=0

    # Database connection check
    if [ "$check_db" = true ]; then
        if test_database; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
        ((total_tests++))
    fi

    # Run type checking
    if [ "$run_typecheck" = true ]; then
        if run_type_check; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
        ((total_tests++))
    fi

    # Run linter
    if [ "$run_lint" = true ]; then
        if run_linter; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
        ((total_tests++))
    fi

    # Run unit tests
    if [ "$run_unit" = true ]; then
        if run_unit_tests; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
        ((total_tests++))
    fi

    # Run integration tests
    if [ "$run_integration" = true ]; then
        if run_integration_tests; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
        ((total_tests++))
    fi

    # Generate coverage
    if [ "$run_coverage" = true ]; then
        if generate_coverage; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
        ((total_tests++))
    fi

    # Generate summary
    generate_summary $total_tests $passed_tests $failed_tests
    exit $?
}

# Run main function
main "$@"
