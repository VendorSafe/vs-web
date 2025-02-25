# Golden Rules for Development

This document outlines key development guidelines and lessons learned to ensure consistency and avoid common pitfalls in the VendorSafe training platform.

Last updated: February 25, 2025

## Database and Model Naming Conventions

### 1. State Management Column Naming

**Rule**: Always use consistent column names between database schema and workflow gems.

**Example Issue**: In the TrainingProgram model, we defined `workflow_column :workflow_state` but the actual database column was named `state`.

```ruby
# INCORRECT
include Workflow
workflow_column :workflow_state  # Does not match database column name

# CORRECT
include Workflow
workflow_column :state  # Matches the actual database column name
```

**Why It's Good**:
- Prevents runtime errors when the model tries to access a non-existent column
- Makes code more maintainable and easier to understand
- Follows the principle of least surprise
- Reduces debugging time for state-related issues

**Why It's Bad When Violated**:
- Causes cryptic errors like `undefined method 'workflow_state'`
- Creates confusion between what's in the database vs. what's in the code
- Makes tests fail in non-obvious ways
- Requires knowledge of both the database schema and the model implementation

### 2. Frontend-Backend Naming Consistency

**Rule**: Use consistent naming conventions between frontend (Vue.js) and backend (Rails) components.

**Example**:
```javascript
// INCONSISTENT
// Vue.js component property
data() {
  return {
    workflowState: 'draft'  // Different from Rails model column 'state'
  }
}

// CONSISTENT
// Vue.js component property
data() {
  return {
    state: 'draft'  // Matches Rails model column 'state'
  }
}
```

**Why It's Good**:
- Reduces cognitive load when switching between frontend and backend code
- Makes API integration more intuitive
- Simplifies data mapping between frontend and backend
- Easier for new developers to understand the system

**Why It's Bad When Violated**:
- Creates confusion about what properties map to what database columns
- Increases the chance of mapping errors in API requests/responses
- Makes the codebase harder to maintain
- Requires mental translation between different naming conventions

## Testing Best Practices

### 1. Factory Data Consistency

**Rule**: Ensure factory definitions match the current database schema and model validations.

**Example**:
```ruby
# INCORRECT
factory :training_program do
  workflow_state { 'draft' }  # Using wrong column name
end

# CORRECT
factory :training_program do
  state { 'draft' }  # Using correct column name
end
```

**Why It's Good**:
- Tests accurately reflect production behavior
- Prevents false positives/negatives in tests
- Makes test setup more reliable
- Reduces debugging time for test failures

**Why It's Bad When Violated**:
- Tests may pass locally but fail in CI
- Creates confusion about what's actually being tested
- Makes it harder to diagnose test failures
- Can lead to production bugs if tests don't accurately reflect real conditions

### 2. Test Environment Isolation

**Rule**: Ensure tests are isolated and don't depend on external state or other tests.

**Example**:
```ruby
# INCORRECT
test "completing a module" do
  # Assumes another test has already set up the program
  visit account_team_training_program_player_path(@team, @program)
end

# CORRECT
test "completing a module" do
  # Sets up everything needed for this specific test
  @program = create(:training_program, state: 'published')
  visit account_team_training_program_player_path(@team, @program)
end
```

**Why It's Good**:
- Tests can be run in any order
- Test failures are easier to diagnose
- Tests are more reliable and less flaky
- Prevents cascading failures when one test breaks

**Why It's Bad When Violated**:
- Tests become interdependent
- Test failures are harder to diagnose
- Tests may be flaky or inconsistent
- Changes to one test can break others

### 3. Focused Testing

**Rule**: Run specific, focused tests when debugging issues rather than the entire test suite.

**Example**:
```bash
# INEFFICIENT
# Running the entire test suite when debugging a specific issue
bin/rails test

# EFFICIENT
# Running a specific test file
bin/rails test test/models/training_program_test.rb

# MOST EFFICIENT
# Running a specific test case
bin/rails test test/models/training_program_test.rb -n test_state_transitions
```

> **IMPORTANT**: Always use `bin/rails` instead of `rails` directly to ensure proper environment setup and gem loading.

