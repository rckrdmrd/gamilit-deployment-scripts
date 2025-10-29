#!/bin/bash

##############################################################################
# Deployment Script: JWT Token Hashing Security Fix
# Vulnerability: GLIT-SEC-002 (CVSS 8.1, CWE-256)
#
# This script safely deploys the JWT token hashing fix with proper validation
# and rollback capabilities.
#
# Author: Claude Code Agent
# Date: 2025-10-23
##############################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-gamilit_platform}"
DB_USER="${DB_USER:-gamilit_user}"
BACKEND_PATH="/home/isem/workspace/projects/glit/backend"
MIGRATION_FILE="013_hash_refresh_tokens_security_fix.sql"
ROLLBACK_FILE="013_hash_refresh_tokens_security_fix_ROLLBACK.sql"

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

confirm_action() {
    local message=$1
    echo -e "${YELLOW}$message${NC}"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted by user."
        exit 1
    fi
}

run_sql() {
    local sql=$1
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "$sql"
}

run_sql_file() {
    local file=$1
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$file"
}

##############################################################################
# Pre-flight Checks
##############################################################################

preflight_checks() {
    print_header "Pre-flight Checks"

    # Check if psql is available
    if ! command -v psql &> /dev/null; then
        print_error "psql command not found. Please install PostgreSQL client."
        exit 1
    fi
    print_success "psql found"

    # Check database connection
    if ! psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1" &> /dev/null; then
        print_error "Cannot connect to database $DB_NAME"
        exit 1
    fi
    print_success "Database connection successful"

    # Check if migration file exists
    if [ ! -f "$SCRIPT_DIR/$MIGRATION_FILE" ]; then
        print_error "Migration file not found: $MIGRATION_FILE"
        exit 1
    fi
    print_success "Migration file found"

    # Check if rollback file exists
    if [ ! -f "$SCRIPT_DIR/$ROLLBACK_FILE" ]; then
        print_warning "Rollback file not found: $ROLLBACK_FILE"
    else
        print_success "Rollback file found"
    fi

    # Check backend code exists
    if [ ! -d "$BACKEND_PATH" ]; then
        print_error "Backend directory not found: $BACKEND_PATH"
        exit 1
    fi
    print_success "Backend directory found"
}

##############################################################################
# Database Backup
##############################################################################

backup_database() {
    print_header "Database Backup"

    local backup_file="gamilit_platform_backup_$(date +%Y%m%d_%H%M%S).sql"
    local backup_path="/tmp/$backup_file"

    print_info "Creating database backup: $backup_path"

    if pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" > "$backup_path"; then
        print_success "Database backup created: $backup_path"
        echo "$backup_path" > /tmp/gamilit_jwt_fix_backup_path.txt
    else
        print_error "Failed to create database backup"
        exit 1
    fi
}

##############################################################################
# Pre-Migration Statistics
##############################################################################

show_pre_migration_stats() {
    print_header "Pre-Migration Statistics"

    local active_sessions=$(run_sql "SELECT COUNT(*) FROM auth_management.user_sessions WHERE is_active = true;" | awk 'NR==3 {print $1}')
    local total_sessions=$(run_sql "SELECT COUNT(*) FROM auth_management.user_sessions;" | awk 'NR==3 {print $1}')
    local total_users=$(run_sql "SELECT COUNT(*) FROM auth.users WHERE deleted_at IS NULL;" | awk 'NR==3 {print $1}')

    echo "Total users: $total_users"
    echo "Active sessions: $active_sessions"
    echo "Total sessions: $total_sessions"
    echo ""

    print_warning "All $active_sessions active sessions will be invalidated!"
    print_warning "Users will need to re-login after deployment."
}

##############################################################################
# Run Migration
##############################################################################

run_migration() {
    print_header "Running Migration"

    print_info "Applying migration: $MIGRATION_FILE"

    if run_sql_file "$SCRIPT_DIR/$MIGRATION_FILE"; then
        print_success "Migration completed successfully"
    else
        print_error "Migration failed!"
        print_error "Check error messages above and consider rolling back."
        exit 1
    fi
}

##############################################################################
# Verify Migration
##############################################################################

