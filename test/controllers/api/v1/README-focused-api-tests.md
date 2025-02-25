# Focused API Tests

This directory contains focused test files for API controllers that follow the 10-step testing process outlined in the golden rules.

## Purpose

These focused test files are designed to:

1. Isolate specific API controller issues
2. Test happy paths, edge cases, and error conditions
3. Verify authentication and authorization
4. Ensure proper response formats
5. Provide a clear path for fixing API controller issues

## Test Files

- `focused_training_programs_controller_test.rb`: Tests for the TrainingPrograms API endpoints
  - Tests basic CRUD operations
  - Tests authentication and authorization
  - Tests progress tracking and certificate generation
  - Tests edge cases and error conditions

## Running the Tests

You can run the focused tests using the provided script:

```bash
bin/run-focused-api-tests.sh
```

Or run individual test files directly:

```bash
bin/rails test test/controllers/api/v1/focused_training_programs_controller_test.rb
```

To run a specific test:

```bash
bin/rails test test/controllers/api/v1/focused_training_programs_controller_test.rb -n test_should_get_index_with_proper_authentication
```

## Adding New Focused Tests

When adding new focused test files:

1. Create a new file with the naming convention `focused_[controller_name]_controller_test.rb`
2. Follow the 10-step testing process:
   - Test happy paths first
   - Then test edge cases
   - Then test error conditions
3. Update the `bin/run-focused-api-tests.sh` script to include the new test file
4. Document the new test file in this README

## Fixing API Controller Issues

Once the focused tests are passing, apply the fixes to the original controller and test files:

1. Fix routing issues
2. Fix authentication and authorization
3. Fix controller implementations
4. Fix serialization issues
5. Run the original tests to verify the fixes

## Relationship to Original Tests

These focused tests are not meant to replace the original tests, but to provide a more focused approach to fixing the issues. Once the issues are fixed, the original tests should pass.

The original tests are located in the same directory with the naming convention `[controller_name]_controller_test.rb`.