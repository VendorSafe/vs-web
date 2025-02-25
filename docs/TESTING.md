# Testing Guide

This document provides comprehensive guidance for testing the VendorSafe training platform, following Bullet Train conventions.

Last updated: February 24, 2025

## Setup and Maintenance

### Resetting Dependencies
If you encounter any issues with dependencies or need a clean environment:

```bash
# Reset all dependencies and rebuild
bin/reset-dependencies

# This script will:
# 1. Remove all JavaScript and Ruby dependencies
# 2. Clear all caches (Rails, Yarn, Assets)
# 3. Reinstall all dependencies
# 4. Rebuild assets
```

## Test Types

### 1. System Tests
System tests verify the application's behavior from end-to-end using a real browser environment.

```bash
# Run all system tests (headless)
rails test:system

# Run specific system test file
rails test test/system/training_player_test.rb

# Run specific test case
rails test test/system/training_player_test.rb -n test_completing_video_module
```

Key features:
- Headless Chrome by default
- Real browser simulation
- JavaScript execution
- Asset compilation
- Database interactions

### 2. Model Tests
Model tests verify business logic, validations, and relationships.

```bash
# Run all model tests
rails test:models

# Run specific model test
rails test test/models/training_program_test.rb
```

Areas covered:
- Validations
- Associations
- Callbacks
- State machines
- Business logic
- Scopes

### 3. Controller Tests
Controller tests verify API endpoints and request handling.

```bash
# Run all controller tests
rails test:controllers

# Run specific controller test
rails test test/controllers/training_programs_controller_test.rb
```

Verifies:
- Response codes
- JSON structures
- Authorization
- Parameter handling
- Session management

### 4. Integration Tests
Integration tests verify interactions between different parts of the application.

```bash
# Run all integration tests
rails test:integration

# Run specific integration test
rails test test/integration/training_flow_test.rb
```

Covers:
- Multi-step processes
- Cross-model interactions
- Complex workflows

## Test Modes

### Headless Mode (Default)
Runs tests without visible browser window:
```bash
rails test:system
```

### Browser Mode
Opens Chrome for visual debugging:
```bash
OPEN_BROWSER=1 rails test:system
```

### Debug Mode
Opens Chrome DevTools:
```bash
OPEN_BROWSER=1 CHROME_DEBUG=1 rails test:system
```

## Test Configuration

### Environment Variables
- `OPEN_BROWSER`: Opens Chrome browser (default: false)
- `CHROME_DEBUG`: Opens DevTools (default: false)
- `SAVE_SCREENSHOTS`: Saves failure screenshots (default: false)
- `COVERAGE`: Generates coverage report (default: false)
- `PARALLEL_WORKERS`: Number of parallel processes (default: CPU cores)

### Test Data

#### Factories
Located in `test/factories/`:
```ruby
# Create basic training program
program = create(:training_program)

# Create program with contents
program = create(:training_program, :with_contents)

# Create completed training
program = create(:training_program, :completed)
```

#### Fixtures
Located in `test/fixtures/`:
- `files/`: Test media files
- `vcr_cassettes/`: HTTP interaction recordings

## Running Tests

### Full Test Suite
```bash
# Run all tests
rails test:all

# With coverage report
COVERAGE=1 rails test:all
```

### Specific Components
```bash
# Run only model tests
rails test:models

# Run only system tests
rails test:system

# Run only controller tests
rails test:controllers
```

### Debugging Tests

#### Visual Debugging
```bash
# Open browser
OPEN_BROWSER=1 rails test:system

# Open DevTools
OPEN_BROWSER=1 CHROME_DEBUG=1 rails test:system

# Save screenshots
SAVE_SCREENSHOTS=1 rails test:system
```

#### Console Debugging
```bash
# Run specific test with debugging
rails test test/system/training_player_test.rb --verbose
```

### Test Coverage

Generate coverage report:
```bash
COVERAGE=1 rails test:all
open coverage/index.html
```

Coverage groups:
- Controllers
- Models
- Components
- Stores
- Helpers

## Best Practices

### 1. Writing Tests
- Follow Arrange-Act-Assert pattern
- Use meaningful descriptions
- Keep tests focused and atomic
- Use appropriate assertions
- Mock external services

### 2. Test Data
- Use factories for flexible test data
- Keep fixtures minimal
- Use traits for variations
- Clean up after tests

### 3. System Tests
- Use semantic selectors
- Handle asynchronous operations
- Check for proper state changes
- Verify UI feedback

### 4. Performance
- Use headless mode for CI
- Parallelize when possible
- Mock external services
- Use database cleaner

## Common Issues

### 1. Dependency Issues
If you encounter any dependency-related issues:

1. Reset all dependencies:
```bash
bin/reset-dependencies
```

2. If issues persist, check:
- Node.js and Yarn versions
- Ruby version and gemset
- Asset compilation errors
- Cache corruption

### 2. Browser Tests
- Check Chrome version
- Verify window size
- Clear browser state
- Check JavaScript console

### 3. Coverage
- Exclude irrelevant files
- Check uncovered lines
- Add missing test cases
- Update coverage thresholds

## CI Integration

### GitHub Actions
```yaml
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v2
    - name: Reset dependencies
      run: bin/reset-dependencies
    - name: Run tests
      run: bundle exec rails test:all
```

### Test Artifacts
- Screenshots from failed tests
- Coverage reports
- Test logs
- Performance metrics

## Bullet Train Integration

The testing approach follows Bullet Train conventions:

### 1. System Test Helpers
- Uses Bullet Train's system test helpers
- Leverages authentication helpers
- Uses factory definitions
- Follows test organization patterns

### 2. Test Data Generation
- Uses FactoryBot for test data
- Follows Bullet Train's factory patterns
- Leverages traits for variations
- Uses realistic test data

### 3. Test Organization
- Tests are organized by type
- System tests verify user workflows
- Model tests verify business logic
- Controller tests verify API endpoints

### 4. CI/CD Integration
- Tests run on every pull request
- Coverage reports are generated
- Screenshots are saved for failures
- Performance metrics are tracked