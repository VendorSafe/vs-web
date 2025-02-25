#!/bin/bash

# Script to run focused API controller tests
# Created as part of the 10-step process for addressing API controller issues

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running focused API controller tests...${NC}"
echo "==============================================="

# Run the focused test file for TrainingPrograms API
echo -e "${YELLOW}Running TrainingPrograms API tests...${NC}"
bin/rails test test/controllers/api/v1/focused_training_programs_controller_test.rb -v

# Check the exit code
if [ $? -eq 0 ]; then
  echo -e "${GREEN}TrainingPrograms API tests passed!${NC}"
else
  echo -e "${RED}TrainingPrograms API tests failed.${NC}"
  echo "Please check the output above for details."
fi

# Run the focused test file for TrainingQuestions API
echo -e "${YELLOW}Running TrainingQuestions API tests...${NC}"
bin/rails test test/controllers/api/v1/focused_training_questions_controller_test.rb -v

# Check the exit code
if [ $? -eq 0 ]; then
  echo -e "${GREEN}TrainingQuestions API tests passed!${NC}"
else
  echo -e "${RED}TrainingQuestions API tests failed.${NC}"
  echo "Please check the output above for details."
fi

# Run the focused test file for TrainingContents API
echo -e "${YELLOW}Running TrainingContents API tests...${NC}"
bin/rails test test/controllers/api/v1/focused_training_contents_controller_test.rb -v

# Check the exit code
if [ $? -eq 0 ]; then
  echo -e "${GREEN}TrainingContents API tests passed!${NC}"
else
  echo -e "${RED}TrainingContents API tests failed.${NC}"
  echo "Please check the output above for details."
fi

echo "==============================================="
echo -e "${YELLOW}Test run complete.${NC}"

# Add more focused test files here as they are created
# Example:
# echo -e "${YELLOW}Running Facilities API tests...${NC}"
# bin/rails test test/controllers/api/v1/focused_facilities_controller_test.rb -v