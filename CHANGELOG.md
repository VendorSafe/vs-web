# Changelog

## Unreleased

### Added

*   Added comprehensive test infrastructure:
    - System tests with headless/browser mode toggle
    - Factory definitions for all training models
    - Test helpers and utilities
    - Documentation and best practices
    - Screenshot and debugging support
    - VCR integration for HTTP mocking
    - Coverage reporting configuration

*   Added state management to training programs with workflow transitions (draft, published, archived)
*   Added completion fields to training programs
*   Added progress tracking to training memberships with completion percentage and status tracking
*   Added training invitations feature
*   Added training progress tracking
*   Added support for faker gem
*   Added confirmable module to users
*   Added activities tracking system
*   Added Vue.js training program player with:
    - Interactive video player with progress tracking
    - Quiz system with multiple choice and true/false questions
    - Progress bar with module navigation
    - Real-time progress synchronization
    - Certificate generation on completion
    - Responsive design with Tailwind CSS
    - State management with Pinia
    - Comprehensive test coverage
*   Added training program state management
*   Added certificate generation system with:
    - Automatic certificate number generation
    - QR code generation for verification
    - Certificate validity period tracking
    - Custom certificate fields support
    - Certificate verification endpoints
    - Certificate data serialization
*   Added comprehensive role-based system:
    - Administrator role with full system access
    - Training Manager role with program management
    - Instructor role with content management
    - Trainee role with program access
*   Added role-specific permissions and features:
    - Program creation and management
    - Certificate issuance and verification
    - Content creation and editing
    - Progress monitoring and reporting
*   Added seeding system with role-based examples:
    - Sample users for each role
    - Role-specific permissions
    - Progress tracking data
    - Certificate examples

### Changed

*   Updated routes to handle training invitations
*   Updated TrainingInvitationsController to handle invitation flow
*   Enhanced training program model with completion tracking
*   Improved user authentication flow with confirmable
*   Updated training content management system
*   Implemented role-based access control improvements

### Fixed

*   Fixed issue with missing faker gem
*   Removed unnecessary migration `20250224192215_add_content_fields_to_training_contents.rb` since the column `content_type` already exists in the `training_contents` table
*   Fixed training program state transitions
*   Resolved user confirmation email issues
*   Fixed activity tracking in training programs
