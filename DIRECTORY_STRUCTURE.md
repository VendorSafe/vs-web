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
- `user.rb` - User authentication and roles
- `address.rb` - Location and address management

### Controllers (`app/controllers/`)
- `application_controller.rb` - Base controller with shared functionality
- `training_programs_controller.rb` - Training program management
- `training_certificates_controller.rb` - Certificate operations
- `training_contents_controller.rb` - Content management

### Views (`app/views/`)
- `layouts/` - Application layout templates
- `training_programs/` - Training program views
- `training_certificates/` - Certificate templates and views
- `shared/` - Reusable view components

### JavaScript (`app/javascript/`)
- `controllers/` - Stimulus controllers
- `components/` - Vue.js components
- `training_player/` - Vue.js training program player

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
- ✅ Full training program management
- ✅ Certificate management
- ✅ User role management
- ✅ Team management
- ✅ Content management
- ✅ Progress tracking
- ✅ Reporting tools

### Training Manager
Can access:
- ✅ Training program creation/editing
- ✅ Content management
- ✅ Progress monitoring
- ✅ Certificate generation
- ✅ Team member management
- ❌ System configuration
- ❌ Role management

### Instructor
Can access:
- ✅ Content creation
- ✅ Progress tracking
- ✅ Certificate viewing
- ✅ Student management
- ❌ Program creation
- ❌ System settings
- ❌ Team management

### Student
Can access:
- ✅ Training program viewing
- ✅ Content consumption
- ✅ Progress tracking
- ✅ Certificate viewing
- ❌ Content management
- ❌ Program management
- ❌ User management