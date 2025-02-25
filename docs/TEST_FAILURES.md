# Test Failures and TODOs

This document outlines the current test failures and provides notes on how to fix them.

Last updated: February 25, 2025

## Fixed Issues

**TrainingProgram Method Access**
- Fixed the `enroll_trainee` method in TrainingProgram by making it explicitly public.

**Route Helpers**
- Fixed the route helpers in TrainingProgramsControllerTest to use the correct namespaced paths.

**PDF Generation**
- Added the missing OpenSans-Regular.ttf font file and fixed the PDF generation tests by replacing the unsupported `stub` method with proper method replacement.

**Terminology**
- Renamed all instances of "student" to "trainee" throughout the codebase for consistency.

**TrainingProgram State Management**
- Fixed the workflow state column in TrainingProgram model by changing `workflow_column :workflow_state` to `workflow_column :state`
- Updated `after_initialize` callback to use `self.state` instead of `self.workflow_state`
- Created focused tests for state transitions to verify the fix

**TrainingProgram Completion Percentage**
- Implemented the `completion_percentage_for` method in the TrainingProgram model
- Added support for calculating completion percentage based on completed content
- Created focused tests for completion percentage calculation

## API Controller Issues

Most API controller tests are failing with 404 errors. This is likely due to routing issues or authentication problems.

### API V1 Training Programs Controller

```
Api::V1::TrainingProgramsControllerTest#test_index
Api::V1::TrainingProgramsControllerTest#test_create
Api::V1::TrainingProgramsControllerTest#test_update
Api::V1::TrainingProgramsControllerTest#test_show
```

**TODO:** 
- Check API routes to ensure they're properly defined
- Verify authentication is working correctly for API requests
- Ensure the controller is properly handling the requests
- Fix serialization issues in the controller

### API V1 Training Questions Controller

```
Api::V1::TrainingQuestionsControllerTest#test_index
Api::V1::TrainingQuestionsControllerTest#test_show
Api::V1::TrainingQuestionsControllerTest#test_update
Api::V1::TrainingQuestionsControllerTest#test_destroy
Api::V1::TrainingQuestionsControllerTest#test_create
```

**TODO:**
- Check API routes for training questions
- Fix serialization issues in the controller
- Ensure proper authentication and authorization

### API V1 Training Contents Controller

```
Api::V1::TrainingContentsControllerTest#test_index
Api::V1::TrainingContentsControllerTest#test_show
Api::V1::TrainingContentsControllerTest#test_update
Api::V1::TrainingContentsControllerTest#test_create
```

**TODO:**
- Fix serialization issues in the controller
- Ensure content_type validation is working correctly
- Add proper validation for content_data

### API V1 Facilities Controller

```
Api::V1::FacilitiesControllerTest#test_index
Api::V1::FacilitiesControllerTest#test_show
Api::V1::FacilitiesControllerTest#test_update
Api::V1::FacilitiesControllerTest#test_create
Api::V1::FacilitiesControllerTest#test_destroy
```

**TODO:**
- Check API routes for facilities
- Ensure proper authentication and authorization

### API V1 Locations Controller

```
Api::V1::LocationsControllerTest#test_index
Api::V1::LocationsControllerTest#test_show
Api::V1::LocationsControllerTest#test_update
Api::V1::LocationsControllerTest#test_create
Api::V1::LocationsControllerTest#test_destroy
```

**TODO:**
- Check API routes for locations
- Ensure proper authentication and authorization

### API V1 Pricing Models Controller

```
Api::V1::PricingModelsControllerTest#test_index
Api::V1::PricingModelsControllerTest#test_show
Api::V1::PricingModelsControllerTest#test_update
Api::V1::PricingModelsControllerTest#test_create
Api::V1::PricingModelsControllerTest#test_destroy
```

**TODO:**
- Check API routes for pricing models
- Ensure proper authentication and authorization

### API V1 Teams Controller

```
Api::V1::TeamsControllerTest#test_index
Api::V1::TeamsControllerTest#test_show
Api::V1::TeamsControllerTest#test_update
```

**TODO:**
- Check API routes for teams
- Ensure proper authentication and authorization

