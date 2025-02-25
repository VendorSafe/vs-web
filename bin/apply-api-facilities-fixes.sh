#!/bin/bash

# Script to apply API controller and route fixes for Facilities
# Created as part of the 10-step process for addressing API controller issues

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Applying API controller and route fixes for Facilities...${NC}"
echo "==============================================="

# Create backup directory
BACKUP_DIR="api-facilities-fixes-backup-$(date +%Y%m%d%H%M%S)"
mkdir -p $BACKUP_DIR

# Backup original files
echo -e "${YELLOW}Backing up original files...${NC}"
cp config/routes/api/v1.rb $BACKUP_DIR/
cp app/controllers/api/v1/facilities_controller.rb $BACKUP_DIR/

# Apply route fixes
echo -e "${YELLOW}Applying route fixes...${NC}"
cp config/routes/api/v1_facilities_fixed.rb config/routes/api/v1.rb

# Apply controller fixes
echo -e "${YELLOW}Applying controller fixes...${NC}"
cp app/controllers/api/v1/facilities_controller_fixed.rb app/controllers/api/v1/facilities_controller.rb

# Run the tests
echo -e "${YELLOW}Running tests to verify fixes...${NC}"
bin/rails test test/controllers/api/v1/focused_facilities_controller_test.rb -v

# Output a clear result without requiring user interaction
echo ""
echo -e "${YELLOW}Test Results Summary:${NC}"
echo "==============================================="
echo -e "${GREEN}✓${NC} Applied fixes to API routes in config/routes/api/v1.rb"
echo -e "${GREEN}✓${NC} Applied fixes to FacilitiesController"
echo -e "${YELLOW}!${NC} Check test results above to see if fixes were successful"
echo "==============================================="
echo -e "${GREEN}RESULT: API_FACILITIES_FIXES_APPLIED${NC}"
echo "Backup files are available in $BACKUP_DIR if needed."
echo "To restore the original files, run:"
echo "cp $BACKUP_DIR/v1.rb config/routes/api/v1.rb"
echo "cp $BACKUP_DIR/facilities_controller.rb app/controllers/api/v1/facilities_controller.rb"

echo "==============================================="
echo -e "${YELLOW}Process complete.${NC}"