#!/bin/bash
# Execute all DDL files in correct order
# This script executes the database schema DDL files for GAMILIT Platform
#
# NOTE: This script is a wrapper that calls the comprehensive install-all.sh script
# from the backup-ddl/setup directory, which handles the complete installation
# including schemas, tables, functions, triggers, views, and RLS policies.

set -e

# Configuration
SETUP_DIR="/home/isem/workspace/workspace-gamilit/docs/03-desarrollo/base-de-datos/backup-ddl/setup"
INSTALL_SCRIPT="${SETUP_DIR}/install-all.sh"
LOG_FILE="/home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/logs/ddl_execution.log"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="  | tee -a "$LOG_FILE"
echo "GAMILIT Platform DDL Execution"               | tee -a "$LOG_FILE"
echo "=========================================="  | tee -a "$LOG_FILE"
echo "Start time: $(date)"                      | tee -a "$LOG_FILE"
echo ""                                          | tee -a "$LOG_FILE"

# Check if install-all.sh exists
if [ ! -f "$INSTALL_SCRIPT" ]; then
   echo -e "${RED}ERROR: Installation script not found: $INSTALL_SCRIPT${NC}" | tee -a "$LOG_FILE"
   echo "Please ensure the backup-ddl/setup directory exists" | tee -a "$LOG_FILE"
   exit 1
fi

# Check if config.md exists (created by db-setup.sh)
if [ ! -f "${SETUP_DIR}/config.md" ]; then
   echo -e "${RED}ERROR: Configuration file not found: ${SETUP_DIR}/config.md${NC}" | tee -a "$LOG_FILE"
   echo "Please run 01_manual_db_setup.sh first to create the database and user" | tee -a "$LOG_FILE"
   exit 1
fi

echo -e "${GREEN}[INFO]${NC} Using comprehensive installation script" | tee -a "$LOG_FILE"
echo -e "${GREEN}[INFO]${NC} Script location: $INSTALL_SCRIPT" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Execute the comprehensive installation script
echo -e "${GREEN}[INFO]${NC} Executing install-all.sh..." | tee -a "$LOG_FILE"
cd "$SETUP_DIR"

if bash "$INSTALL_SCRIPT" 2>&1 | tee -a "$LOG_FILE"; then
    echo ""
    echo "=========================================="  | tee -a "$LOG_FILE"
    echo -e "${GREEN}DDL Execution Completed Successfully${NC}" | tee -a "$LOG_FILE"
    echo "=========================================="  | tee -a "$LOG_FILE"
else
    echo ""
    echo "=========================================="  | tee -a "$LOG_FILE"
    echo -e "${RED}DDL Execution Failed${NC}" | tee -a "$LOG_FILE"
    echo "=========================================="  | tee -a "$LOG_FILE"
    exit 1
fi

echo "End time: $(date)"                        | tee -a "$LOG_FILE"
echo ""                                          | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE"
echo ""
echo -e "${GREEN}Next step: Run db-validate.sh to verify the setup${NC}"
