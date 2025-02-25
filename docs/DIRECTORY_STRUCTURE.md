# Directory Structure

This document provides an overview of the project's directory structure, following Bullet Train conventions.

Last updated: February 24, 2025

## Root Directory Files

- `.erdconfig` - Entity-Relationship Diagram configuration for visualizing database relationships
- `.rubocop.yml` - Ruby code style configuration for consistent code quality
- `.standard.yml` - Ruby code standardization rules for the Standard gem
- `.gitignore` - Specifies files to be ignored by Git
- `.tool-versions` - Defines tool versions for asdf version manager
- `app.json` - Application configuration for Heroku and other deployment platforms
- `config.ru` - Rack configuration file for the web server
- `esbuild.config.js` - JavaScript bundler configuration for modern JS processing
- `postcss.config.js` - CSS processing configuration for modern CSS features
- `tailwind.config.js` - Tailwind CSS framework configuration for UI styling
- `Gemfile` / `Gemfile.lock` - Ruby dependencies
- `package.json` / `yarn.lock` - JavaScript dependencies
- `Procfile` / `Procfile.dev` - Process definitions for production and development
- `Rakefile` - Task definitions for the rake command
- `README.md` - Project overview and documentation

## App Directory (`app/`)

Core application code following Rails MVC structure and Bullet Train conventions:

### Models (`app/models/`)

- `ability.rb` - CanCanCan authorization definitions
- `application_record.rb` - Base class for all models
- `user.rb` - User authentication and profile management (via Devise)
- `team.rb` - Team management and organization (Bullet Train's multitenancy)
- `membership.rb` - Team membership and roles
- `role.rb` - Role definitions for permissions
- `training_program.rb` - Core training program functionality with workflow states
- `training_certificate.rb` - Certificate generation and verification
- `training_membership.rb` - User program enrollment and progress tracking
- `training_content.rb` - Program content and materials management
- `training_question.rb` - Quiz questions and answers
- `training_invitation.rb` - Training invitations management
- `facility.rb` - Facility management
- `location.rb` - Location management
- `pricing_model.rb` - Training program pricing
- `address.rb` - Location and address management
- `concerns/` - Shared model concerns and mixins

### Controllers (`app/controllers/`)

- `application_controller.rb` - Base controller with shared functionality
- `account/` - Authenticated user controllers (Bullet Train convention)
  - `account/application_controller.rb` - Base controller for authenticated routes
  - `account/dashboard_controller.rb` - User dashboard
  - `account/teams_controller.rb` - Team management
  - `account/training_programs_controller.rb` - Training program management
  - `account/training_contents_controller.rb` - Content management
  - `account/training_questions_controller.rb` - Quiz management
  - `account/facilities_controller.rb` - Facility management
  - `account/locations_controller.rb` - Location management
  - `account/pricing_models_controller.rb` - Pricing management
- `api/` - API controllers (versioned per Bullet Train convention)
  - `api/v1/application_controller.rb` - Base API controller
  - `api/v1/training_programs_controller.rb` - Training program API
  - `api/v1/training_contents_controller.rb` - Content API
  - `api/v1/training_questions_controller.rb` - Quiz API
- `public/` - Public-facing controllers
  - `public/application_controller.rb` - Base controller for public routes
  - `public/home_controller.rb` - Homepage and marketing pages
- `training_certificates_controller.rb` - Certificate operations
- `training_invitations_controller.rb` - Invitation handling
- `training_programs_controller.rb` - Public training program access

### Views (`app/views/`)

- `layouts/` - Application layout templates
- `account/` - Authenticated user views
  - `account/training_programs/` - Training program management
  - `account/training_contents/` - Content management
  - `account/training_questions/` - Quiz management
  - `account/facilities/` - Facility management
  - `account/locations/` - Location management
  - `account/pricing_models/` - Pricing management
- `api/` - API views and serializers
  - `api/v1/training_programs/` - Training program API views
  - `api/v1/training_contents/` - Content API views
  - `api/v1/training_questions/` - Quiz API views
  - `api/v1/open_api/` - API documentation
- `public/` - Public-facing views
- `training_certificates/` - Certificate templates and views
- `training_invitations/` - Invitation management views
- `shared/` - Reusable view components
- `themes/` - Bullet Train theme components

### JavaScript (`app/javascript/`)

- `application.js` - Main JavaScript entry point
- `controllers/` - Stimulus controllers for interactive UI
- `channels/` - Action Cable channels for real-time features
- `entrypoints/` - Additional entry points for specific pages
- `training_player/` - Vue.js training program player
  - `components/` - Vue components for the player
  - `stores/` - State management
- `training-program-viewer/` - Training program viewing interface
  - `TrainingProgramViewer.vue` - Main component
  - `VideoPlayer.vue` - Video playback component
  - `QuestionsPanel.vue` - Quiz interface
  - `StepProgress.vue` - Progress tracking UI

## Config Directory (`config/`)

- `application.rb` - Main application configuration
- `routes.rb` - Application routing
- `database.yml` - Database configuration
- `initializers/` - Framework and gem initialization
- `locales/` - Internationalization files
  - `en/` - English translations
  - `training_programs.en.yml` - Training program translations
  - `training_certificates.en.yml` - Certificate translations
- `routes/` - Modular routing definitions
  - `api/v1.rb` - API routes
- `models/` - Model configuration
  - `roles.yml` - Role definitions
  - `billing/products.yml` - Billing product definitions

## Database (`db/`)

- `migrate/` - Database migrations
- `seeds/` - Seed data for development
  - `development.rb` - Development-specific seeds
  - `test.rb` - Test-specific seeds
- `schema.rb` - Current database schema

## Test Directory (`test/`)

- `models/` - Model unit tests
- `controllers/` - Controller tests
- `system/` - System/integration tests with browser automation
- `factories/` - Test data factories using FactoryBot
- `support/` - Test helpers and shared functionality
- `fixtures/` - Test fixtures and sample files

## Bin Directory (`bin/`)

- `rails` - Rails command wrapper
- `rake` - Rake command wrapper
- `setup` - Project setup script
- `dev` - Development server launcher
- `directory-structure` - Generates directory structure documentation
- `resolve` - Bullet Train's file resolution tool
- `theme` - Theme management tool
- `super-scaffold` - Bullet Train's scaffolding tool

## Documentation (`docs/`)

- `README.md` - Documentation overview
- `CHANGELOG.md` - Version history and changes
- `DEVELOPMENT-NOTES.md` - Development notes and known issues
- `DIRECTORY_STRUCTURE.md` - This file
- `IMPLEMENTATION-STATUS.md` - Current implementation status
- `INTEGRATION-PLAN.md` - Integration planning
- `INTEGRATION-TASKS.md` - Specific integration tasks
- `MILESTONES.md` - Project milestones
- `ROLES.md` - Role architecture documentation
- `TESTING.md` - Testing guide
- `TODO.md` - Pending tasks
- `bullet-train-docs.md` - Bullet Train documentation

## Key Features by Role

### Administrator
Can access:
- System-wide configuration
- Full user management
- Training program management
- Certificate management
- Payment management
- API management
- Comprehensive reporting

### Customer
Can access:
- Vendor management
- Employee viewing
- Training program access
- Certificate management
- Training requests
- Role-specific reports

### Vendor
Can access:
- Employee management
- Training program viewing
- Payment processing
- Training requests
- Progress monitoring
- Certificate management

### Employee
Can access:
- Training program viewing
- Content consumption
- Progress tracking
- Certificate viewing
- Profile management