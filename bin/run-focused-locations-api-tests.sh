#!/bin/bash
#!/bin/bash

# Script to run focused tests for the Locations API
# This script will run the tests for the Locations API endpoints

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running focused tests for Locations API...${NC}"
echo "==============================================="

# Run the tests
bin/rails test test/controllers/api/v1/focused_locations_controller_test.rb -v

# Check if tests passed
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Success!${NC}"
  echo "All tests passed. The Locations API implementation is working correctly."
  exit 0
else
  echo -e "${RED}✗ Failed!${NC}"
  echo "Some tests failed. Please check the output above for details."
  exit 1
fi

# Script to run the focused tests for the Locations API
# Created as part of the Facility to Location consolidation plan

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running focused tests for Locations API...${NC}"
echo "==============================================="

# Run the focused test
bin/rails test test/controllers/api/v1/focused_locations_controller_test.rb -v

# Check if tests were successful
if [ $? -eq 0 ]; then
  echo -e "${GREEN}All tests passed!${NC}"
else
  echo -e "${RED}Some tests failed. Please check the output above for details.${NC}"
  exit 1
fi

echo "==============================================="
echo -e "${GREEN}Focused tests for Locations API completed.${NC}"
echo "==============================================="