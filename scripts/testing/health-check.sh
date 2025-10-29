#!/bin/bash

##############################################################################
# GAMILIT Platform - Health Check Script
#
# This script checks the health of all GLIT platform components:
# - PostgreSQL database connection
# - Backend API health endpoints
# - System resources
# - Service status
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

# Configuration
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-gamilit_platform}"
DB_USER="${DB_USER:-gamilit_user}"
API_URL="${API_URL:-http://localhost:3001}"

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
        print_success "Loaded environment variables"
    else
        print_warning "Using default configuration"
    fi
}

##############################################################################
# Check PostgreSQL
##############################################################################

check_postgresql() {
    print_header "PostgreSQL Health Check"

    # Check if PostgreSQL service is running
    if command -v systemctl &> /dev/null; then
        if systemctl is-active --quiet postgresql 2>/dev/null; then
            print_success "PostgreSQL service is running"
        else
            print_warning "PostgreSQL service not detected or not running"
        fi
    fi

    # Check database connection
    if command -v psql &> /dev/null; then
        if PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -c "SELECT 1" &> /dev/null; then
            print_success "Database connection: OK"

            # Get database size
            db_size=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "SELECT pg_size_pretty(pg_database_size('${DB_NAME}'))" | xargs)
            echo -e "  Database: ${DB_NAME}"
            echo -e "  Size: ${db_size}"

            # Get connection count
            conn_count=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "SELECT count(*) FROM pg_stat_activity WHERE datname = '${DB_NAME}'" | xargs)
            echo -e "  Active connections: ${conn_count}"

            # Check for long-running queries
            long_queries=$(PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "SELECT count(*) FROM pg_stat_activity WHERE state = 'active' AND query_start < now() - interval '1 minute'" | xargs)
            if [ "$long_queries" -gt 0 ]; then
                print_warning "Found $long_queries long-running query/queries (>1 min)"
            fi

        else
            print_error "Database connection: FAILED"
            return 1
        fi
    else
        print_warning "PostgreSQL client not found"
        return 1
    fi
}

##############################################################################
# Check Backend API
##############################################################################

check_backend() {
    print_header "Backend API Health Check"

    if ! command -v curl &> /dev/null; then
        print_warning "curl not found, skipping API checks"
        return 1
    fi

    # Check basic API health endpoint
    print_info "Checking: ${API_URL}/api/health"
    if curl -s -f -o /dev/null "${API_URL}/api/health" 2>/dev/null; then
        print_success "API health endpoint: OK"

        # Get response
        response=$(curl -s "${API_URL}/api/health")
        echo -e "  Response: ${response}"
    else
        print_error "API health endpoint: FAILED"
        print_info "Backend may not be running"
        return 1
    fi

    # Check database health endpoint
    print_info "Checking: ${API_URL}/api/health/db"
    if curl -s -f -o /dev/null "${API_URL}/api/health/db" 2>/dev/null; then
        print_success "Database health endpoint: OK"
    else
        print_warning "Database health endpoint: Not available"
    fi
}

##############################################################################
# Check System Resources
##############################################################################

