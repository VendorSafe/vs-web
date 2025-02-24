# VendorSafe.app

## Database Setup and Structure

### Quick Start
To set up a fresh database with the complete structure:

```bash
# Make sure the script is executable
chmod +x bin/vendorsafe-structure

# Run the structure builder
./bin/vendorsafe-structure
```

### Core Tables and Structure

1. **Teams** (Multi-tenancy support)
   - Central organization unit
   - Has many locations and training programs
   - Manages team-wide settings

2. **Locations** (Physical locations hierarchy)
   - Supports parent/child relationships
   - Used for organizing training requirements
   - Hierarchical structure for complex organizations

3. **PricingModels** (Flexible pricing strategies)
   - Supports fixed and variable pricing
   - Handles volume discounts
   - Links to training programs

4. **TrainingPrograms** (Core content management)
   - Manages training content and structure
   - Links to pricing models
   - Controls certification rules

5. **TrainingContent** (Modular content units)
   - Individual content modules
   - Supports various content types
   - Organized within programs

6. **TrainingQuestions** (Assessment system)
   - Question management
   - Answer validation
   - Progress tracking

7. **TrainingMemberships** (Access control)
   - Links users to training programs
   - Manages certification validity
   - Tracks progress

### Initial Setup

After running the structure builder, use the Rails console to create your initial admin user and team:

```ruby
# Create initial team
team = Team.create!(
  name: "Admin Team",
  time_zone: "Pacific Time (US & Canada)"
)

# Create admin user
admin = User.create!(
  email: "admin@example.com",
  password: "password",
  password_confirmation: "password",
  first_name: "Admin",
  last_name: "User",
  time_zone: "Pacific Time (US & Canada)"
)

# Add admin to team
Membership.create!(
  user: admin,
  team: team,
  role_ids: ["admin"]
)
```

## Role System

### Quick Start
To set up the role system with predefined roles:

```bash
# Make sure the script is executable
chmod +x bin/roles-setup

# Run the role setup
./bin/roles-setup
```

### Role Types and Capabilities

1. **Administrator**
   - Full system access
   - Manage teams and memberships
   - Manage all locations
   - Control pricing models
   - Oversee training programs
   - Access all reports

2. **Vendor**
   - View assigned locations
   - Manage own training programs
   - Issue certificates
   - View own reports
   - Access assigned content

3. **Customer**
   - Manage own location
   - Purchase training
   - Assign training to employees
   - View team certificates
   - Access team reports

4. **Employee**
   - Access assigned training
   - Take training modules
   - View own certificates
   - Track own progress

### Implementation Details

The role system uses Bullet Train's built-in role management and adds custom capabilities through:
- `config/models/roles.yml`: Role definitions
- `app/models/concerns/roles.rb`: Role behavior
- `config/initializers/roles.rb`: Role configuration

### Usage Examples

```ruby
# Check roles
membership.admin?
membership.vendor?
membership.customer?
membership.employee?

# Check capabilities
membership.can_manage_team?
membership.can_manage_locations?
membership.can_manage_training_programs?
membership.can_view_certificates?
```

# Training Program Player with Vue.js
