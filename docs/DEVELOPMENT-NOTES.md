# Development Notes

## Known Issues and Solutions

### Entity-Relationship Diagram (ERD) Generation Warnings

When running migrations or generating ERD diagrams, you may see the following warnings:

1. `Warning: Ignoring invalid association :country on Address`
2. `Warning: Ignoring invalid association :region on Address`

These warnings have been addressed by properly configuring ActiveHash associations in the Address model:

```ruby
# app/models/address.rb
class Address < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :country, class_name: 'Addresses::Country'
  belongs_to_active_hash :region, class_name: 'Addresses::Region'
end
```

3. `Warning: Ignoring invalid association :event_type on Webhooks::Outgoing::Event`

This warning indicates that the webhooks functionality is not properly set up. The required database tables and models are missing. To fix this:

1. Copy the migrations from the bullet_train-outgoing_webhooks gem:
```bash
cp `bundle show bullet_train-outgoing_webhooks`/db/migrate/* db/migrate/
```

2. Run the migrations:
```bash
rails db:migrate
```

These migrations will:
- Create webhooks_outgoing_endpoints table
- Create webhooks_outgoing_events table
- Create webhooks_outgoing_deliveries table
- Create webhooks_outgoing_delivery_attempts table
- Set up proper event type associations
- Add necessary fields for API versioning

After running these migrations, the warning should be resolved as the proper database structure for webhooks will be in place.

Note: The event types defined in `config/models/webhooks/outgoing/event_types.yml` will be properly associated with the Webhooks::Outgoing::Event model once these migrations are run.

## Bullet Train Dependencies Management

### Best Practices

1. **Pull Down Dependencies Locally**: For better development experience and easier debugging, consider pulling down Bullet Train dependencies locally:
   - Use `bin/hack` to clone core packages to `local/bullet_train-core`
   - Use `bin/hack --link` to link local packages
   - Use `bin/hack --reset` to revert to using original gems

2. **File Modification Strategy**:
   - Favor using Bullet Train's approach first before custom implementations
   - Use `bin/resolve` to locate and understand framework files
   - Only eject files when you need to modify specific functionality
   - When ejecting, only override the specific methods that need changes
   - Keep original files as reference for future upgrades

3. **Upgrading Process**:
   - Document any ejected files and overridden methods
   - Keep track of modifications in CHANGELOG.md
   - Test thoroughly after any framework upgrades
   - Review ejected files during upgrades to ensure compatibility

4. **Framework Integration**:
    - Use Bullet Train's conventions and patterns where possible
    - Leverage existing tools and helpers before creating custom solutions
    - Document any deviations from standard Bullet Train patterns

## PDF Certificate Generation

### Overview

The system includes a PDF certificate generation feature that creates professional-looking certificates for users who complete training programs. This feature uses the Prawn gem for PDF generation and includes:

1. **Background Processing**:
   - Certificates are generated asynchronously using ActiveJob
   - Status tracking (processing, completed, failed)
   - Error handling with detailed error messages

2. **Certificate Features**:
   - Program logo inclusion
   - Custom fonts (Open Sans)
   - Verification QR code
   - Grade and completion status
   - Issue and expiry dates
   - Unique verification code

3. **Testing**:
   - Unit tests for the PDF generation job
   - System tests for certificate management
   - CI/CD integration with GitHub Actions

### Implementation Notes

1. **Required Gems**:
   - `prawn` for PDF generation
   - `prawn-table` for table layouts
   - `rqrcode` for QR code generation

2. **Font Installation**:
   - Open Sans fonts must be available in `app/assets/fonts/`
   - CI environment requires font installation (see `.github/workflows/pdf_tests.yml`)

3. **Verification System**:
   - Each certificate has a unique verification code
   - QR codes link to verification page
   - Route helper: `verify_training_certificate_url`
   
4. **Certificate Management**:
   - Certificates are managed through the `TrainingCertificatesController`
   - PDF generation is handled asynchronously via `GenerateCertificatePdfJob`
   - Certificate status tracking includes:
     - Active/expired status based on expiry date
     - PDF generation status (processing, completed, failed)
     - Error tracking for failed PDF generation
   - Certificate verification is available via public URL

5. **Routes**:
   - Team-scoped routes for certificate management:
     - `/account/teams/:team_id/training_certificates` - List certificates
     - `/account/teams/:team_id/training_programs/:training_program_id/training_certificates` - Program-specific certificates
     - `/account/teams/:team_id/training_programs/:training_program_id/training_certificates/new` - Create certificate
   - Shallow routes for individual certificates:
     - `/training_certificates/:id` - View certificate
     - `/training_certificates/:id/download_pdf` - Download PDF
     - `/training_certificates/:id/regenerate_pdf` - Regenerate PDF
   - Public verification route:
     - `/certificates/verify/:verification_code` - Verify certificate

### Known Issues and Pending Fixes

1. **Duplicate Methods**:
   - The `TrainingCertificate` model has two `revoke!` methods with different implementations
   - The first implementation (lines 52-54) updates `revoked_at` timestamp
   - The second implementation (lines 122-124) updates `expires_at` to current time
   - Need to consolidate these methods with consistent behavior

