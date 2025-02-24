# Bullet Train Starter Repository Changelog
This file is limited to breaking or potentially breaking changes. Please review any new items carefully when upgrading your application.

## February 24, 2025
 - **Breaking**: Changed Facility model to Location model with hierarchical structure support
   - If upgrading, you'll need to migrate existing facility data to the new location structure
   - Added parent/child relationships for locations
   - Enabled real-time updates via CableReady
 - Added PricingModel for flexible training program pricing
   - Supports fixed and variable pricing strategies
   - Includes volume discount capabilities
   - Integrated with TrainingProgram model
 - Enhanced real-time updates across the application
   - Locations and PricingModels now update in real-time via CableReady
   - Improved team-based multitenancy enforcement

## March 7, 2023
 - `rails db:migrate` and `rails db:seed` will now automatically be run on deploy to Heroku or Render. For more information about why we want seeds run on every deploy, see [Database Seeds](http://bullettrain.co/docs/seeds) in our documentation.
