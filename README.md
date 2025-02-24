# Training Program Application

## Running Tests

### System Tests

The training program system tests can be run in two modes:

1. Headless Mode (Default):
```bash
rails test:system
```

2. Browser Mode (for debugging):
```bash
OPEN_BROWSER=1 rails test:system
```

Additional test options:
- `CHROME_DEBUG=1`: Opens Chrome DevTools automatically
- `SAVE_SCREENSHOTS=1`: Saves screenshots on test failures
- `PARALLEL_WORKERS=1`: Runs tests sequentially (useful for debugging)

Examples:
```bash
# Run specific test file in browser mode
OPEN_BROWSER=1 rails test test/system/training_player_test.rb

# Run specific test with debugging
OPEN_BROWSER=1 CHROME_DEBUG=1 rails test test/system/training_player_test.rb -n test_completing_video_module

# Run all tests with screenshots
SAVE_SCREENSHOTS=1 rails test:system
```

### Test Structure

The test suite includes:

1. System Tests (`test/system/`)
   - Training player integration tests
   - User interaction simulations
   - Browser compatibility tests
   - Responsive design tests

2. Model Tests (`test/models/`)
   - Training program business logic
   - Progress tracking
   - Certificate generation
   - State management

3. Controller Tests (`test/controllers/`)
   - API endpoints
   - Progress updates
   - Authorization checks

4. Factory Definitions (`test/factories/`)
   - Training program factories
   - Content type factories
   - Progress tracking factories
   - Certificate factories

### Test Data

Sample data is provided for testing:
- `test/fixtures/files/sample.mp4.example`: Sample video for testing
- Factory definitions for all models
- VCR cassettes for external service mocking

### Development Workflow

1. Write tests first (TDD approach)
2. Run in headless mode for quick feedback
3. Use browser mode for debugging UI issues
4. Save screenshots for UI regression testing
5. Use Chrome DevTools for JavaScript debugging

### Continuous Integration

The test suite is configured for CI environments:
- Runs in headless mode by default
- Parallel test execution
- Test coverage reporting
- Screenshot artifacts for failed tests

### Best Practices

1. Always run tests before pushing:
```bash
rails test:all
```

2. Check test coverage:
```bash
COVERAGE=1 rails test:all
open coverage/index.html
```

3. Update test data when adding features:
- Add new factories
- Update sample files
- Record new VCR cassettes

4. Debug failing tests:
```bash
OPEN_BROWSER=1 PARALLEL_WORKERS=1 rails test:system
```

### Common Issues

1. Flaky Tests
   - Use `wait_for_ajax` helper
   - Increase Capybara wait time
   - Run tests sequentially

2. Video Playback
   - Ensure sample video exists
   - Check video format support
   - Verify JavaScript events

3. Screenshots
   - Check tmp/screenshots directory
   - Verify browser window size
   - Check CSS rendering

4. Browser Mode
   - Port conflicts
   - Chrome process cleanup
   - DevTools connection
