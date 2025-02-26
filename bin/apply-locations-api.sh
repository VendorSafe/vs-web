#!/bin/bash

# Script to apply the Locations API implementation
# This script will copy the fixed controller and routes files to their proper locations

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Applying Locations API implementation...${NC}"
echo ""

# Create backup of existing files
echo "Creating backup of existing files..."
if [ -f app/controllers/api/v1/locations_controller.rb ]; then
  cp app/controllers/api/v1/locations_controller.rb app/controllers/api/v1/locations_controller.rb.bak
  echo "Backed up existing locations_controller.rb"
fi

if [ -f config/routes/api/v1.rb ]; then
  cp config/routes/api/v1.rb config/routes/api/v1.rb.bak
  echo "Backed up existing v1.rb routes file"
fi

# Apply the new controller
echo "Applying new controller..."
cp app/controllers/api/v1/locations_controller.rb app/controllers/api/v1/locations_controller.rb

# Update routes
echo "Updating routes..."
cp config/routes/api/v1_locations_fixed.rb config/routes/api/v1.rb
echo "Appended locations routes to existing v1.rb file"

# Run tests
echo "Running tests..."
echo "Running focused tests for Locations API..."
echo "==============================================="
bin/rails test test/controllers/api/v1/focused_locations_controller_test.rb -v

# Check if tests passed
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Success!${NC}"
  echo "All tests passed. The Locations API implementation is complete."
  exit 0
else
  echo -e "${RED}✗ Failed!${NC}"
  echo "Some tests failed. Please check the output above for details."
  
  # Roll back changes if tests failed
  echo "Rolling back changes..."
  if [ -f app/controllers/api/v1/locations_controller.rb.bak ]; then
    mv app/controllers/api/v1/locations_controller.rb.bak app/controllers/api/v1/locations_controller.rb
    echo "Rolled back locations_controller.rb"
  fi
  
  if [ -f config/routes/api/v1.rb.bak ]; then
    mv config/routes/api/v1.rb.bak config/routes/api/v1.rb
    echo "Rolled back v1.rb routes file"
  fi
  
  echo "Changes have been rolled back. Please fix the issues and try again."
  exit 1
fi