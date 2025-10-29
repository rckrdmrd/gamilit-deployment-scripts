#!/bin/bash

# =====================================================
# Database Setup Script for GAMILIT Platform
# Description: Automated database creation with secure credentials
# Created: 2025-10-27
# =====================================================

set -e  # Exit on error
set -u  # Exit on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DB_NAME="gamilit_platform"
DB_USER="gamilit_user"
DB_HOST="localhost"
DB_PORT="5432"
POSTGRES_USER="postgres"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.md"
DDL_DIR="${SCRIPT_DIR}/../gamilit_platform"

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to generate secure password
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-32
}

# Function to check if PostgreSQL is running
check_postgres() {
    print_info "Checking PostgreSQL status..."
    if ! pg_isready -h $DB_HOST -p $DB_PORT > /dev/null 2>&1; then
        print_error "PostgreSQL is not running on ${DB_HOST}:${DB_PORT}"
        exit 1
    fi
    print_info "PostgreSQL is running ✓"
}

# Function to create database user
create_user() {
    local password=$1
    print_info "Creating database user: ${DB_USER}..."

    # Check if user exists
    if sudo -u postgres psql -h $DB_HOST -p $DB_PORT -tAc "SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}'" | grep -q 1; then
        print_warn "User ${DB_USER} already exists, skipping creation"
    else
        sudo -u postgres psql -h $DB_HOST -p $DB_PORT <<EOF
CREATE USER ${DB_USER} WITH
    LOGIN
    PASSWORD '${password}'
    CREATEDB
    NOCREATEROLE
    NOSUPERUSER;
EOF
        print_info "User ${DB_USER} created successfully ✓"
    fi
}

# Function to create database
create_database() {
    print_info "Creating database: ${DB_NAME}..."

    # Check if database exists
    if sudo -u postgres psql -h $DB_HOST -p $DB_PORT -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then
        print_warn "Database ${DB_NAME} already exists"
        read -p "Do you want to drop and recreate it? (yes/no): " confirm
        if [ "$confirm" == "yes" ]; then
            print_info "Dropping existing database..."
            sudo -u postgres psql -h $DB_HOST -p $DB_PORT -c "DROP DATABASE ${DB_NAME};"
        else
            print_info "Skipping database creation"
            return
        fi
    fi

    sudo -u postgres psql -h $DB_HOST -p $DB_PORT <<EOF
CREATE DATABASE ${DB_NAME}
    WITH
    OWNER = ${DB_USER}
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE ${DB_NAME} IS 'Base de datos para GAMILIT - Gamified Literacy Interactive Training Platform';
EOF

    print_info "Database ${DB_NAME} created successfully ✓"
}

# Function to grant permissions
grant_permissions() {
    print_info "Granting permissions to ${DB_USER}..."

    sudo -u postgres psql -h $DB_HOST -p $DB_PORT -d ${DB_NAME} <<EOF
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};
GRANT ALL ON SCHEMA public TO ${DB_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${DB_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${DB_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO ${DB_USER};
EOF

    print_info "Permissions granted successfully ✓"
}

# Function to save configuration
save_config() {
    local password=$1
    print_info "Saving configuration to ${CONFIG_FILE}..."

    cat > "${CONFIG_FILE}" <<EOF
# GAMILIT Platform - Database Configuration

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')

## Database Credentials

\`\`\`bash
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${password}
\`\`\`

## Connection String

\`\`\`bash
# PostgreSQL Connection String
postgresql://${DB_USER}:${password}@${DB_HOST}:${DB_PORT}/${DB_NAME}

# PSQL Command
PGPASSWORD='${password}' psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME}
\`\`\`

## Environment Variables (.env)

\`\`\`bash
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${password}
DB_POOL_MIN=2
DB_POOL_MAX=10
DB_SSL=false
\`\`\`

## Security Notes

- **IMPORTANT:** This file contains sensitive credentials
- Add \`config.md\` to your \`.gitignore\` immediately
- Use environment variables in production
- Rotate password periodically
- Never commit this file to version control

## Next Steps

1. Run the DDL scripts to create schemas and tables:
   \`\`\`bash
   cd ../gamilit_platform
   PGPASSWORD='${password}' psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f 00-create-database.sql
   PGPASSWORD='${password}' psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f 01-create-schemas.sql
   PGPASSWORD='${password}' psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -f 02-create-enums.sql
   # ... continue with other scripts
   \`\`\`

2. Update your backend \`.env\` file with these credentials

3. Test the connection:
   \`\`\`bash
   PGPASSWORD='${password}' psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -c "SELECT version();"
   \`\`\`

## Backup Command

\`\`\`bash
PGPASSWORD='${password}' pg_dump -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -F c -b -v -f backup_\$(date +%Y%m%d_%H%M%S).dump
\`\`\`

## Restore Command

\`\`\`bash
PGPASSWORD='${password}' pg_restore -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -v backup_YYYYMMDD_HHMMSS.dump
\`\`\`
EOF

    chmod 600 "${CONFIG_FILE}"  # Restrict permissions
    print_info "Configuration saved to ${CONFIG_FILE} ✓"
    print_warn "IMPORTANT: Add config.md to .gitignore!"
}

# Main execution
main() {
    echo ""
    echo "========================================="
    echo "  GAMILIT Database Setup"
    echo "========================================="
    echo ""

    # Check PostgreSQL
    check_postgres

    # Generate secure password
    print_info "Generating secure password..."
    DB_PASSWORD=$(generate_password)
    print_info "Password generated ✓"

    # Create user
    create_user "${DB_PASSWORD}"

    # Create database
    create_database

    # Grant permissions
    grant_permissions

    # Save configuration
    save_config "${DB_PASSWORD}"

    echo ""
    echo "========================================="
    echo "  Setup Complete!"
    echo "========================================="
    echo ""
    print_info "Database: ${DB_NAME}"
    print_info "User: ${DB_USER}"
    print_info "Password: ${DB_PASSWORD}"
    print_info "Config file: ${CONFIG_FILE}"
    echo ""
    print_warn "NEXT STEPS:"
    echo "  1. Review the configuration in ${CONFIG_FILE}"
    echo "  2. Add config.md to .gitignore"
    echo "  3. Run the DDL scripts to create schemas and tables"
    echo "  4. Update your backend .env file"
    echo ""
}

# Run main function
main
