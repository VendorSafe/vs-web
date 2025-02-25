# Bullet Train Golden Rules

This document outlines key conventions, practices, and features specific to Bullet Train that are used in the VendorSafe training platform.

Last updated: February 25, 2025

## Core Concepts

### 1. Bullet Train Framework Structure

Bullet Train is a Ruby on Rails application template that provides a foundation for building SaaS applications. It includes:

- Multi-tenancy via Teams
- User authentication and authorization
- Role-based permissions
- Invitation system
- Responsive UI with Tailwind CSS
- Super Scaffolding for rapid development

### 2. Local Bullet Train Gems

When using the `bin/hack` command, Bullet Train clones the core gems locally for development. These can be found at:

```
~/bullet_train
~/bullet_train-api
~/bullet_train-incoming_webhooks
~/bullet_train-integrations
~/bullet_train-integrations-stripe
~/bullet_train-obfuscates_id
~/bullet_train-outgoing_webhooks
~/bullet_train-scope_questions
~/bullet_train-sortable
~/bullet_train-super_scaffolding
~/bullet_train-themes
~/bullet_train-themes-light
```

To access documentation for these gems, you can:
1. Navigate to the gem directory
2. Check the README.md file
3. Review the source code for implementation details

## Libraries and Dependencies

### 1. Core Libraries Maintained by Bullet Train

- **Bullet Train Core**: The main framework (`@bullet-train/bullet-train`)
- **Bullet Train Themes**: Theming system (`@bullet-train/bullet-train-themes`)
- **Bullet Train Sortable**: Drag-and-drop sorting (`@bullet-train/bullet-train-sortable`)
- **Bullet Train Fields**: Form field components (`@bullet-train/fields`)

### 2. Third-Party Libraries Integrated with Bullet Train

- **Devise**: Authentication
- **CanCanCan**: Authorization
- **Hotwire (Turbo & Stimulus)**: Modern frontend
- **Tailwind CSS**: Utility-first CSS framework
- **Stripe**: Payment processing
- **OAuth Providers**: Social login

### 3. VendorSafe-Specific Libraries

- **Vue.js**: Used for the training player
- **Pinia**: State management for Vue.js
- **Service Worker API**: For offline support

## Script Directory (`bin/`)

### 1. Bullet Train Scripts

- **`bin/setup`**: Initial project setup
- **`bin/dev`**: Start the development server
- **`bin/rails`**: Rails command wrapper (always use this instead of `rails` directly)
- **`bin/rake`**: Rake command wrapper (always use this instead of `rake` directly)
- **`bin/yarn`**: Yarn command wrapper
- **`bin/hack`**: Clone and use local versions of Bullet Train gems
- **`bin/super-scaffold`**: Generate scaffolding with Bullet Train conventions
- **`bin/resolve`**: Resolve gem dependencies
- **`bin/reset-dependencies`**: Reset all dependencies
- **`bin/link`**: Link local Bullet Train gems
- **`bin/theme`**: Theme management commands

> **IMPORTANT**: Always use the bin-wrapped versions of commands (e.g., `bin/rails` instead of `rails`) as they include proper environment setup and gem loading specific to Bullet Train.

### 2. VendorSafe-Specific Scripts

- **`bin/demo-script.js`**: Puppeteer script for demonstrating the application
- **`bin/copy-service-worker.js`**: Script to copy service worker to public directory
- **`bin/create-milestones.js`**: Script to create GitHub milestones from markdown
- **`bin/directory-structure`**: Generate directory structure documentation
- **`bin/roles-setup`**: Set up roles and permissions
- **`bin/setup-demo`**: Set up demo environment
- **`bin/vendorsafe-structure`**: Generate VendorSafe-specific structure documentation

## Theming System

### 1. Theme Structure

Bullet Train uses a theming system that allows for multiple themes:

```
app/assets/stylesheets/application.tailwind.css
app/assets/stylesheets/mailers.tailwind.css
```

### 2. Ejecting Themes

To customize a theme, you can eject it from the Bullet Train gems:

```bash
bin/theme eject light
```

This copies the theme files to your local project, allowing for customization:

```
app/assets/stylesheets/themes/light/
```

