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