### API V1 Platform Access Tokens Controller

```
Api::V1::Platform::AccessTokensControllerTest#test_index
Api::V1::Platform::AccessTokensControllerTest#test_create
```

**TODO:**
- Check API routes for access tokens
- Ensure proper authentication and authorization

### API V1 Platform Applications Controller

```
Api::V1::Platform::ApplicationsControllerTest#test_provision
```

**TODO:**
- Fix the testing provision key issue
- Ensure proper authentication and authorization

## Account Controller Issues

Most account controller tests are failing with authentication issues. Users are being redirected to the sign-in page.

### Account Training Programs Controller

```
Account::TrainingProgramsControllerTest#test_vendor_can_view_training_program
Account::TrainingProgramsControllerTest#test_employee_can_view_training_program
Account::TrainingProgramsControllerTest#test_non-member_cannot_view_training_program
Account::TrainingProgramsControllerTest#test_redirects_when_not_authenticated
```

**TODO:**
- Fix the Role.vendor class method
- Ensure proper authentication in the controller
- Verify the controller is handling the requests correctly

### Account Teams Controller

```
Account::TeamsControllerTest#test_should_get_index
Account::TeamsControllerTest#test_should_get_new
Account::TeamsControllerTest#test_should_create_team
Account::TeamsControllerTest#test_should_show_team
Account::TeamsControllerTest#test_should_get_edit
Account::TeamsControllerTest#test_should_update_team
Account::TeamsControllerTest#test_should_get_redirect_to_team_homepage
```

**TODO:**
- Fix authentication issues in the controller
- Ensure proper authorization for team actions

### Account Scaffolding Controllers

```
Account::Scaffolding::AbsolutelyAbstract::CreativeConceptsControllerTest#test_should_get_index
Account::Scaffolding::AbsolutelyAbstract::CreativeConceptsControllerTest#test_should_get_new
Account::Scaffolding::AbsolutelyAbstract::CreativeConceptsControllerTest#test_should_create_creative_concept
Account::Scaffolding::AbsolutelyAbstract::CreativeConceptsControllerTest#test_should_show_creative_concept
Account::Scaffolding::AbsolutelyAbstract::CreativeConceptsControllerTest#test_should_get_edit
Account::Scaffolding::AbsolutelyAbstract::CreativeConceptsControllerTest#test_should_update_creative_concept
Account::Scaffolding::AbsolutelyAbstract::CreativeConceptsControllerTest#test_should_destroy_creative_concept

Account::Scaffolding::CompletelyConcrete::TangibleThingsControllerTest#test_should_get_index
Account::Scaffolding::CompletelyConcrete::TangibleThingsControllerTest#test_should_get_new
Account::Scaffolding::CompletelyConcrete::TangibleThingsControllerTest#test_should_create_tangible_thing
Account::Scaffolding::CompletelyConcrete::TangibleThingsControllerTest#test_should_show_tangible_thing
Account::Scaffolding::CompletelyConcrete::TangibleThingsControllerTest#test_should_get_edit
Account::Scaffolding::CompletelyConcrete::TangibleThingsControllerTest#test_should_update_tangible_thing
Account::Scaffolding::CompletelyConcrete::TangibleThingsControllerTest#test_should_destroy_tangible_thing
```

**TODO:**
- Fix authentication issues in the scaffolding controllers
- Ensure proper authorization for scaffolding actions

## Application Controller Issues

```
ApplicationControllerTest#test_team_locale_is_nil_user_locale_is_nil
ApplicationControllerTest#test_team_locale_is_nil_user_locale_is_nil_HTTP_ACCEPT_LANGUAGE_equals_es
ApplicationControllerTest#test_team_locale_is_es_user_locale_is_nil
ApplicationControllerTest#test_team_locale_is_es_user_locale_is_de
ApplicationControllerTest#test_team_locale_is_nil_user_locale_is_de
ApplicationControllerTest#test_team_locale_is_es_user_locale_is_empty_string
```

**TODO:**
- Fix locale handling in the application controller
- Ensure proper fallback for locales

## TrainingProgram Completion Percentage Issues

