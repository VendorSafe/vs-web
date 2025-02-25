# Test Failures and TODOs

This document outlines the current test failures and provides notes on how to fix them.

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