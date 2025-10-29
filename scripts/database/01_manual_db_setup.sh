#!/bin/bash
# Manual Database Setup Script for GAMILIT Platform
# This script must be run with sudo privileges
# Usage: sudo bash 01_manual_db_setup.sh

set -e

echo "=========================================="
echo "GAMILIT Platform Database Setup"
echo "=========================================="
echo ""

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
   echo "ERROR: This script must be run with sudo"
   echo "Usage: sudo bash 01_manual_db_setup.sh"
   exit 1
fi

echo "[1/6] Creating database 'gamilit_platform'..."
sudo -u postgres psql -c "CREATE DATABASE gamilit_platform;" 2>&1 || echo "Database may already exist"

echo "[2/6] Creating user 'gamilit_user'..."
sudo -u postgres psql -c "CREATE USER gamilit_user WITH ENCRYPTED PASSWORD 'mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj';" 2>&1 || echo "User may already exist"

echo "[3/6] Granting privileges to gamilit_user..."
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE gamilit_platform TO gamilit_user;" 2>&1

echo "[4/6] Granting schema privileges..."
sudo -u postgres psql -d gamilit_platform -c "GRANT ALL ON SCHEMA public TO gamilit_user;" 2>&1

echo "[5/6] Installing pgcrypto extension..."
sudo -u postgres psql -d gamilit_platform -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;" 2>&1

echo "[6/6] Installing uuid-ossp extension..."
sudo -u postgres psql -d gamilit_platform -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";" 2>&1

echo ""
echo "=========================================="
echo "Database setup completed successfully!"
echo "=========================================="
echo ""
echo "Database: gamilit_platform"
echo "User: gamilit_user"
echo "Password: mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj"
echo ""
echo "Next step: Run 02_execute_ddl.sh to create tables and objects"
