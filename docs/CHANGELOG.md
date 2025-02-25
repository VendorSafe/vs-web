# Changelog

All notable changes to the VendorSafe training platform will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

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
- Training program state management
- Certificate generation system with:
  - Automatic certificate number generation
  - QR code generation for verification
  - Certificate validity period tracking
  - Custom certificate fields support
  - Certificate verification endpoints
  - Certificate data serialization
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