2. **Field Naming Inconsistencies**:
   - The model uses `expires_at` but the form in new.html.erb uses `expiry_date`
   - The job references `certificate.grade` but the model uses `score`
   - The job references `certificate.completion_status` which isn't defined in the model

3. **User Reference Inconsistencies**:
   - The PDF generation job uses `certificate.user.name`
   - The model delegates to `membership.user_first_name` and `membership.user_last_name`
   - Need to ensure consistent user reference approach

4. **Route Helper Inconsistencies**:
   - System tests reference paths like `certificates_path` and `training_program_path`
   - These don't match the routes defined in routes.rb which use team-scoped paths

5. **Error Handling Improvements**:
   - PDF generation error handling could be improved with more specific error types
   - Consider adding retry mechanism with exponential backoff
   - Add monitoring for failed PDF generations

## Training Program Role Architecture

### Role-Based Access Control

The training system uses Bullet Train's built-in team, role, and invitation functionality. This is configured in `config/models/roles.yml` with the following roles:

1. **training_viewer**:
   - Can view published training programs
   - Read-only access to content and certificates

2. **training_participant**:
   - Inherits training_viewer permissions
   - Can participate in training programs
   - Can track progress and earn certificates

3. **training_author**:
   - Inherits training_participant permissions
   - Can create and edit training programs in draft state
   - Can publish training programs
   - Can manage training content and questions

4. **training_admin**:
   - Inherits training_author permissions
   - Can archive/restore training programs
   - Full management of all training resources
   - Can assign training roles to other team members

### Invitation and Access Management

Instead of implementing custom invitation logic, we leverage Bullet Train's team invitation system:

1. Team admins can invite new members
2. Invitees receive standard Bullet Train invitations
3. Upon acceptance, appropriate training roles can be assigned
4. Access to training programs is controlled through team membership and roles

### State Management

Training programs use workflow states (draft, published, archived) with role-based guards:
- Only training_authors and admins can publish programs
- Only training_admins can archive programs
- Published programs are visible to all roles
- Draft programs are only visible to authors and admins

## Command Execution Logs

To maintain a record of commands executed during development and testing, we've established a structured approach:

1. **Command Log Directory**:
   - All command scripts are stored in the `agent-cmd-log` directory
   - Scripts are timestamped for easy reference (e.g., `2025-02-24-test-commands.sh`)
   - Each script is executable and contains related commands for a specific task

2. **Script Structure**:
   - Scripts begin with proper shell environment setup: `#!/bin/zsh -l`
   - Working directory is set to project root
   - Commands are grouped by related functionality
   - Comments explain the purpose of each command
   - Output messages are included for clarity

3. **Usage**:
   - Execute scripts from the project root: `./agent-cmd-log/SCRIPT_NAME.sh`
   - After execution, update the script with comments containing the output
   - Mark executed scripts with execution date and results

4. **Example**:
   - The script `2025-02-24-test-commands.sh` contains commands to:
     - Install the correct bundler version
     - Run certificate job tests
     - Run certificate system tests

## Original Udoras Specifications Analysis

After reviewing the documentation in the `docs/old-udoras-secifications/` folder, I've analyzed what the original quote was based on years ago:

### Original System Concept

The original Udoras system was designed as a training management platform with a multi-role architecture focused on:

1. **Role-Based Access Control**: Four distinct user roles with hierarchical permissions:
   - **Admin**: System administrators with full access
   - **Customer**: Organizations creating and managing training programs
   - **Vendor**: Team managers with employee management capabilities
   - **Employee**: Individual team members taking training

2. **Training Management Workflow**:
   - Customers could create training requests
   - Vendors could assign training to employees
   - Employees could complete training and earn certificates
   - Admins could oversee the entire process

3. **Certificate Management System**:
   - Generation of certificates upon training completion
   - Verification and sharing capabilities
   - Expiration tracking

4. **User Interface Design**:
   - Simple, form-based interfaces
   - Table-based data presentation
   - Basic search and pagination

### Key Features in Original Specifications

Based on the wireframes and documentation:

1. **User Registration and Profile Management**:
   - Role-specific registration flows
   - Profile management with contact information
   - Address management (up to 5 addresses for vendors)

2. **Training Content Management**:
   - Basic training information display
   - Training status tracking
   - Simple pricing model ($20 per training)

3. **Certificate System**:
   - Certificate viewing
   - Download and sharing options
   - Basic certificate design

4. **Employee Management**:
   - Adding/editing employees
   - Viewing employee certificates
   - Managing employee training requests

5. **Training Request System**:
   - Customers could request training
   - Vendors could view and respond to requests
   - Payment options (vendor pays or employee pays)

### Comparison with Current Implementation

The current implementation has significantly expanded on the original concept:

1. **Enhanced Role System**:
   - More sophisticated role-based permissions
   - Team-based access control
   - Integration with Bullet Train's built-in team system

2. **Advanced Training Program Features**:
   - State management with workflow transitions (draft, published, archived)
   - Progress tracking with completion percentage
   - Sequential content progression

