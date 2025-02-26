# Changelog

All notable changes to the VendorSafe training platform will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Facility to Location consolidation with GeoJSON support:
  - Created a BulletTrain GeoJSON fields gem for handling geospatial data
  - Added geometry column to Locations table for storing GeoJSON data
  - Implemented Locations API with geospatial query capabilities
  - Created data migration scripts to move Facilities data to Locations
  - Established mapping between Facilities and Locations for backward compatibility
  - Added comprehensive test coverage for the new API endpoints
  - Created implementation scripts for automated deployment
  - Documented in COMPLETION_REPORT_2025-02-25-FACILITY-TO-LOCATION.md
  - Detailed next steps in NEXT-STEPS-FACILITY-TO-LOCATION.md
  - Added support for hierarchical location relationships (parent/child)
  - Implemented geospatial queries (near a point, by geometry type)
  - Created a reusable GeoJSON field type for Bullet Train
  - Added Mapbox integration for map visualization
  - Created Stimulus controllers for map input and display
  - Added field partials for forms and display
  - Implemented a systematic 10-step process for the implementation

- Created a new 10-step process for addressing API controller issues:
  - Documented in COMPLETION_REPORT_2025-02-25-API-CONTROLLERS.md
  - Follows the systematic testing approach from golden rules
  - Provides a methodical approach to fixing API controller test failures
  - Includes detailed implementation plan and expected outcomes

- Created a 10-step process for addressing Training Questions API controller issues:
  - Documented in COMPLETION_REPORT_2025-02-25-API-QUESTIONS-CONTROLLERS.md
  - Follows the same systematic testing approach
  - Focuses specifically on the Training Questions API endpoints
  - Provides a detailed implementation plan for fixing the issues

- Comprehensive test infrastructure:
  - System tests with headless/browser mode toggle
  - Factory definitions for all training models
  - Test helpers and utilities
  - Documentation and best practices
  - Screenshot and debugging support
  - VCR integration for HTTP mocking
  - Coverage reporting configuration

- State management to training programs with workflow transitions (draft, published, archived)
- Completion fields to training programs
- Progress tracking to training memberships with completion percentage and status tracking
- Training invitations feature
- Training progress tracking
- Support for faker gem
- Confirmable module to users
- Activities tracking system
- Vue.js training program player with:
  - Interactive video player with progress tracking
  - Quiz system with multiple choice and true/false questions
  - Progress bar with module navigation
  - Real-time progress synchronization
  - Certificate generation on completion
  - Responsive design with Tailwind CSS
  - State management with Pinia
  - Comprehensive test coverage
  - Advanced filtering for training content
  - Offline support with service worker
  - Certificate viewer component
  - Performance optimizations
- Training program state management
- Certificate generation system with:
  - Automatic certificate number generation
  - QR code generation for verification
  - Certificate validity period tracking
  - Custom certificate fields support
  - Certificate verification endpoints
  - Certificate data serialization
- Service worker for offline support:
  - Caching of training program data
  - Offline progress tracking
  - Background synchronization
  - Offline fallback page
  - Network status indicators
- Comprehensive documentation:
  - GOLDEN-RULES.md for development best practices
  - BULLET-TRAIN-GOLDEN-RULES.md for Bullet Train specific conventions
  - Focused testing approach for debugging complex issues
  - Documentation on using bin-wrapped commands (bin/rails, bin/rake)
  - 10-step systematic testing process for methodical problem-solving
  - One-step-one-test rule for structured test organization
- Comprehensive role-based system:
  - Administrator role with full system access
  - Training Manager role with program management
  - Instructor role with content management
  - Trainee role with program access
- Role-specific permissions and features:
  - Program creation and management
  - Certificate issuance and verification
  - Content creation and editing
  - Progress monitoring and reporting
- Seeding system with role-based examples:
  - Sample users for each role
  - Role-specific permissions
  - Progress tracking data
  - Certificate examples

### Changed

- Implemented customer/vendor/employee role structure:
  - Customer: Creates and manages training programs
  - Vendor: Team manager with training access and employee management
  - Employee: Individual team member taking training
- Enhanced team-based access control:
  - Added team-specific content visibility
  - Implemented role-based permission checks
  - Added team progress tracking
- Improved sequential progression system:
  - Added strict content order enforcement
  - Implemented dependency checking
  - Added progress tracking with team context
- Enhanced activity tracking:
  - Added completion activity tracking
  - Tracked team-based progress
  - Added role-specific activity parameters
  - Configured PublicActivity with jsonb parameters
  - Added activity tracking to all training models
  - Implemented team-based activity ownership