**Why It's Good**:
- Saves time and computational resources
- Maintains context by focusing on one problem at a time
- Makes debugging more efficient
- Reduces cognitive load when fixing complex issues
- Preserves context in your development environment

**Why It's Bad When Violated**:
- Wastes time waiting for unrelated tests to run
- Increases cognitive load with unrelated test failures
- Makes it harder to focus on the specific issue at hand
- Can lead to context switching and reduced productivity
- May exceed memory or token limits in AI-assisted development

### 4. Test-Driven Bug Fixing

**Rule**: When fixing a bug, first write a test that reproduces the issue.

**Example**:
```ruby
# GOOD PRACTICE
test "handles empty content_data gracefully" do
  # This test reproduces the bug
  content = build(:training_content, content_data: {})
  assert_not content.valid?
  assert_includes content.errors[:content_data], "must contain media URL"
end
```

**Why It's Good**:
- Ensures the bug is well understood before fixing
- Provides a clear way to verify the fix works
- Prevents regression by catching the issue in future tests
- Documents the expected behavior
- Makes code reviews more effective

**Why It's Bad When Violated**:
- May fix symptoms without addressing root causes
- Increases the chance of regression in the future
- Makes it harder to verify the fix actually works
- Reduces confidence in the solution
- Makes it harder for others to understand the issue and solution

### 5. Systematic Testing Process

**Rule**: Follow a systematic 10-step process for testing and fixing issues.

**10-Step Testing Process**:

1. **Identify the Scope**: Define exactly what feature or component you're testing.
   ```bash
   # Document the scope in a comment at the top of your test file
   # This test suite covers the TrainingProgram state transitions
   ```

2. **Create a Focused Test File**: Create a dedicated test file for the specific feature.
   ```bash
   # Create a focused test file
   bin/rails generate test_unit:system feature_name
   ```

3. **Isolate Dependencies**: Mock or stub external dependencies to focus on the component under test.
   ```ruby
   # Use stubs to isolate dependencies
   TrainingProgram.any_instance.stubs(:generate_certificate).returns(true)
   ```

4. **Test Happy Path First**: Verify the feature works under normal conditions.
   ```ruby
   test "publishes a draft program successfully" do
     program = create(:training_program, state: 'draft')
     program.publish!
     assert_equal 'published', program.state
   end
   ```

5. **Test Edge Cases**: Identify and test boundary conditions and edge cases.
   ```ruby
   test "handles empty content gracefully" do
     program = create(:training_program, state: 'draft')
     program.training_contents.destroy_all
     program.publish!
     assert_equal 'published', program.state
   end
   ```

6. **Test Error Conditions**: Verify the system handles errors appropriately.
   ```ruby
   test "prevents invalid state transitions" do
     program = create(:training_program, state: 'draft')
     assert_raises(Workflow::NoTransitionAllowed) do
       program.archive!
     end
   end
   ```

7. **Fix One Issue at a Time**: Address issues sequentially, running tests after each fix.
   ```bash
   # Fix one issue
   bin/rails test test/system/feature_test.rb -n test_specific_case
   ```

8. **Refactor with Confidence**: Refactor code with the safety net of tests.
   ```ruby
   # Refactor with tests to ensure functionality is preserved
   def publish
     # Refactored implementation
   end
   ```

9. **Document Findings**: Update documentation with insights from testing.
   ```markdown
   # Add to CHANGELOG.md or documentation
   - Fixed issue with state transitions in TrainingProgram
   ```

10. **Verify in Integration**: Ensure the fix works in the broader system context.
    ```bash
    # Run integration tests
    bin/rails test:system
    ```

**Why It's Good**:
- Provides a structured approach to testing
- Ensures comprehensive test coverage
- Makes complex issues more manageable
- Creates a clear path for fixing issues
- Builds confidence in the solution

**Why It's Bad When Violated**:
- Testing becomes ad-hoc and inconsistent
- Important edge cases may be missed
- Fixes may address symptoms rather than root causes
- Integration issues may be discovered late
- Documentation may be incomplete or outdated

### 6. One Step, One Test

**Rule**: Each step in the 10-step process should correspond to a focused test.

