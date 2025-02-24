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
    - State management (draft, published, archived)
    - Workflow transitions with validations
    - Completion tracking and deadlines
    - Passing percentage requirements
    - Supports Vue.js player integration (pending)

5. **TrainingMemberships** (Progress & Access Control)
    - Links users to training programs
    - Tracks detailed progress in JSON format
    - Calculates completion percentages
    - Records time spent per content
    - Manages completion status
    - Handles automatic certification
    - Supports content-specific progress

5. **TrainingContent** (Modular content units)
   - Individual content modules
   - Supports various content types
   - Organized within programs
   - Integrated with Vue.js player

6. **TrainingQuestions** (Assessment system)
   - Question management
   - Answer validation
   - Progress tracking
   - Real-time feedback

7. **TrainingMemberships** (Access control)
   - Links users to training programs
   - Manages certification validity
   - Tracks progress
   - Handles invitations

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

## Training Program Player with Vue.js

### Overview
The Training Program Player is a Vue.js-based component that provides an interactive interface for users to engage with training content. It supports various content types including video, text, and quizzes.

### Features
- Multi-format content support
- Progress tracking
- Interactive quizzes
- Certificate generation
- Real-time updates

### Setup
The player is automatically included in the asset pipeline. To use it in your views:

```erb
<%%= render "training_programs/player", training_program: @training_program %>
```

### Components
1. **VideoPlayer**
   - Supports multiple video formats
   - Progress tracking
   - Playback controls

2. **ContentViewer**
   - Text content display
   - Image galleries
   - Document viewers

3. **QuizSystem**
   - Multiple question types
   - Real-time validation
   - Progress tracking

4. **ProgressTracker**
   - Visual progress indicators
   - Completion status
   - Achievement tracking

### API Integration
The player automatically integrates with the VendorSafe API endpoints:
- `/api/v1/training_programs/:id`
- `/api/v1/training_programs/:id/progress`
- `/api/v1/training_programs/:id/complete`

### State Management
Uses Pinia for state management with the following stores:
- `trainingProgramStore`
- `progressStore`
- `userStore`

### Customization
The player can be customized through:
- Tailwind CSS classes
- Vue.js props
- Event handlers
- Custom components

For detailed customization options, see the Vue.js component documentation in `app/javascript/training-program-viewer/README.md`.

## State Management & Progress Tracking

### Training Program States

Training programs follow a workflow with three states:
- **Draft**: Initial state for new programs
- **Published**: Available for users to take
- **Archived**: No longer active but preserved for records

```ruby
# State transitions
training_program = TrainingProgram.create!(name: "Safety Training", team: team)
training_program.draft?      # => true (default state)
training_program.publish!    # => transitions to published
training_program.archive!    # => transitions to archived
training_program.restore!    # => back to published
training_program.unpublish!  # => back to draft
```

### Progress Tracking

Progress is tracked per user through TrainingMembership:

```ruby
# Track progress for a specific content
membership = training_program.training_memberships.find_by(membership: current_membership)
membership.update_progress(
  content_id: 1,
  status: "completed",
  time_spent: 300 # seconds
)

# Check progress
membership.content_progress(content_id: 1)
# => {"status" => "completed", "time_spent" => 300, "updated_at" => "2025-02-24T..."}

# Get completion percentage
membership.completion_percentage # => 75

# Check if completed
membership.completed? # => true/false

# Get completion time
membership.completed_at # => returns completion timestamp if completed
```

### Completion Requirements

Training programs can specify completion requirements:

```ruby
training_program.update!(
  passing_percentage: 80,           # Minimum percentage to pass
  completion_timeframe: 30,         # Days allowed to complete
  completion_deadline: 1.month.from_now # Absolute deadline
)
```

For more details on implementing specific workflows, see the model documentation in `app/models/training_program.rb` and `app/models/training_membership.rb`.
