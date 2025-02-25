#!/bin/bash

# Script to run the migrations and perform the consolidation of Facilities to Locations
# Created as part of the Facility to Location consolidation plan

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting Facility to Location consolidation...${NC}"
echo "==============================================="

# Step 1: Run the migrations
echo -e "${YELLOW}Running migrations...${NC}"
bin/rails db:migrate

# Check if migrations were successful
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Migrations completed successfully.${NC}"
else
  echo -e "${RED}Migrations failed. Please check the output above for details.${NC}"
  exit 1
fi

# Step 2: Run a Rails task to verify the data migration
echo -e "${YELLOW}Verifying data migration...${NC}"
bin/rails runner "puts \"Total facilities: #{Facility.count}\"; puts \"Migrated facilities: #{Facility.migrated.count}\"; puts \"Locations created: #{Location.count}\""

# Step 3: Run a Rails task to migrate any remaining facilities
echo -e "${YELLOW}Migrating any remaining facilities...${NC}"
bin/rails runner "Facility.not_migrated.find_each { |f| f.migrate_to_location; print '.' }; puts; puts \"#{Facility.migrated.count} facilities now migrated.\""

# Step 4: Output statistics
echo -e "${YELLOW}Migration statistics:${NC}"
bin/rails runner "puts \"Total facilities: #{Facility.count}\"; puts \"Migrated facilities: #{Facility.migrated.count}\"; puts \"Locations: #{Location.count}\"; puts \"Facility-Location mappings: #{FacilityLocationMapping.count}\""

echo "==============================================="
echo -e "${GREEN}Facility to Location consolidation completed.${NC}"
echo "You can now start using the Location model with GeoJSON support."
echo "The Facility model is now deprecated but still available during the transition period."
echo "==============================================="
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update your controllers to use Locations instead of Facilities"
echo "2. Update your views to use the new Location model"
echo "3. Update your tests to reflect the changes"
echo "4. Run the test suite to ensure everything is working correctly"
echo "==============================================="