**Example**:
```ruby
# Step 1: Identify the Scope - Create a test file with clear scope
# test/system/training_program_state_test.rb
class TrainingProgramStateTest < ApplicationSystemTestCase
  # This test suite focuses on TrainingProgram state transitions
end

# Step 4: Test Happy Path - Create a specific test for the happy path
test "publishes a draft program successfully" do
  program = create(:training_program, state: 'draft')
  program.publish!
  assert_equal 'published', program.state
end

# Step 6: Test Error Conditions - Create a specific test for error handling
test "prevents invalid state transitions" do
  program = create(:training_program, state: 'draft')
  assert_raises(Workflow::NoTransitionAllowed) do
    program.archive!
  end
end
```

**Why It's Good**:
- Creates a clear mapping between process steps and tests
- Ensures each aspect of the feature is tested
- Makes it easier to track progress
- Provides a structured approach to test creation
- Improves test organization and readability

**Why It's Bad When Violated**:
- Tests may not cover all aspects of the feature
- Process steps may be skipped or overlooked
- Progress becomes harder to track
- Test organization becomes less structured
- Test coverage may have gaps

### 7. Document Completion Reports

**Rule**: When completing a significant task or fixing a complex issue, create a datetime-stamped completion report.

**Example**:
```markdown
# Completion Report: 10-Step Testing Process for TrainingProgram Completion Percentage

**Date: February 25, 2025**
**Time: 1:58 PM PST**

## Summary

I've successfully applied the 10-step testing process to address the TrainingProgram completion percentage issues. This report documents the steps taken, findings, and recommendations for future work.

## Steps Completed

1. **Identified the Scope**: Focused on the TrainingProgram completion percentage calculation functionality.
2. **Created a Focused Test File**: Created `training_program_completion_test.rb` to isolate and test the completion percentage functionality.
...

## Key Implementations

...

## Remaining Issues

...

## Recommendations for Next Steps

...
```

**Why It's Good**:
- Creates a clear record of what was accomplished
- Provides context for future developers
- Documents the decision-making process
- Makes knowledge transfer more effective
- Serves as a reference for similar issues in the future
- Facilitates handoffs between different developers or teams

**Why It's Bad When Violated**:
- Knowledge about complex fixes may be lost over time
- Future developers may not understand why certain decisions were made
- Similar issues may be approached inconsistently
- Makes it harder to track progress on complex issues
- Reduces the effectiveness of knowledge sharing

## API Design Principles

### 1. Consistent Response Formats

**Rule**: Use consistent response formats across all API endpoints.

**Example**:
```ruby
# INCONSISTENT
# One endpoint returns direct object
def show
  render json: @training_program
end

# Another endpoint wraps in data key
def index
  render json: { data: @training_programs }
end

# CONSISTENT
# All endpoints use the same format
def show
  render json: { data: @training_program }
end

def index
  render json: { data: @training_programs }
end
```

**Why It's Good**:
- Frontend code can handle responses consistently
- Reduces special case handling
- Makes API documentation clearer
- Easier to implement error handling

**Why It's Bad When Violated**:
- Frontend needs special case handling for different endpoints
- Increases complexity in API integration
- Makes the API harder to document
- More prone to errors when consuming the API

### 2. Versioned API Endpoints

**Rule**: Always version API endpoints to allow for future changes.

**Example**:
```ruby
# GOOD
namespace :api do
  namespace :v1 do
    resources :training_programs
  end
end
```

**Why It's Good**:
- Allows for non-breaking changes to the API
- Provides a clear migration path for clients
- Makes API evolution more manageable
- Prevents breaking existing integrations

**Why It's Bad When Violated**:
- Changes to the API can break existing clients
- Makes it harder to evolve the API over time
- Creates resistance to improving the API
- Can lead to technical debt in maintaining backward compatibility

## Service Worker Implementation

### 1. Consistent Caching Strategies

**Rule**: Use consistent caching strategies for similar types of resources.

**Example**:
```javascript
// INCONSISTENT
// Images use cache-first
if (event.request.url.match(/\.(jpg|jpeg|png|gif)$/)) {
  event.respondWith(caches.match(event.request));
}
// But CSS uses network-first
if (event.request.url.match(/\.css$/)) {
  event.respondWith(fetch(event.request).catch(() => caches.match(event.request)));
}

// CONSISTENT
// All static assets use cache-first
if (event.request.url.match(/\.(jpg|jpeg|png|gif|css|js)$/)) {
  event.respondWith(caches.match(event.request).then(response => {
    return response || fetch(event.request);
  }));
}
```

