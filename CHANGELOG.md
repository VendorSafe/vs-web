# Changelog

## Unreleased

### Added

*   Added completion fields to training programs
*   Added training invitations feature
*   Added training progress tracking
*   Added support for faker gem

### Changed

*   Updated routes to handle training invitations
*   Updated TrainingInvitationsController to handle invitation flow

### Fixed

*   Fixed issue with missing faker gem
*   Removed unnecessary migration `20250224192215_add_content_fields_to_training_contents.rb` since the column `content_type` already exists in the `training_contents` table
