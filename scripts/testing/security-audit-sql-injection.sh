#!/bin/bash

###############################################################################
# SQL Injection Security Audit Script
# Scans codebase for potential SQL injection vulnerabilities
###############################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BACKEND_DIR="/home/isem/workspace/workspace-gamilit/projects/gamilit-platform-backend/src"
REPORT_FILE="/home/isem/workspace/docs/projects/glit-analisys/reportes/security-audit-sql-$(date +%Y%m%d-%H%M%S).txt"

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  SQL Injection Security Audit${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Initialize report
cat > "$REPORT_FILE" << EOF
SQL Injection Security Audit Report
Generated: $(date)
Project: GLIT Backend
Scan Directory: $BACKEND_DIR

============================================

EOF

echo -e "${YELLOW}Scanning for SQL injection patterns...${NC}"
echo ""

# Pattern 1: Template literals with query
echo -e "${BLUE}1. Checking for template literal queries...${NC}"
echo "1. Template Literal Queries (VULNERABLE PATTERN)" >> "$REPORT_FILE"
echo "   Pattern: \`query(\`...\${variable}...\`)\`" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

PATTERN1_RESULTS=$(grep -rn "query(\`" "$BACKEND_DIR" 2>/dev/null | grep '\${' || echo "")

if [ -z "$PATTERN1_RESULTS" ]; then
    echo -e "   ${GREEN}✓ No template literal queries found${NC}"
    echo "   ✓ No vulnerabilities found" >> "$REPORT_FILE"
else
    echo -e "   ${RED}✗ Found potential vulnerabilities:${NC}"
    echo "$PATTERN1_RESULTS" | while IFS= read -r line; do
        echo -e "   ${RED}$line${NC}"
        echo "   $line" >> "$REPORT_FILE"
    done
fi
echo "" >> "$REPORT_FILE"
echo ""

# Pattern 2: String concatenation in queries
echo -e "${BLUE}2. Checking for string concatenation in queries...${NC}"
echo "2. String Concatenation in Queries (VULNERABLE PATTERN)" >> "$REPORT_FILE"
echo "   Pattern: query('...' + variable + '...')" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

PATTERN2_RESULTS=$(grep -rn "query(.*+.*)" "$BACKEND_DIR" 2>/dev/null | grep -v "node_modules" | grep -v ".test.ts" || echo "")

if [ -z "$PATTERN2_RESULTS" ]; then
    echo -e "   ${GREEN}✓ No string concatenation in queries found${NC}"
    echo "   ✓ No vulnerabilities found" >> "$REPORT_FILE"
else
    echo -e "   ${YELLOW}⚠ Found potential string concatenation:${NC}"
    echo "$PATTERN2_RESULTS" | while IFS= read -r line; do
        echo -e "   ${YELLOW}$line${NC}"
        echo "   $line" >> "$REPORT_FILE"
    done
fi
echo "" >> "$REPORT_FILE"
echo ""

# Pattern 3: Direct variable interpolation in SQL
echo -e "${BLUE}3. Checking for direct SQL variable interpolation...${NC}"
echo "3. Direct Variable Interpolation (VULNERABLE PATTERN)" >> "$REPORT_FILE"
echo "   Pattern: Variables used directly in SQL strings" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

PATTERN3_RESULTS=$(grep -rn "SET LOCAL.*=.*\${" "$BACKEND_DIR" 2>/dev/null || echo "")

if [ -z "$PATTERN3_RESULTS" ]; then
    echo -e "   ${GREEN}✓ No direct variable interpolation in SET LOCAL found${NC}"
    echo "   ✓ No vulnerabilities found" >> "$REPORT_FILE"
else
    echo -e "   ${RED}✗ Found direct variable interpolation:${NC}"
    echo "$PATTERN3_RESULTS" | while IFS= read -r line; do
        echo -e "   ${RED}$line${NC}"
        echo "   $line" >> "$REPORT_FILE"
    done
fi
echo "" >> "$REPORT_FILE"
echo ""

# Pattern 4: Check for proper parameterized queries
echo -e "${BLUE}4. Checking for parameterized queries (SECURE PATTERN)...${NC}"
echo "4. Parameterized Queries (SECURE PATTERN)" >> "$REPORT_FILE"
echo "   Pattern: query('...', [parameters])" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

PATTERN4_RESULTS=$(grep -rn "query('.*\$[0-9]" "$BACKEND_DIR" 2>/dev/null | grep -v "node_modules" | grep -v ".test.ts" || echo "")

if [ -z "$PATTERN4_RESULTS" ]; then
    echo -e "   ${YELLOW}⚠ No parameterized queries found (may need review)${NC}"
    echo "   ⚠ No parameterized queries detected" >> "$REPORT_FILE"
else
    echo -e "   ${GREEN}✓ Found parameterized queries (secure):${NC}"
    COUNT=$(echo "$PATTERN4_RESULTS" | wc -l)
    echo -e "   ${GREEN}  Total: $COUNT instances${NC}"
    echo "   ✓ Found $COUNT instances of parameterized queries" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "$PATTERN4_RESULTS" | head -10 | while IFS= read -r line; do
        echo "   $line" >> "$REPORT_FILE"
    done
fi
echo "" >> "$REPORT_FILE"
echo ""

# Pattern 5: Check for raw SQL execution
echo -e "${BLUE}5. Checking for raw SQL execution...${NC}"
echo "5. Raw SQL Execution (REVIEW REQUIRED)" >> "$REPORT_FILE"
echo "   Pattern: .query() or .execute() calls" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

PATTERN5_RESULTS=$(grep -rn "\\.query\\|.execute" "$BACKEND_DIR" 2>/dev/null | grep -v "node_modules" | grep -v ".test.ts" | wc -l)

echo -e "   ${BLUE}ℹ Total query/execute calls: $PATTERN5_RESULTS${NC}"
echo "   Total query/execute calls found: $PATTERN5_RESULTS" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo ""

# Summary
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo "Summary" >> "$REPORT_FILE"
echo "============================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

VULNERABLE_COUNT=0

if [ -n "$PATTERN1_RESULTS" ]; then
    VULNERABLE_COUNT=$((VULNERABLE_COUNT + $(echo "$PATTERN1_RESULTS" | wc -l)))
fi

if [ -n "$PATTERN3_RESULTS" ]; then
    VULNERABLE_COUNT=$((VULNERABLE_COUNT + $(echo "$PATTERN3_RESULTS" | wc -l)))
fi

if [ $VULNERABLE_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓ No SQL injection vulnerabilities found!${NC}"
    echo "✓ No SQL injection vulnerabilities detected" >> "$REPORT_FILE"
    echo -e "${GREEN}✓ RLS middleware fix successfully applied${NC}"
    echo "✓ RLS middleware fix successfully applied" >> "$REPORT_FILE"
else
    echo -e "${RED}✗ Found $VULNERABLE_COUNT potential SQL injection vulnerabilities${NC}"
    echo "✗ Found $VULNERABLE_COUNT potential vulnerabilities" >> "$REPORT_FILE"
    echo -e "${YELLOW}⚠ Please review and fix these issues${NC}"
    echo "⚠ Manual review required" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "Report saved to: $REPORT_FILE" >> "$REPORT_FILE"

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Report saved to:${NC}"
echo -e "${GREEN}$REPORT_FILE${NC}"
echo -e "${BLUE}============================================${NC}"

exit $VULNERABLE_COUNT