3. **Sophisticated Certificate System**:
   - PDF generation with custom styling
   - QR code verification
   - Expiration handling
   - Revocation capabilities

4. **Modern Frontend**:
   - Vue.js training program player
   - Interactive content viewer
   - Progress visualization
   - Responsive design

5. **Additional Features Not in Original Spec**:
   - Activity tracking system
   - API endpoints for integration
   - Comprehensive test infrastructure
   - Advanced reporting capabilities

### Development Progress

The current implementation is built on the Bullet Train framework, which provides:
- Team-based multitenancy
- Built-in authentication and authorization
- API infrastructure
- Testing framework

The project has evolved from a simple training management system to a comprehensive platform with advanced features for training delivery, progress tracking, and certification management.

### Next Steps

Based on the implementation status documents, the following areas still need work:

1. **Vue.js Training Player**: In progress but not fully implemented
2. **Payment Processing**: Not started
3. **Analytics Dashboard**: Not started
4. **API Documentation**: Partially complete
5. **Performance Optimization**: Not started

## Current Development Focus

Based on the analysis of the original specifications, current implementation status, and project priorities, I'm focusing on the following areas:

### 1. Vue.js Training Player Completion

The Vue.js Training Player is a critical component that's currently at approximately 75% completion. The remaining work includes:

1. **Content Management System**:
   - Implement the interface for managing training content
   - Add content type selection (video, quiz, text)
   - Create content editing capabilities
   - Implement content ordering and sequencing

2. **Advanced Filtering**:
   - Add filtering by content type
   - Implement search functionality
   - Add sorting options
   - Create filter persistence

3. **UI Enhancements**:
   - Improve responsive design
   - Add loading states and animations
   - Enhance accessibility features
   - Implement error handling and recovery

### 2. API Documentation

The API documentation is partially complete but needs significant work:

1. **Endpoint Documentation**:
   - Document all existing API endpoints
   - Include request/response examples
   - Add authentication requirements
   - Document error responses

2. **Getting Started Guide**:
   - Create comprehensive onboarding documentation
   - Add authentication setup instructions
   - Include example workflows
   - Provide SDK examples if applicable

3. **Role-Specific Documentation**:
   - Document endpoints available to each role
   - Include role-specific examples
   - Add permission requirements
   - Document role-based limitations

Progress on these areas will be tracked here, with regular updates as features are completed or issues are encountered.

## Documentation Updates

### Standardization to Bullet Train Conventions

As part of our alignment with Bullet Train conventions, the following documentation updates have been made:

1. **Directory Structure Documentation**:
   - Updated `docs/DIRECTORY_STRUCTURE.md` with comprehensive directory information
   - Deprecated `docs/DIRECTORY-STRUCTURE.md` (with hyphen) in favor of the underscore version
   - Added more detailed descriptions of key files and directories
   - Organized structure to match Bullet Train's conventions
   - Added information about namespaced controllers and views

2. **Documentation Format**:
   - Standardized markdown formatting across documentation files
   - Added last updated timestamps
   - Improved readability with consistent headings and lists
   - Removed redundant checkmarks and symbols in favor of clean text

## Demo Script Implementation

### Automated Demo Workflow

To facilitate demonstrations and testing, an automated demo script has been implemented:

1. **Puppeteer-Based Automation**:
   - Created `bin/demo-script.js` for automated workflow demonstration
   - Implemented browser automation with Puppeteer
   - Added screenshot capture at key points
   - Included detailed logging for each step
   - Added database reset functionality with `--reset-db` option
   - Implemented robust error handling for database operations
   - Added interactive prompt to continue without database reset if it fails
   - Added automatic handling of onboarding process after login
   - Implemented resilient detection and completion of team creation forms
   - Enhanced dashboard detection with multiple selector fallbacks
   - Added comprehensive error handling for missing UI elements
   - Implemented flexible form submission with fallback methods
   - Improved seed data handling to manage duplicate records gracefully

2. **Multiple Scenario Support**:
   - Implemented basic scenario (default) - complete workflow from scratch
   - Implemented advanced scenario with pre-seeded data
   - Created seed data for advanced scenario in `db/seeds/advanced.rb`
   - Added Rake task for loading advanced scenario seed data
   - Fixed workflow state management in seed data to use proper model methods
   - Added proper pricing model associations for training programs
   - Improved error handling for seed data loading

3. **Complete Workflow Demonstration**:
   - Basic scenario:
     - Admin adding a customer
     - Customer creating a training program with video content and quiz
     - Customer inviting vendors
     - Vendor inviting employees
     - Employee completing training and earning certificate
   - Advanced scenario:
     - Admin managing multiple customers
     - Customer managing multiple training programs
     - Customer managing multiple vendors
     - Vendor managing multiple employees
     - Employee completing multiple trainings

4. **Documentation**:
   - Created `docs/DEMO_SCRIPT.md` with comprehensive instructions
   - Added quick reference guide in `bin/README-demo-script.md`
   - Included command-line options documentation
   - Added troubleshooting and customization guides