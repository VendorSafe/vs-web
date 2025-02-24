# Changelog

## Unreleased

### Added

*   Added state management to training programs with workflow transitions (draft, published, archived)
*   Added completion fields to training programs
*   Added progress tracking to training memberships with completion percentage and status tracking
*   Added training invitations feature
*   Added training progress tracking
*   Added support for faker gem
*   Added confirmable module to users
*   Added activities tracking system
*   Added Vue.js training program player integration
*   Added training program state management
*   Added certificate generation system

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
