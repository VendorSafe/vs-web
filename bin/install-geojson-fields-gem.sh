#!/bin/bash
#!/bin/bash

# Script to install the GeoJSON fields gem
# This script will install the GeoJSON fields gem and set up the necessary configurations

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "Installing GeoJSON fields gem..."
echo "==============================================="

# Step 1: Add the gem to the Gemfile
echo "Adding gem to Gemfile..."
if grep -q "bullet_train-fields-geojson" Gemfile; then
  echo "Gem already exists in Gemfile. Skipping..."
else
  echo "gem 'bullet_train-fields-geojson', path: 'lib/bullet_train/fields/geojson'" >> Gemfile
  echo "Added gem to Gemfile."
fi

# Step 2: Install the gem
echo "Installing gem..."
bundle install
if [ $? -eq 0 ]; then
  echo "Gem installed successfully."
else
  echo "Failed to install gem. Please check the output above for details."
  exit 1
fi

# Step 3: Register the Stimulus controllers
echo "Registering Stimulus controllers..."
if grep -q "bullet_train/fields/geojson/map_input_controller" app/javascript/controllers/index.js; then
  echo "Stimulus controllers already registered. Skipping..."
else
  # Add the import statements
  sed -i '' '/import { application } from "controllers\/application"/a\\
import MapInputController from "bullet_train/fields/geojson/map_input_controller"\
application.register("map-input", MapInputController)\
\
import MapDisplayController from "bullet_train/fields/geojson/map_display_controller"\
application.register("map-display", MapDisplayController)
' app/javascript/controllers/index.js
  echo "Registered Stimulus controllers."
fi

# Step 4: Check for Mapbox API key
echo "Checking for Mapbox API key..."
if grep -q "MAPBOX_API_KEY" config/application.yml; then
  echo "Mapbox API key already exists in environment. Skipping..."
else
  echo "MAPBOX_API_KEY: 'pk.your_mapbox_api_key_here'" >> config/application.yml
  echo "Added Mapbox API key placeholder to environment. Please replace with your actual API key."
fi

# Step 5: Create a test location with GeoJSON data
echo "Creating a test location with GeoJSON data..."
bin/rails runner "
  begin
    # Create a test team if none exists
    team = Team.first || Team.create!(name: 'Test Team')
    
    # Create a test location with GeoJSON data
    location = Location.create!(
      team: team,
      name: 'Test Location',
      location_type: 'office',
      geometry: {
        type: 'Point',
        coordinates: [-122.4194, 37.7749]
      }
    )
    
    puts \"Created test location with GeoJSON data: \#{location.name}\"
  rescue => e
    puts \"Error creating test location: \#{e.message}\"
  end
"

echo "==============================================="
echo "GeoJSON fields gem installation complete."
echo "You can now use the GeoJSON field in your models:"
echo ""
echo "class YourModel < ApplicationRecord"
echo "  has_geojson_field :geometry, validate_format: true"
echo "end"
echo ""
echo "And in your views:"
echo ""
echo "<%= render 'fields/geojson/field', form: form, method: :geometry %>"
echo ""
echo "==============================================="

# Script to install the GeoJSON fields gem in the application
# Created as part of the Facility to Location consolidation plan

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Installing GeoJSON fields gem...${NC}"
echo "==============================================="

# Step 1: Add the gem to the Gemfile
echo -e "${YELLOW}Adding gem to Gemfile...${NC}"

# Check if the gem is already in the Gemfile
if grep -q "bullet_train-fields-geojson" Gemfile; then
  echo -e "${YELLOW}Gem already exists in Gemfile. Skipping...${NC}"
else
  # Add the gem to the Gemfile
  echo "
# GeoJSON fields for Bullet Train
gem 'bullet_train-fields-geojson', path: 'lib/bullet_train/fields/geojson'" >> Gemfile
  
  echo -e "${GREEN}Added gem to Gemfile.${NC}"
fi

# Step 2: Install the gem
echo -e "${YELLOW}Installing gem...${NC}"
bundle install

# Check if bundle install was successful
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Gem installed successfully.${NC}"
else
  echo -e "${RED}Failed to install gem. Please check the output above for details.${NC}"
  exit 1
fi

# Step 3: Register the Stimulus controllers
echo -e "${YELLOW}Registering Stimulus controllers...${NC}"

# Check if the controllers are already registered
if grep -q "bullet_train--fields--geojson--map-input" app/javascript/controllers/index.js; then
  echo -e "${YELLOW}Controllers already registered. Skipping...${NC}"
else
  # Add the controllers to the index.js file
  echo "
// GeoJSON field controllers
import MapInputController from './bullet_train/fields/geojson/map_input_controller'
import MapDisplayController from './bullet_train/fields/geojson/map_display_controller'
application.register('bullet-train--fields--geojson--map-input', MapInputController)
application.register('bullet-train--fields--geojson--map-display', MapDisplayController)" >> app/javascript/controllers/index.js
  
  echo -e "${GREEN}Registered Stimulus controllers.${NC}"
fi

# Step 4: Add Mapbox API key to environment
echo -e "${YELLOW}Checking for Mapbox API key...${NC}"

# Check if the API key is already in the environment
if grep -q "MAPBOX_API_KEY" config/application.yml; then
  echo -e "${YELLOW}Mapbox API key already exists in environment. Skipping...${NC}"
else
  # Prompt for Mapbox API key
  echo -e "${YELLOW}Please enter your Mapbox API key (or press Enter to skip):${NC}"
  read -p "> " mapbox_api_key
  
  if [ -n "$mapbox_api_key" ]; then
    # Add the API key to the environment
    echo "
# Mapbox API key for GeoJSON fields
MAPBOX_API_KEY: \"$mapbox_api_key\"" >> config/application.yml
    
    echo -e "${GREEN}Added Mapbox API key to environment.${NC}"
  else
    echo -e "${YELLOW}Skipping Mapbox API key. You can add it later in config/application.yml.${NC}"
  fi
fi

# Step 5: Create a test location with GeoJSON data
echo -e "${YELLOW}Creating a test location with GeoJSON data...${NC}"

# Run a Rails task to create a test location
bin/rails runner "
begin
  team = Team.first
  
  if team
    location = team.locations.create!(
      name: 'Test GeoJSON Location',
      location_type: 'office',
      address: '123 Main St, San Francisco, CA',
      geometry: {
        type: 'Point',
        coordinates: [-122.4194, 37.7749]
      }
    )
    
    puts \"Created test location: \#{location.name} with GeoJSON data\"
  else
    puts \"No teams found. Please create a team first.\"
  end
rescue => e
  puts \"Error creating test location: \#{e.message}\"
end
"

echo "==============================================="
echo -e "${GREEN}GeoJSON fields gem installation complete.${NC}"
echo "You can now use the GeoJSON field in your models:"
echo "
class YourModel < ApplicationRecord
  has_geojson_field :geometry, validate_format: true
end
"
echo "And in your views:"
echo "
<%= render 'fields/geojson/field', form: form, method: :geometry %>
"
echo "==============================================="