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
rails test

# EFFICIENT
# Running a specific test file
rails test test/models/training_program_test.rb

# MOST EFFICIENT
# Running a specific test case
rails test test/models/training_program_test.rb -n test_state_transitions
```

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