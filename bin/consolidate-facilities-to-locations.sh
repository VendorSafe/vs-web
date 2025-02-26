#!/bin/bash

# Script to consolidate facilities to locations
# This script will run the data migration to move facilities data to locations

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}FACILITY TO LOCATION CONSOLIDATION${NC}"
echo "========================================================="
echo ""

# Step 1: Run the data migration
echo -e "${YELLOW}Step 1: Running Data Migration...${NC}"
bin/rails runner "
  # Count facilities before migration
  total_facilities = Facility.count
  puts \"Total facilities before migration: #{total_facilities}\"
  
  # Count locations before migration
  total_locations_before = Location.count
  puts \"Total locations before migration: #{total_locations_before}\"
  
  # Create locations from facilities
  facilities_migrated = 0
  
  Facility.find_each do |facility|
    # Create a new location from the facility
    location = Location.new(
      team_id: facility.team_id,
      name: facility.name,
      location_type: facility.other_attribute,
      address: facility.url,
      sort_order: facility.sort_order
    )
    
    if location.save
      # Create mapping
      mapping = FacilityLocationMapping.create!(
        facility_id: facility.id,
        location_id: location.id
      )
      
      # Update facility with reference to the new location
      facility.update(migrated_to_location_id: location.id)
      
      facilities_migrated += 1
      print '.' # Progress indicator
    else
      puts \"\\nError migrating facility #{facility.id}: #{location.errors.full_messages.join(', ')}\"
    end
  end
  
  # Count locations after migration
  total_locations_after = Location.count
  locations_created = total_locations_after - total_locations_before
  
  puts \"\\n\\nMigration complete!\"
  puts \"#{facilities_migrated} out of #{total_facilities} facilities migrated to locations\"
  puts \"#{locations_created} new locations created\"
  
  # Verify mappings
  total_mappings = FacilityLocationMapping.count
  puts \"#{total_mappings} facility-location mappings created\"
  
  # Verify facilities updated
  facilities_with_location_id = Facility.where.not(migrated_to_location_id: nil).count
  puts \"#{facilities_with_location_id} facilities updated with location references\"
"

# Check if the migration was successful
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Success!${NC}"
  echo "Data migration completed successfully."
  
  # Step 2: Update the application to use locations instead of facilities
  echo -e "${YELLOW}Step 2: Updating Application References...${NC}"
  echo "The following files may need to be updated to use locations instead of facilities:"
  echo "- Controllers that reference facilities"
  echo "- Views that display facilities"
  echo "- JavaScript that interacts with facilities"
  echo ""
  echo "You can use the following command to find all references to facilities:"
  echo "grep -r \"facility\" --include=\"*.rb\" --include=\"*.js\" --include=\"*.erb\" app/"
  
  echo -e "${BLUE}=========================================================${NC}"
  echo -e "${GREEN}FACILITY TO LOCATION CONSOLIDATION COMPLETE!${NC}"
  echo -e "${BLUE}=========================================================${NC}"
  echo ""
  echo -e "The following steps have been completed:"
  echo -e "1. ${GREEN}✓${NC} Migrated facility data to locations"
  echo -e "2. ${GREEN}✓${NC} Created facility-location mappings"
  echo -e "3. ${GREEN}✓${NC} Updated facilities with references to locations"
  echo ""
  echo -e "${YELLOW}Next Steps:${NC}"
  echo -e "1. Update application code to use locations instead of facilities"
  echo -e "2. Add GeoJSON data to locations"
  echo -e "3. Implement location-based features"
  echo -e "4. Deprecate facilities API"
  echo ""
  exit 0
else
  echo -e "${RED}✗ Failed!${NC}"
  echo "Data migration failed. Please check the output above for details."
  exit 1
fi