#!/bin/bash
# ============================================================================
# File: execute_all_seeds.sh
# Description: Execute all seed data scripts in correct order for GAMILIT Platform
# Usage: sudo bash execute_all_seeds.sh
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DB_NAME="gamilit_platform"
DB_USER="postgres"
SEED_DIR="/home/isem/workspace/projects/glit/database/seed_data"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo "============================================================================"
    echo "  $1"
    echo "============================================================================"
    echo ""
}

# Header
print_header "GAMILIT Platform - Seed Data Execution"

# Check if running with proper permissions
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run with sudo"
    echo "Usage: sudo bash execute_all_seeds.sh"
    exit 1
fi

# Check database connection
print_info "Checking database connection..."
if ! sudo -u $DB_USER psql -d $DB_NAME -c "SELECT 1" > /dev/null 2>&1; then
    print_error "Cannot connect to database '$DB_NAME'"
    exit 1
fi
print_success "Database connection OK"

# Execute seed files in order
SEED_FILES=(
    "01_achievements_seed.sql"
    "02_system_config_seed.sql"
    "03_educational_modules_seed.sql"
    "04_demo_users_and_data_seed.sql"
)

FAILED_FILES=()
SUCCESS_COUNT=0

for seed_file in "${SEED_FILES[@]}"; do
    file_path="$SEED_DIR/$seed_file"

    if [ ! -f "$file_path" ]; then
        print_error "File not found: $seed_file"
        FAILED_FILES+=("$seed_file")
        continue
    fi

    print_info "Executing: $seed_file"

    if sudo -u $DB_USER psql -d $DB_NAME -f "$file_path" > /dev/null 2>&1; then
        print_success "✓ $seed_file completed"
        ((SUCCESS_COUNT++))
    else
        print_error "✗ $seed_file failed"
        FAILED_FILES+=("$seed_file")
    fi
done

# Summary
echo ""
print_header "EXECUTION SUMMARY"

if [ ${#FAILED_FILES[@]} -eq 0 ]; then
    print_success "All seed scripts executed successfully!"
    echo ""
    print_info "Seed data loaded:"
    print_info "  ✓ Achievements (32 achievements)"
    print_info "  ✓ System Configuration (37 settings + 17 feature flags)"
    print_info "  ✓ Educational Modules (8 modules + 4 sample exercises)"
    print_info "  ✓ Demo Users & Data (1 admin + 2 teachers + 7 students)"
    print_info "  ✓ Classrooms (3 classrooms with student assignments)"
    print_info "  ✓ Sample Progress (2 students with completed/in-progress modules)"
    echo ""
    print_info "Demo Login Credentials:"
    print_info "  - All users password: Glit2024!"
    print_info "  - Admin: admin@glit.com"
    print_info "  - Teacher 1: teacher1@glit.com"
    print_info "  - Teacher 2: teacher2@glit.com"
    print_info "  - Students: student1@glit.com through student7@glit.com"
    echo ""
    print_info "Database is now ready for development!"
    exit 0
else
    print_error "$SUCCESS_COUNT of ${#SEED_FILES[@]} files succeeded"
    print_error "Failed files:"
    for file in "${FAILED_FILES[@]}"; do
        echo "  - $file"
    done
    exit 1
fi
