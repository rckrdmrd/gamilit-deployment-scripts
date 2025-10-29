#!/bin/bash

###############################################################################
# Quick Validation Script for SQL Injection Fix
# Can be integrated into CI/CD pipeline
###############################################################################

set -e

BACKEND_DIR="/home/isem/workspace/workspace-gamilit/projects/gamilit-platform-backend/src"
RLS_FILE="$BACKEND_DIR/middleware/rls.middleware.ts"
TEST_FILE="$BACKEND_DIR/middleware/__tests__/rls.middleware.security.test.ts"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  SQL Injection Fix Validation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

EXIT_CODE=0

# Check 1: Verify RLS middleware file exists
echo -e "${BLUE}[1/6]${NC} Checking RLS middleware file..."
if [ ! -f "$RLS_FILE" ]; then
    echo -e "  ${RED}✗ FAIL: RLS middleware file not found${NC}"
    EXIT_CODE=1
else
    echo -e "  ${GREEN}✓ PASS: File exists${NC}"
fi

# Check 2: Verify no template literal queries in RLS
echo -e "${BLUE}[2/6]${NC} Checking for template literal vulnerabilities..."
TEMPLATE_LITERALS=$(grep -n "query(\`" "$RLS_FILE" 2>/dev/null | grep '\${' || echo "")
if [ -n "$TEMPLATE_LITERALS" ]; then
    echo -e "  ${RED}✗ FAIL: Found template literal queries${NC}"
    echo "$TEMPLATE_LITERALS"
    EXIT_CODE=1
else
    echo -e "  ${GREEN}✓ PASS: No template literals found${NC}"
fi

# Check 3: Verify parameterized queries exist
echo -e "${BLUE}[3/6]${NC} Checking for parameterized queries..."
PARAM_QUERIES=$(grep -n "query('SET LOCAL.*\$1'" "$RLS_FILE" || echo "")
PARAM_COUNT=$(echo "$PARAM_QUERIES" | grep -c "SET LOCAL" || echo "0")

if [ "$PARAM_COUNT" -lt 7 ]; then
    echo -e "  ${RED}✗ FAIL: Expected at least 7 parameterized queries, found $PARAM_COUNT${NC}"
    EXIT_CODE=1
else
    echo -e "  ${GREEN}✓ PASS: Found $PARAM_COUNT parameterized queries${NC}"
fi

# Check 4: Verify security comments exist
echo -e "${BLUE}[4/6]${NC} Checking for security documentation..."
SECURITY_COMMENTS=$(grep -c "prevent SQL injection" "$RLS_FILE" || echo "0")
if [ "$SECURITY_COMMENTS" -lt 2 ]; then
    echo -e "  ${YELLOW}⚠ WARNING: Missing security documentation comments${NC}"
else
    echo -e "  ${GREEN}✓ PASS: Security comments present${NC}"
fi

# Check 5: Verify test file exists
echo -e "${BLUE}[5/6]${NC} Checking for security tests..."
if [ ! -f "$TEST_FILE" ]; then
    echo -e "  ${RED}✗ FAIL: Security test file not found${NC}"
    EXIT_CODE=1
else
    TEST_COUNT=$(grep -c "it('should" "$TEST_FILE" || echo "0")
    echo -e "  ${GREEN}✓ PASS: Test file exists with $TEST_COUNT test cases${NC}"
fi

# Check 6: Verify no obvious SQL injection patterns
echo -e "${BLUE}[6/6]${NC} Checking for SQL injection patterns..."
SQL_INJECTION_PATTERNS=$(grep -rn "SET LOCAL.*=.*\${" "$RLS_FILE" 2>/dev/null || echo "")
if [ -n "$SQL_INJECTION_PATTERNS" ]; then
    echo -e "  ${RED}✗ FAIL: Found potential SQL injection patterns${NC}"
    echo "$SQL_INJECTION_PATTERNS"
    EXIT_CODE=1
else
    echo -e "  ${GREEN}✓ PASS: No SQL injection patterns detected${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ ALL CHECKS PASSED${NC}"
    echo -e "${GREEN}SQL injection fix validated successfully${NC}"
else
    echo -e "${RED}✗ VALIDATION FAILED${NC}"
    echo -e "${RED}Please review and fix the issues above${NC}"
fi

echo -e "${BLUE}========================================${NC}"

exit $EXIT_CODE