- Integrated with Bullet Train's team system:
  - Leveraged built-in team management
  - Used team-based invitations
  - Added team-scoped queries
- Improved user authentication flow with confirmable
- Updated training content management system
- Implemented role-based access control improvements
- Standardized documentation to follow Bullet Train conventions:
  - Updated all documentation files
  - Improved formatting and organization
  - Added last updated timestamps
  - Removed redundant symbols and checkmarks
- Added automated demo script:
  - Created `bin/demo-script.js` for Puppeteer-based workflow demonstration
  - Implemented complete workflow from admin to employee
  - Added comprehensive documentation in `docs/DEMO_SCRIPT.md`
  - Added database reset functionality with `--reset-db` option
  - Implemented multiple scenarios (basic and advanced)
  - Created seed data for advanced scenario in `db/seeds/advanced.rb`
  - Added Rake task for loading advanced scenario seed data
  - Fixed database reset functionality to handle errors gracefully
  - Updated advanced seed file to use correct workflow state management
  - Added interactive prompt to continue without database reset if it fails
  - Added onboarding process handling after login for all user roles
  - Improved script resilience by handling team creation during first login
  - Enhanced dashboard detection with multiple selector fallbacks
  - Improved error handling for missing UI elements
  - Fixed seed data to handle duplicate user records
  - Added more robust form submission with fallback methods

### Removed

- Removed custom training_invitations table and model in favor of Bullet Train's built-in invitation system
- Removed custom role implementation code
- Removed redundant invitation handling logic
- Removed duplicate DIRECTORY-STRUCTURE.md file (with hyphen) in favor of DIRECTORY_STRUCTURE.md (with underscore)

### Fixed

- Fixed issue with missing faker gem
- Removed unnecessary migration `20250224192215_add_content_fields_to_training_contents.rb` since the column `content_type` already exists in the `training_contents` table
- Fixed training program state transitions
- Resolved user confirmation email issues
- Fixed activity tracking in training programs
- Fixed training program workflow state management to properly handle state transitions and validations
- Fixed column name mismatch in TrainingProgram model:
  - Changed `workflow_column :workflow_state` to `workflow_column :state` to match the actual database column
  - Updated `after_initialize` callback to use `self.state` instead of `self.workflow_state`
  - Updated factory definition to use `state` instead of `workflow_state`
  - Created GOLDEN-RULES.md to document naming convention best practices
- Fixed completion percentage calculation in TrainingProgram model:
  - Implemented the `completion_percentage_for` method to calculate completion percentage based on completed content
  - Added support for handling edge cases like programs with no content and non-enrolled trainees
  - Implemented the `mark_complete_for` method in TrainingContent model to properly update completion percentage
  - Created focused tests for completion percentage calculation
  - Added a new golden rule about creating datetime-stamped completion reports
- Created focused test files for API controllers:
  - Implemented comprehensive test cases for TrainingPrograms API endpoints
  - Implemented comprehensive test cases for TrainingQuestions API endpoints
  - Added tests for happy paths, edge cases, and error conditions
  - Included tests for authentication and authorization
  - Added tests for progress tracking and certificate generation
  - Created `bin/run-focused-api-tests.sh` script to run the focused tests
  - Added `README-focused-api-tests.md` with documentation on the testing approach
  - Created fixed versions of API routes and controllers to address identified issues
  - Added `bin/apply-api-fixes.sh` script to apply and test the fixes
  - Created `docs/API-CONTROLLER-FIXES.md` with detailed explanation of the fixes
  - Added new golden rule about non-interactive scripts to GOLDEN-RULES.md
- Fixed training content validation issues in tests:
  - Updated training_player_test.rb to use proper factory traits (:video, :document, :quiz)
  - Ensured content_data includes required media URLs for video and document content
- Fixed inconsistencies in the training certificate system:
  - Added verification code generation to the TrainingCertificate model
  - Fixed verification URL generation to use verification_code consistently
  - Updated PDF generation job to use the model's verification_url method
  - Removed unused completion_status field from certificate creation form
  - Fixed field naming inconsistencies in system tests (expiry_date vs expires_at, grade vs score)
  - Fixed user reference inconsistencies in system tests (user vs membership)
  - Fixed route helper inconsistencies in system tests

## [0.1.0] - 2025-01-15

### Added

- Initial project setup with Bullet Train
- Basic training program model
- Team-based multitenancy
- User authentication with Devise
- Role-based access control
- Basic API endpoints
- Initial test infrastructure
