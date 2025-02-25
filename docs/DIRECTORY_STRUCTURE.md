# Directory Structure

## Root Directory
- `.erdconfig` - Entity-Relationship Diagram configuration
- `.rubocop.yml` - Ruby code style configuration
- `.standard.yml` - Ruby code standardization rules
- `app.json` - Application configuration for deployment platforms
- `config.ru` - Rack configuration file
- `esbuild.config.js` - JavaScript bundler configuration
- `postcss.config.js` - CSS processing configuration
- `tailwind.config.js` - Tailwind CSS framework configuration

## App Directory (`app/`)
Core application code following Rails MVC structure:

### Models (`app/models/`)
- `training_program.rb` - Core training program functionality
- `training_certificate.rb` - Certificate generation and verification
- `training_membership.rb` - User program enrollment and progress
- `training_content.rb` - Program content and materials
- `training_question.rb` - Quiz questions and answers
- `training_invitation.rb` - Training invitations management
- `training_progress.rb` - Progress tracking
- `user.rb` - User authentication and roles
- `team.rb` - Team management and organization
- `membership.rb` - Team membership and roles
- `pricing_model.rb` - Training program pricing
- `facility.rb` - Facility management
- `location.rb` - Location management
- `address.rb` - Location and address management

### Controllers (`app/controllers/`)
- `application_controller.rb` - Base controller with shared functionality
- `training_programs_controller.rb` - Training program management
- `training_certificates_controller.rb` - Certificate operations
- `training_contents_controller.rb` - Content management
- `training_invitations_controller.rb` - Invitation handling
- `training_questions_controller.rb` - Quiz management
- `training_progress_controller.rb` - Progress tracking
- `facilities_controller.rb` - Facility management
- `locations_controller.rb` - Location management
- `pricing_models_controller.rb` - Pricing management

### Views (`app/views/`)
- `layouts/` - Application layout templates
- `training_programs/` - Training program views
- `training_certificates/` - Certificate templates and views
- `training_contents/` - Content management views
- `training_invitations/` - Invitation management views
- `training_questions/` - Quiz management views
- `facilities/` - Facility management views
- `locations/` - Location management views
- `shared/` - Reusable view components

### JavaScript (`app/javascript/`)
- `controllers/` - Stimulus controllers
- `components/` - Vue.js components
- `training_player/` - Vue.js training program player
- `training-program-viewer/` - Training program viewing interface

## Config Directory (`config/`)
- `application.rb` - Main application configuration
- `routes.rb` - Application routing
- `database.yml` - Database configuration
- `initializers/` - Framework and gem initialization
- `locales/` - Internationalization files

## Database (`db/`)
- `migrate/` - Database migrations
- `seeds/` - Seed data for development
- `schema.rb` - Current database schema

## Test Directory (`test/`)
- `models/` - Model tests
- `controllers/` - Controller tests
- `system/` - System/integration tests
- `factories/` - Test data factories

## Public Directory (`public/`)
Static files served directly:
- `404.html`, `422.html`, `500.html` - Error pages
- `favicon.ico` - Site favicon
- `robots.txt` - Search engine instructions

## Specifications (`specifications/`)
- Contains wireframes and design specifications
- UI/UX documentation and mockups

## Key Features by Role

### Administrator
Can access:
- ✅ System-wide configuration
- ✅ Full user management
- ✅ Training program management
- ✅ Certificate management
- ✅ Payment management
- ✅ API management
- ✅ Comprehensive reporting

### Customer
Can access:
- ✅ Vendor management
- ✅ Employee viewing
- ✅ Training program access
- ✅ Certificate management
- ✅ Training requests
- ✅ Role-specific reports
- ❌ System configuration
- ❌ Payment processing

### Vendor
Can access:
- ✅ Employee management
- ✅ Training program viewing
- ✅ Payment processing
- ✅ Training requests
- ✅ Progress monitoring
- ✅ Certificate management
- ❌ System configuration
- ❌ Program creation

### Employee
Can access:
- ✅ Training program viewing
- ✅ Content consumption
- ✅ Progress tracking
- ✅ Certificate viewing
- ✅ Profile management
- ❌ User management
- ❌ Program management
- ❌ Payment processing