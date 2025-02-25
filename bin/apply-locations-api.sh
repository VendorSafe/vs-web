#!/bin/bash

# Script to apply the Locations API implementation
# Created as part of the Facility to Location consolidation plan

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Applying Locations API implementation...${NC}"
echo "==============================================="

# Step 1: Create backup of existing files
echo -e "${YELLOW}Creating backup of existing files...${NC}"
BACKUP_DIR="api-locations-backup-$(date +%Y%m%d%H%M%S)"
mkdir -p $BACKUP_DIR

# Check if the locations controller already exists
if [ -f app/controllers/api/v1/locations_controller.rb ]; then
  cp app/controllers/api/v1/locations_controller.rb $BACKUP_DIR/
  echo "Backed up existing locations_controller.rb"
fi

# Check if the routes file already exists
if [ -f config/routes/api/v1.rb ]; then
  cp config/routes/api/v1.rb $BACKUP_DIR/
  echo "Backed up existing v1.rb routes file"
fi

# Step 2: Apply the new controller
echo -e "${YELLOW}Applying new controller...${NC}"
mkdir -p app/controllers/api/v1
cp -f app/controllers/api/v1/locations_controller.rb app/controllers/api/v1/

# Step 3: Update the routes
echo -e "${YELLOW}Updating routes...${NC}"
mkdir -p config/routes/api

# Check if the main routes file exists
if [ -f config/routes/api/v1.rb ]; then
  # Append our routes to the existing file
  cat config/routes/api/v1_locations.rb >> config/routes/api/v1.rb
  echo "Appended locations routes to existing v1.rb file"
else
  # Create a new routes file
  cp config/routes/api/v1_locations.rb config/routes/api/v1.rb
  echo "Created new v1.rb file with locations routes"
fi

# Step 4: Run the tests
echo -e "${YELLOW}Running tests...${NC}"
bin/run-focused-locations-api-tests.sh

# Check if tests were successful
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Tests passed! The Locations API implementation has been applied successfully.${NC}"
else
  echo -e "${RED}Tests failed. Rolling back changes...${NC}"
  
  # Rollback controller
  if [ -f $BACKUP_DIR/locations_controller.rb ]; then
    cp $BACKUP_DIR/locations_controller.rb app/controllers/api/v1/
    echo "Rolled back locations_controller.rb"
  else
    rm app/controllers/api/v1/locations_controller.rb
    echo "Removed new locations_controller.rb"
  fi
  
  # Rollback routes
  if [ -f $BACKUP_DIR/v1.rb ]; then
    cp $BACKUP_DIR/v1.rb config/routes/api/
    echo "Rolled back v1.rb routes file"
  fi
  
  echo -e "${RED}Changes have been rolled back. Please fix the issues and try again.${NC}"
  exit 1
fi

echo "==============================================="
echo -e "${GREEN}Locations API implementation completed.${NC}"
echo "The following files have been updated:"
echo "- app/controllers/api/v1/locations_controller.rb"
echo "- config/routes/api/v1.rb"
echo "==============================================="
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Run the migrations to add GeoJSON support to Locations"
echo "   bin/rails db:migrate"
echo "2. Run the consolidation script to migrate Facilities to Locations"
echo "   bin/consolidate-facilities-to-locations.sh"
echo "3. Update your frontend to use the new Locations API"
echo "==============================================="