#!/bin/bash

# Master script to implement the Facility to Location consolidation
# This script will run all the necessary steps to complete the implementation

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================================${NC}"
echo -e "${BLUE}  FACILITY TO LOCATION CONSOLIDATION IMPLEMENTATION      ${NC}"
echo -e "${BLUE}=========================================================${NC}"
echo ""

# Function to check if a step was successful
check_success() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Success!${NC}"
    echo ""
  else
    echo -e "${RED}✗ Failed!${NC}"
    echo -e "${RED}Implementation stopped due to errors. Please fix the issues and try again.${NC}"
    exit 1
  fi
}

# Step 1: Install the GeoJSON Fields Gem
echo -e "${YELLOW}Step 1: Installing GeoJSON Fields Gem...${NC}"
bin/install-geojson-fields-gem.sh
check_success

# Step 2: Run the Database Migrations
echo -e "${YELLOW}Step 2: Running Database Migrations...${NC}"
# Skip ERD generation to avoid the Version constant issue
DISABLE_ERD=true bin/rails db:migrate
check_success

# Step 3: Apply the Locations API Implementation
echo -e "${YELLOW}Step 3: Applying Locations API Implementation...${NC}"
bin/apply-locations-api.sh
check_success

# Step 4: Perform the Data Migration
echo -e "${YELLOW}Step 4: Performing Data Migration...${NC}"
bin/consolidate-facilities-to-locations.sh
check_success

# Step 5: Run the Focused Tests
echo -e "${YELLOW}Step 5: Running Focused Tests...${NC}"
bin/run-focused-locations-api-tests.sh
check_success

# Step 6: Update the main API tests script to include the locations tests
echo -e "${YELLOW}Step 6: Updating Main API Tests Script...${NC}"

if grep -q "focused_locations_controller_test.rb" bin/run-focused-api-tests.sh; then
  echo "Locations tests already included in main API tests script."
else
  # Add the locations tests to the main API tests script
  sed -i '' 's/bin\/rails test test\/controllers\/api\/v1\/focused_facilities_controller_test.rb/bin\/rails test test\/controllers\/api\/v1\/focused_facilities_controller_test.rb test\/controllers\/api\/v1\/focused_locations_controller_test.rb/' bin/run-focused-api-tests.sh
  echo "Added locations tests to main API tests script."
fi
check_success

echo -e "${BLUE}=========================================================${NC}"
echo -e "${GREEN}FACILITY TO LOCATION CONSOLIDATION IMPLEMENTATION COMPLETE!${NC}"
echo -e "${BLUE}=========================================================${NC}"
echo ""
echo -e "The following steps have been completed:"
echo -e "1. ${GREEN}✓${NC} Installed GeoJSON Fields Gem"
echo -e "2. ${GREEN}✓${NC} Ran Database Migrations"
echo -e "3. ${GREEN}✓${NC} Applied Locations API Implementation"
echo -e "4. ${GREEN}✓${NC} Performed Data Migration"
echo -e "5. ${GREEN}✓${NC} Ran Focused Tests"
echo -e "6. ${GREEN}✓${NC} Updated Main API Tests Script"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "Please refer to the detailed next steps document for the remaining tasks:"
echo -e "${BLUE}docs/NEXT-STEPS-FACILITY-TO-LOCATION.md${NC}"
echo ""
echo -e "The key remaining tasks are:"
echo -e "1. Update Location Forms with GeoJSON support"
echo -e "2. Add Map Visualization"
echo -e "3. Update Navigation and Routes"
echo -e "4. Deprecate Facilities API"
echo -e "5. Create System Tests"
echo -e "6. Update Documentation"
echo -e "7. Prepare GeoJSON Fields Gem for Contribution"
echo ""
echo -e "${BLUE}=========================================================${NC}"