verify_migration() {
    print_header "Verifying Migration"

    # Check that sessions are invalidated
    local active_sessions=$(run_sql "SELECT COUNT(*) FROM auth_management.user_sessions WHERE is_active = true;" | awk 'NR==3 {print $1}')

    if [ "$active_sessions" -eq 0 ]; then
        print_success "All sessions invalidated: $active_sessions active"
    else
        print_warning "Still have active sessions: $active_sessions"
    fi

    # Check that indexes were created
    local session_token_index=$(run_sql "SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'auth_management' AND tablename = 'user_sessions' AND indexname = 'idx_user_sessions_session_token_hash';" | awk 'NR==3 {print $1}')
    local refresh_token_index=$(run_sql "SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'auth_management' AND tablename = 'user_sessions' AND indexname = 'idx_user_sessions_refresh_token_hash';" | awk 'NR==3 {print $1}')

    if [ "$session_token_index" -eq 1 ]; then
        print_success "Session token index created"
    else
        print_error "Session token index missing"
    fi

    if [ "$refresh_token_index" -eq 1 ]; then
        print_success "Refresh token index created"
    else
        print_error "Refresh token index missing"
    fi

    # Check that trigger was created
    local trigger_exists=$(run_sql "SELECT COUNT(*) FROM pg_trigger WHERE tgname = 'trg_validate_token_format';" | awk 'NR==3 {print $1}')

    if [ "$trigger_exists" -ge 1 ]; then
        print_success "Validation trigger created"
    else
        print_error "Validation trigger missing"
    fi

    # Check security event was logged
    local security_event=$(run_sql "SELECT COUNT(*) FROM auth_management.security_events WHERE event_type = 'security_migration' AND description LIKE '%GLIT-SEC-002%';" | awk 'NR==3 {print $1}')

    if [ "$security_event" -ge 1 ]; then
        print_success "Security event logged"
    else
        print_warning "Security event not found in logs"
    fi
}

##############################################################################
# Build Backend
##############################################################################

build_backend() {
    print_header "Building Backend"

    print_info "Building TypeScript code..."

    cd "$BACKEND_PATH"

    if npm run build; then
        print_success "Backend build successful"
    else
        print_error "Backend build failed"
        exit 1
    fi
}

##############################################################################
# Deploy Backend (if PM2 is available)
##############################################################################

deploy_backend() {
    print_header "Deploying Backend"

    if command -v pm2 &> /dev/null; then
        print_info "Restarting backend with PM2..."

        if pm2 restart gamilit-backend 2>/dev/null; then
            print_success "Backend restarted successfully"
        else
            print_warning "Could not restart with PM2 (may not be configured)"
            print_info "Please manually restart your backend server"
        fi
    else
        print_warning "PM2 not found"
        print_info "Please manually restart your backend server"
    fi
}

##############################################################################
# Post-Deployment Verification
##############################################################################

post_deployment_verification() {
    print_header "Post-Deployment Verification"

    print_info "Waiting 5 seconds for backend to start..."
    sleep 5

    # Try to test login endpoint (optional)
    if command -v curl &> /dev/null; then
        print_info "Testing backend health..."

        # Check if backend is responding (adjust URL as needed)
        if curl -s -f http://localhost:3000/health &> /dev/null; then
            print_success "Backend is responding"
        else
            print_warning "Backend health check failed (may need manual verification)"
        fi
    fi

    print_info "Please verify:"
    echo "  1. Users can login successfully"
    echo "  2. Tokens are being hashed (check database)"
    echo "  3. Session management works correctly"
}

##############################################################################
# Rollback Function
##############################################################################

rollback() {
    print_header "ROLLBACK PROCEDURE"

    print_error "Rolling back changes..."

    if [ -f "$SCRIPT_DIR/$ROLLBACK_FILE" ]; then
        run_sql_file "$SCRIPT_DIR/$ROLLBACK_FILE"
        print_success "Database rollback completed"
    else
        print_error "Rollback file not found!"
    fi

    # Restore from backup
    if [ -f /tmp/glit_jwt_fix_backup_path.txt ]; then
        local backup_path=$(cat /tmp/glit_jwt_fix_backup_path.txt)

        if [ -f "$backup_path" ]; then
            confirm_action "Restore database from backup: $backup_path?"

            print_info "Restoring database..."
            psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" < "$backup_path"
            print_success "Database restored from backup"
        fi
    fi

    print_warning "Remember to also revert backend code changes!"
}

##############################################################################
# Main Execution
##############################################################################

main() {
    print_header "JWT Token Hashing Security Fix Deployment"
    print_info "Vulnerability: GLIT-SEC-002 (CVSS 8.1, CWE-256)"
    print_info "Fix: Hash JWT tokens with SHA256 before database storage"
    echo ""

    # Check if running as rollback
    if [ "$1" == "--rollback" ]; then
        rollback
        exit 0
    fi

    # Pre-flight checks
    preflight_checks

    # Show statistics
    show_pre_migration_stats

    # Confirm deployment
    confirm_action "⚠️  This will INVALIDATE ALL ACTIVE SESSIONS. Users must re-login."

    # Create backup
    backup_database

    # Run migration
    run_migration

    # Verify migration
    verify_migration

    # Build backend
    build_backend

    # Deploy backend
    deploy_backend

    # Post-deployment verification
    post_deployment_verification

    # Success message
    print_header "Deployment Complete"
    print_success "JWT token hashing fix deployed successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. Monitor application logs for errors"
    echo "  2. Test user login functionality"
    echo "  3. Verify tokens are hashed in database"
    echo "  4. Monitor security_events table for validation warnings"
    echo ""
    print_info "Backup location:"
    cat /tmp/glit_jwt_fix_backup_path.txt 2>/dev/null || echo "  No backup path recorded"
    echo ""
    print_info "To rollback: $0 --rollback"
}

# Run main function
main "$@"
