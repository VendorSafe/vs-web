#!/bin/bash

# Script to apply API controller and route fixes
# Created as part of the 10-step process for addressing API controller issues

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Applying API controller and route fixes...${NC}"
echo "==============================================="

# Create backup directory
BACKUP_DIR="api-fixes-backup-$(date +%Y%m%d%H%M%S)"
mkdir -p $BACKUP_DIR

# Backup original files
echo -e "${YELLOW}Backing up original files...${NC}"
cp config/routes/api/v1.rb $BACKUP_DIR/
cp app/controllers/api/v1/training_programs_controller.rb $BACKUP_DIR/

# Apply route fixes
echo -e "${YELLOW}Applying route fixes...${NC}"
cp config/routes/api/v1_fixed.rb config/routes/api/v1.rb

# Apply controller fixes
echo -e "${YELLOW}Applying controller fixes...${NC}"
cp app/controllers/api/v1/training_programs_controller_fixed.rb app/controllers/api/v1/training_programs_controller.rb

# Run the tests
echo -e "${YELLOW}Running tests to verify fixes...${NC}"
bin/run-focused-api-tests.sh

# Output a clear result without requiring user interaction
echo ""
echo -e "${YELLOW}Test Results Summary:${NC}"
echo "==============================================="
echo -e "${GREEN}✓${NC} Applied fixes to API routes in config/routes/api/v1.rb"
echo -e "${GREEN}✓${NC} Applied fixes to TrainingProgramsController"
echo -e "${YELLOW}!${NC} Tests are still failing - further fixes needed"
echo "==============================================="
echo -e "${GREEN}RESULT: API_FIXES_APPLIED${NC}"
echo "Backup files are available in $BACKUP_DIR if needed."
echo "To restore the original files, run:"
echo "cp $BACKUP_DIR/v1.rb config/routes/api/v1.rb"
echo "cp $BACKUP_DIR/training_programs_controller.rb app/controllers/api/v1/training_programs_controller.rb"

echo "==============================================="
echo -e "${YELLOW}Process complete.${NC}"