**Why It's Good**:
- Creates predictable offline behavior
- Simplifies service worker code
- Makes debugging easier
- Provides consistent user experience

**Why It's Bad When Violated**:
- Creates unpredictable offline behavior
- Makes the service worker harder to maintain
- Complicates debugging cache issues
- Results in inconsistent performance

### 2. Proper Error Handling

**Rule**: Always handle network errors and provide appropriate fallbacks.

**Example**:
```javascript
// INCORRECT
fetch(url).then(response => {
  // No error handling
  return response;
});

// CORRECT
fetch(url).then(response => {
  return response;
}).catch(error => {
  console.error('Fetch error:', error);
  return caches.match(url) || caches.match('/offline.html');
});
```

**Why It's Good**:
- Provides graceful degradation when offline
- Prevents uncaught exceptions
- Improves user experience during network issues
- Makes the application more resilient

**Why It's Bad When Violated**:
- Application may crash when offline
- Creates poor user experience during network issues
- Makes debugging harder
- Reduces application reliability

## Vue.js Component Design

### 1. Prop Validation

**Rule**: Always validate component props with proper types and requirements.

**Example**:
```javascript
// INCORRECT
props: ['programId', 'userName']

// CORRECT
props: {
  programId: {
    type: String,
    required: true
  },
  userName: {
    type: String,
    default: ''
  }
}
```

**Why It's Good**:
- Catches prop type errors early
- Makes component API self-documenting
- Provides clear expectations for component usage
- Helps prevent runtime errors

**Why It's Bad When Violated**:
- Can lead to subtle bugs that are hard to track down
- Makes component usage less clear
- Reduces component reusability
- Makes debugging more difficult

### 2. Single Responsibility Components

**Rule**: Each component should have a single responsibility.

**Example**:
```javascript
// INCORRECT
// One component handling video, quiz, and certificate
<TrainingContent />

// CORRECT
// Separate components for each responsibility
<VideoPlayer />
<QuizComponent />
<CertificateViewer />
```

**Why It's Good**:
- Makes components more reusable
- Simplifies testing
- Improves code organization
- Makes maintenance easier

**Why It's Bad When Violated**:
- Creates complex, hard-to-maintain components
- Makes testing more difficult
- Reduces component reusability
- Increases cognitive load when working with the component

## General Development Guidelines

### 1. Explicit Over Implicit

**Rule**: Prefer explicit, clear code over clever, implicit code.

**Example**:
```ruby
# IMPLICIT
def method_missing(method_name, *args)
  if method_name.to_s.start_with?('find_by_')
    # Complex dynamic finder logic
  end
end

# EXPLICIT
def find_by_name(name)
  where(name: name).first
end

def find_by_email(email)
  where(email: email).first
end
```

**Why It's Good**:
- Makes code more readable and maintainable
- Reduces the learning curve for new developers
- Makes debugging easier
- Improves IDE support (autocomplete, etc.)

**Why It's Bad When Violated**:
- Creates "magic" code that's hard to understand
- Makes debugging more difficult
- Increases the learning curve for new developers
- Can lead to unexpected behavior

### 2. Consistent Error Handling

**Rule**: Handle errors consistently throughout the application.

**Example**:
```ruby
# INCONSISTENT
# One method raises an exception
def process_certificate
  raise "Certificate not found" unless certificate
end

# Another returns nil
def process_training
  return nil unless training
end

# CONSISTENT
# All methods use the same error handling approach
def process_certificate
  return Result.error("Certificate not found") unless certificate
  Result.success(certificate)
end

def process_training
  return Result.error("Training not found") unless training
  Result.success(training)
end
```

**Why It's Good**:
- Creates predictable error handling patterns
- Makes error recovery more consistent
- Improves logging and monitoring
- Makes the application more robust

**Why It's Bad When Violated**:
- Creates unpredictable error behavior
- Makes error handling more complex
- Increases the chance of unhandled errors
- Makes debugging more difficult