```
TrainingProgramTest#test_should_track_completion_status
TrainingProgramCompletionTest#test_initial_completion_percentage_should_be_zero
TrainingProgramCompletionTest#test_completion_percentage_should_increase_when_content_is_completed
TrainingProgramCompletionTest#test_completion_percentage_should_be_100_when_all_content_is_completed
TrainingProgramCompletionTest#test_completion_percentage_should_be_0_when_program_has_no_content
```

**TODO:**
- Fix the `completion_percentage_for` method in the TrainingProgram model to handle edge cases
- Ensure the method calculates the completion percentage based on completed content
- Update the TrainingContent model's `mark_complete_for` method to properly update the completion percentage
- Add tests for the completion percentage calculation

## PDF Generation Issues

```
GenerateCertificatePdfJobTest#test_generates_PDF_certificate_successfully
GenerateCertificatePdfJobTest#test_handles_PDF_generation_failure
GenerateCertificatePdfJobTest#test_updates_status_to_processing_while_generating
```

**TODO:**
- Add the missing OpenSans-Regular.ttf font to app/assets/fonts/
- Fix the Prawn::Document.stub method for testing
- Ensure proper PDF generation

## Ability Test Issues

```
AbilityTest::TeamAdminScenarios#test_can_manage_team
AbilityTest::TeamAdminScenarios#test_can_manage_membership
```

**TODO:**
- Fix the ability definitions for team admins
- Ensure proper authorization rules

## Training Programs Controller Issues

```
TrainingProgramsControllerTest#test_should_get_index
TrainingProgramsControllerTest#test_should_create_program_when_admin
TrainingProgramsControllerTest#test_should_not_create_program_when_trainee
```

**TODO:**
- Define the training_programs_url helper
- Fix the controller to handle the requests correctly

## API Documentation Issues

```
Api::OpenApiControllerTest#test_OpenAPI_document_is_valid
```

**TODO:**
- Fix the OpenAPI document warnings

## Troubleshooting Strategies

### Authentication Issues
1. Check if the test is properly setting up authentication
2. Verify that the controller is using the correct authentication method
3. Ensure that the test is using the correct user factory
4. Check for any changes in the authentication flow

### Authorization Issues
1. Verify that the user has the correct role
2. Check if the ability definitions are correct
3. Ensure that the controller is checking for the correct permissions
4. Verify that the test is setting up the correct permissions

### Routing Issues
1. Check if the routes are properly defined
2. Verify that the controller is using the correct routes
3. Ensure that the test is using the correct route helpers
4. Check for any changes in the routing configuration

### Serialization Issues
1. Verify that the serializer is correctly defined
2. Check if the controller is using the correct serializer
3. Ensure that the test is expecting the correct JSON structure
4. Check for any changes in the serialization configuration

## 10-Step Testing Process

To systematically address the remaining test failures, follow this 10-step process:

1. **Identify the Scope**: Define exactly what feature or component you're testing.
   ```bash
   # Create a focused test file for the specific feature
   bin/rails generate test_unit:system feature_name
   ```

2. **Create a Focused Test File**: Create a dedicated test file for the specific feature.
   ```ruby
   # Example of a focused test file
   class TrainingProgramStateTest < ApplicationSystemTestCase
     # This test suite focuses on TrainingProgram state transitions
   end
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

### Applying the 10-Step Process to Current Failures

For each category of test failures:

1. Create a focused test file that isolates the specific issue
2. Write tests for the happy path, edge cases, and error conditions
3. Fix one issue at a time, running tests after each fix
4. Document your findings and solutions
5. Verify the fix works in the broader system context

## Test Execution Tips

### Running Specific Tests
```bash
# Run a specific test file
bin/rails test test/controllers/api/v1/training_programs_controller_test.rb

# Run a specific test
bin/rails test test/controllers/api/v1/training_programs_controller_test.rb:42

# Run tests with a specific name pattern
bin/rails test -n /training_program/
```

### Debugging Tests
```bash
# Run tests with verbose output
bin/rails test -v

# Run tests with debugging
bin/rails test --debug

# Run system tests with browser
OPEN_BROWSER=1 bin/rails test:system