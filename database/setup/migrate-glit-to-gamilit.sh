#!/bin/bash

# =====================================================
# Migration Script: glit → gamilit
# Description: Replaces all references of glit with gamilit
# Created: 2025-10-27
# =====================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_debug() { echo -e "${BLUE}[DEBUG]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DDL_DIR="${SCRIPT_DIR}/../gamilit_platform"
BACKUP_DIR="${SCRIPT_DIR}/../backup_before_migration_$(date +%Y%m%d_%H%M%S)"

# Statistics
TOTAL_FILES=0
TOTAL_REPLACEMENTS=0

echo ""
echo "========================================="
echo "  GLIT → GAMILIT Migration"
echo "========================================="
echo ""

# Create backup
print_info "Creating backup before migration..."
cp -r "${DDL_DIR}" "${BACKUP_DIR}"
print_info "Backup created at: ${BACKUP_DIR}"
echo ""

# Function to replace in file
replace_in_file() {
    local file=$1
    local changes=0

    if [ ! -f "${file}" ]; then
        return
    fi

    # Count occurrences before replacement
    local count_before=$(grep -o "glit" "${file}" | wc -l)

    if [ $count_before -gt 0 ]; then
        print_debug "Processing: ${file##*/} (${count_before} occurrences)"

        # Perform replacements with sed
        # Replace database name
        sed -i 's/glit_platform/gamilit_platform/g' "${file}"
        sed -i 's/DB_NAME=glit_platform/DB_NAME=gamilit_platform/g' "${file}"

        # Replace user
        sed -i 's/glit_user/gamilit_user/g' "${file}"
        sed -i 's/DB_USER=glit_user/DB_USER=gamilit_user/g' "${file}"

        # Replace password variable name (but not the password itself!)
        # Only in comments or variable names
        sed -i 's/glit_secure/gamilit_secure/g' "${file}"

        # Replace in comments and strings
        sed -i 's/GLIT Platform/GAMILIT Platform/g' "${file}"
        sed -i 's/GLIT - /GAMILIT - /g' "${file}"
        sed -i 's/proyecto GLIT/proyecto GAMILIT/g' "${file}"
        sed -i 's/sistema GLIT/sistema GAMILIT/g' "${file}"
        sed -i 's/base de datos GLIT/base de datos GAMILIT/g' "${file}"
        sed -i 's/plataforma GLIT/plataforma GAMILIT/g' "${file}"

        # Count after
        local count_after=$(grep -o "glit" "${file}" 2>/dev/null | wc -l || echo 0)
        changes=$((count_before - count_after))

        if [ $changes -gt 0 ]; then
            TOTAL_REPLACEMENTS=$((TOTAL_REPLACEMENTS + changes))
            TOTAL_FILES=$((TOTAL_FILES + 1))
            print_info "  ✓ ${changes} replacements in ${file##*/}"
        fi
    fi
}

# Process all SQL files
print_info "Processing SQL files..."
echo ""

find "${DDL_DIR}" -type f -name "*.sql" | while read -r file; do
    replace_in_file "${file}"
done

# Process Markdown files
print_info "Processing Markdown files..."
echo ""

find "${DDL_DIR}" -type f -name "*.md" | while read -r file; do
    replace_in_file "${file}"
done

# Process text files
print_info "Processing text files..."
echo ""

find "${DDL_DIR}" -type f -name "*.txt" | while read -r file; do
    replace_in_file "${file}"
done

# Process config files
if [ -f "${SCRIPT_DIR}/config.md" ]; then
    print_info "Processing config.md..."
    replace_in_file "${SCRIPT_DIR}/config.md"
    echo ""
fi

# Also update the setup scripts
print_info "Updating setup scripts..."
if [ -f "${SCRIPT_DIR}/db-setup.sh" ]; then
    replace_in_file "${SCRIPT_DIR}/db-setup.sh"
fi
if [ -f "${SCRIPT_DIR}/install-all.sh" ]; then
    replace_in_file "${SCRIPT_DIR}/install-all.sh"
fi
echo ""

# Verification
print_info "Running verification..."
echo ""

# Check for remaining "glit_" references (excluding this script and backups)
remaining=$(find "${DDL_DIR}" -type f \( -name "*.sql" -o -name "*.md" \) -exec grep -l "glit_platform\|glit_user" {} \; 2>/dev/null | wc -l)

if [ $remaining -eq 0 ]; then
    print_info "✓ No remaining 'glit_platform' or 'glit_user' references found"
else
    print_warn "Found ${remaining} files with remaining references"
    print_warn "These might be intentional (in comments or historical references)"
fi

echo ""
echo "========================================="
echo "  Migration Complete!"
echo "========================================="
echo ""
print_info "Files modified: ${TOTAL_FILES}"
print_info "Total replacements: ${TOTAL_REPLACEMENTS}"
print_info "Backup location: ${BACKUP_DIR}"
echo ""
print_warn "IMPORTANT NEXT STEPS:"
echo "  1. Review the changes (compare with backup)"
echo "  2. Test a fresh installation"
echo "  3. Update documentation references"
echo "  4. Keep backup until verified"
echo ""

# Generate summary report
REPORT_FILE="${SCRIPT_DIR}/migration_report_$(date +%Y%m%d_%H%M%S).txt"
cat > "${REPORT_FILE}" <<EOF
GLIT → GAMILIT Migration Report
Generated: $(date)

REPLACEMENTS MADE:
------------------
- glit_platform → gamilit_platform
- glit_user → gamilit_user
- glit_secure → gamilit_secure
- "GLIT Platform" → "GAMILIT Platform"
- Various references in comments and strings

STATISTICS:
-----------
Files modified: ${TOTAL_FILES}
Total replacements: ${TOTAL_REPLACEMENTS}
Backup location: ${BACKUP_DIR}

VERIFICATION:
-------------
Remaining "glit_" references: ${remaining} files

FILES PROCESSED:
----------------
SQL files: $(find "${DDL_DIR}" -type f -name "*.sql" | wc -l)
Markdown files: $(find "${DDL_DIR}" -type f -name "*.md" | wc -l)
Text files: $(find "${DDL_DIR}" -type f -name "*.txt" | wc -l)

NEXT STEPS:
-----------
1. Review changes with: diff -r ${BACKUP_DIR} ${DDL_DIR}
2. Test fresh installation
3. Update backend .env file
4. Update documentation
5. Delete backup after verification

EOF

print_info "Migration report saved to: ${REPORT_FILE}"