### 3. Theme Configuration

Themes are configured in:

```
tailwind.config.js
postcss.config.js
```

## Multi-tenancy and Team Management

### 1. Team Model

The core of Bullet Train's multi-tenancy is the `Team` model:

- Teams represent separate tenants
- Users can belong to multiple teams
- Each team has its own data isolation

### 2. Membership Model

The `Membership` model connects users to teams:

- Represents a user's membership in a team
- Stores role information
- Handles team-specific user settings

### 3. Invitation System

Bullet Train provides a complete invitation system:

- `Invitation` model for pending invitations
- Email delivery with secure tokens
- Acceptance flow for new and existing users

## Role-Based Permissions

### 1. Role System

Bullet Train uses a role system defined in:

```
lib/roles/
```

Key components:
- Role definitions
- Permission mappings
- Role inheritance

### 2. Permission Checking

Permissions are checked using:

```ruby
# In controllers
authorize! :manage, @resource

# In models
membership.can?(:manage, resource)

# In views
<% if can? :manage, resource %>
```

### 3. VendorSafe Role Structure

VendorSafe extends the Bullet Train role system with:

- Administrator: Full system access
- Training Manager: Program management
- Instructor: Content management
- Trainee: Program access

## Super Scaffolding

### 1. Generating Resources

Super Scaffolding generates resources with Bullet Train conventions:

```bash
bin/super-scaffold resource Team Post title:string body:text
```

### 2. Scaffolding Conventions

- Namespaced under teams
- Includes proper authorization
- Generates tests
- Creates localization files
- Sets up proper routes

### 3. Customizing Scaffolds

Custom scaffolds can be defined in:

```
lib/bullet_train/super_scaffolding/
```

## Best Practices

### 1. Team Scoping

**Rule**: Always scope resources to teams for proper multi-tenancy.

**Example**:
```ruby
# CORRECT
class Post < ApplicationRecord
  belongs_to :team
  validates :team, presence: true
end

# In controllers
@posts = current_team.posts
```

**Why It's Good**:
- Ensures data isolation between tenants
- Prevents data leakage
- Follows Bullet Train's multi-tenancy model

### 2. Using Bullet Train Helpers

**Rule**: Use Bullet Train's built-in helpers for common patterns.

**Example**:
```ruby
# CORRECT
# In models
include Sortable

# In views
<%= render 'shared/fields/text_field', form: form, method: :name %>
```

**Why It's Good**:
- Maintains consistency across the application
- Leverages built-in functionality
- Makes upgrades easier

### 3. Following Naming Conventions

**Rule**: Follow Bullet Train's naming conventions for controllers, views, and routes.

**Example**:
```ruby
# CORRECT
# Routes
namespace :account do
  resources :teams do
    resources :posts
  end
end

# Controllers
module Account
  class PostsController < Account::ApplicationController
  end
end
```

**Why It's Good**:
- Works with Bullet Train's authorization system
- Maintains consistent URL structure
- Follows established patterns

### 4. Using Workflow for State Management

**Rule**: Use the Workflow gem for state management with proper column naming.

**Example**:
```ruby
# CORRECT
include Workflow
workflow_column :state

workflow do
  state :draft do
    event :publish, transitions_to: :published
  end
  
  state :published do
    event :archive, transitions_to: :archived
  end
end
```

**Why It's Good**:
- Provides clear state transitions
- Integrates with Bullet Train's conventions
- Makes state management explicit

## Common Issues and Solutions

### 1. Dependency Management

**Issue**: Gem version conflicts or JavaScript dependency issues.

**Solution**: Use the reset-dependencies script:
```bash
bin/reset-dependencies
```

### 2. Theme Customization

**Issue**: Theme changes not appearing.

**Solution**: Eject the theme and make changes to local files:
```bash
bin/theme eject light
```

### 3. Authorization Errors

**Issue**: Unexpected authorization failures.

**Solution**: Check role definitions in `lib/roles/` and ensure proper team scoping.

### 4. Super Scaffolding Errors

**Issue**: Super scaffolding generates incorrect code.

**Solution**: Check for custom field types and ensure proper model relationships.