check_system_resources() {
    print_header "System Resources Check"

    # Check disk space
    disk_usage=$(df -h "$PROJECT_ROOT" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$disk_usage" -lt 80 ]; then
        print_success "Disk usage: ${disk_usage}%"
    elif [ "$disk_usage" -lt 90 ]; then
        print_warning "Disk usage: ${disk_usage}% (getting high)"
    else
        print_error "Disk usage: ${disk_usage}% (critical)"
    fi

    # Check memory
    if command -v free &> /dev/null; then
        mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
        if [ "$mem_usage" -lt 80 ]; then
            print_success "Memory usage: ${mem_usage}%"
        elif [ "$mem_usage" -lt 90 ]; then
            print_warning "Memory usage: ${mem_usage}% (getting high)"
        else
            print_error "Memory usage: ${mem_usage}% (critical)"
        fi
    fi

    # Check CPU load
    if command -v uptime &> /dev/null; then
        load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
        print_info "Load average: ${load_avg}"
    fi
}

##############################################################################
# Check Node.js Process
##############################################################################

check_node_process() {
    print_header "Node.js Process Check"

    if pgrep -f "node.*backend" > /dev/null; then
        print_success "Backend Node.js process is running"

        # Get process details
        pid=$(pgrep -f "node.*backend" | head -1)
        echo -e "  PID: ${pid}"

        # Get memory usage
        if command -v ps &> /dev/null; then
            mem=$(ps -p "$pid" -o rss= | awk '{printf "%.2f MB", $1/1024}')
            echo -e "  Memory: ${mem}"
        fi

        # Get uptime
        if command -v ps &> /dev/null; then
            uptime=$(ps -p "$pid" -o etime= | xargs)
            echo -e "  Uptime: ${uptime}"
        fi
    else
        print_warning "Backend Node.js process not found"
        print_info "Start with: ./scripts/dev-start.sh"
        return 1
    fi
}

##############################################################################
# Check Docker Services
##############################################################################

check_docker() {
    print_header "Docker Services Check"

    if ! command -v docker &> /dev/null; then
        print_warning "Docker not found"
        return 1
    fi

    # Check if docker-compose.yml exists
    if [ -f "$PROJECT_ROOT/docker-compose.yml" ]; then
        print_success "docker-compose.yml found"

        # Check running containers
        if docker compose ps 2>/dev/null | grep -q "Up"; then
            print_success "Docker containers are running"
            docker compose ps
        else
            print_info "No Docker containers running"
            print_info "Start with: docker-compose up"
        fi
    else
        print_warning "docker-compose.yml not found"
    fi
}

##############################################################################
# Check Logs
##############################################################################

check_logs() {
    print_header "Recent Logs Check"

    # Check backend logs
    if [ -d "$PROJECT_ROOT/backend/logs" ]; then
        print_info "Checking backend logs..."

        # Check for recent errors
        error_count=$(find "$PROJECT_ROOT/backend/logs" -name "*.log" -mtime -1 -exec grep -i "error" {} \; 2>/dev/null | wc -l)

        if [ "$error_count" -eq 0 ]; then
            print_success "No errors in recent logs"
        elif [ "$error_count" -lt 10 ]; then
            print_warning "Found $error_count error(s) in recent logs"
        else
            print_error "Found $error_count errors in recent logs (review needed)"
        fi
    else
        print_info "No log directory found"
    fi
}

##############################################################################
# Generate Health Report
##############################################################################

generate_report() {
    print_header "Health Check Summary"

    local total_checks=$1
    local passed_checks=$2
    local failed_checks=$3

    echo -e "${BLUE}Results:${NC}"
    echo -e "  Total:  $total_checks"
    echo -e "  Passed: ${GREEN}$passed_checks${NC}"
    echo -e "  Failed: ${RED}$failed_checks${NC}"

    local health_percentage=$((passed_checks * 100 / total_checks))

    echo ""
    if [ $health_percentage -ge 90 ]; then
        print_success "System health: EXCELLENT (${health_percentage}%)"
    elif [ $health_percentage -ge 70 ]; then
        print_success "System health: GOOD (${health_percentage}%)"
    elif [ $health_percentage -ge 50 ]; then
        print_warning "System health: FAIR (${health_percentage}%)"
    else
        print_error "System health: POOR (${health_percentage}%)"
    fi

    if [ $failed_checks -gt 0 ]; then
        echo ""
        print_info "Review failed checks above and take necessary actions"
    fi
}

##############################################################################
# Main
##############################################################################

show_help() {
    echo "GAMILIT Platform Health Check Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --quick           Quick check (database and API only)"
    echo "  --detailed        Detailed check with all components"
    echo "  --help            Show this help message"
    echo ""
}

main() {
    local quick=false
    local detailed=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quick)
                quick=true
                shift
                ;;
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

    print_header "GAMILIT Platform Health Check"
    print_info "Timestamp: $(date)"

    load_env

    local total_checks=0
    local passed_checks=0
    local failed_checks=0

    # PostgreSQL check
    if check_postgresql; then
        ((passed_checks++))
    else
        ((failed_checks++))
    fi
    ((total_checks++))

    # Backend API check
    if check_backend; then
        ((passed_checks++))
    else
        ((failed_checks++))
    fi
    ((total_checks++))

    if [ "$quick" = false ]; then
        # Node.js process check
        if check_node_process; then
            ((passed_checks++))
        else
            ((failed_checks++))
        fi
        ((total_checks++))

        # System resources check
        if check_system_resources; then
            ((passed_checks++))
        else
            ((failed_checks++))
        fi
        ((total_checks++))

        if [ "$detailed" = true ]; then
            # Docker check
            if check_docker; then
                ((passed_checks++))
            else
                ((failed_checks++))
            fi
            ((total_checks++))

            # Logs check
            if check_logs; then
                ((passed_checks++))
            else
                ((failed_checks++))
            fi
            ((total_checks++))
        fi
    fi

    # Generate report
    generate_report $total_checks $passed_checks $failed_checks
}

# Run main function
main "$@"
