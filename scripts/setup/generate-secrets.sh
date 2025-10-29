#!/bin/bash
##############################################################################
# GAMILIT Platform - Generate Secure Secrets
#
# This script generates cryptographically secure random secrets for:
# - Database passwords
# - JWT secrets
# - Postgres superuser password
#
# Usage: bash generate-secrets.sh
##############################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}GAMILIT - Secure Secrets Generator${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Generate secrets
DB_PASSWORD=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 32)
POSTGRES_PASSWORD=$(openssl rand -base64 32)

# Display secrets
echo -e "${GREEN}Generated Secrets:${NC}\n"

echo -e "${BLUE}DB_PASSWORD:${NC}"
echo "$DB_PASSWORD"
echo ""

echo -e "${BLUE}JWT_SECRET:${NC}"
echo "$JWT_SECRET"
echo ""

echo -e "${BLUE}POSTGRES_PASSWORD:${NC}"
echo "$POSTGRES_PASSWORD"
echo ""

# Save to temporary file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
SECRETS_FILE="$PROJECT_ROOT/.env.production.secrets"

cat > "$SECRETS_FILE" << EOF
# ============================================================================
# GAMILIT Platform - Generated Secrets
# ============================================================================
# Generated on: $(date)
#
# INSTRUCTIONS:
# 1. Copy these values to your .env.production file
# 2. Replace the placeholder values (CHANGE_ME_IN_PRODUCTION)
# 3. DELETE this file after copying the values
# ============================================================================

DB_PASSWORD=$DB_PASSWORD
JWT_SECRET=$JWT_SECRET
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
EOF

echo -e "${GREEN}✓ Secrets saved to: $SECRETS_FILE${NC}\n"
echo -e "${YELLOW}⚠ IMPORTANT SECURITY STEPS:${NC}"
echo -e "${YELLOW}1. Copy these values to your .env.production file${NC}"
echo -e "${YELLOW}2. DELETE $SECRETS_FILE immediately after copying${NC}"
echo -e "${YELLOW}3. Never commit .env.production to git${NC}\n"

# Also create a .env.production template if it doesn't exist
if [ ! -f "$PROJECT_ROOT/.env.production" ]; then
    if [ -f "$PROJECT_ROOT/.env.example" ]; then
        cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env.production"
        echo -e "${GREEN}✓ Created .env.production from template${NC}"
        echo -e "${BLUE}→ Edit .env.production and paste the generated secrets${NC}\n"
    fi
fi
