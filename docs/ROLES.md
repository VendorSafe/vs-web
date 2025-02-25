# Role Architecture Documentation

This document outlines the role architecture used in the VendorSafe training platform, following Bullet Train conventions.

Last updated: February 24, 2025

## Current Role Structure

The system uses four primary roles: Admin, Customer, Vendor, and Employee. These roles are designed to provide clear separation of concerns and hierarchical access control.

### Admin
- **Role:** System administrator with full access
- **Capabilities:**
  - Manage all customers, vendors, and employees
  - Create and manage training programs
  - Configure system-wide settings
  - View and manage payments history
  - Generate and manage certificates
  - Access comprehensive reports
  - Manage platform applications and API access

### Customer
- **Role:** Organization creating and managing training programs
- **Capabilities:**
  - Create and manage vendors
  - View and manage employees
  - View training list and information
  - Send training requests
  - View employee certificates
  - Access role-specific reports
  - Share and download certificates
  - Manage team profile

### Vendor
- **Role:** Team manager or company representative
- **Capabilities:**
  - Create and manage employees
  - View assigned training programs
  - Pay for training programs
  - Send training requests to employees
  - Track team progress
  - View and manage certificates
  - View training information
  - Manage team profile

### Employee
- **Role:** Individual team member taking training
- **Capabilities:**
  - View training requests
  - Take assigned training programs
  - Complete training content sequentially
  - View training results
  - Earn certificates upon completion
  - View and manage personal certificates
  - Share and download certificates
  - Manage personal profile

## Integration with Bullet Train

The role system is implemented using Bullet Train's built-in role architecture:

1. **Role Definition**
   - Roles are defined in `config/models/roles.yml`
   - Each role has specific permissions and capabilities
   - Roles can inherit permissions from other roles

2. **Team-Based Access**
   - Roles are assigned at the membership level
   - Each user can have different roles in different teams
   - Permissions are scoped to the team context

3. **Authorization**
   - CanCanCan is used for authorization
   - Permissions are defined in `app/models/ability.rb`
   - Role-specific abilities are automatically loaded

## Pros of Current Structure

1. **Clear Separation of Concerns**
   - Admin focuses on system management
   - Customers focus on vendor management
   - Vendors handle team management
   - Employees focus on learning

2. **Hierarchical Access Control**
   - Natural flow of permissions
   - Clear responsibility chain
   - Easy to understand who can do what

3. **Team-Based Organization**
   - Vendors can manage their own teams
   - Employees belong to specific vendor teams
   - Training access controlled at team level

4. **Scalability**
   - Supports multiple customer organizations
   - Each vendor can have multiple employees
   - Training programs can be shared across vendors

## Challenges and Considerations

1. **Limited Flexibility**
   - Fixed hierarchy might not fit all use cases
   - Some organizations might need hybrid roles
   - Cross-team collaboration could be complex

2. **Permission Granularity**
   - Might need more fine-grained controls
   - Some vendors might need partial author rights
   - Special cases might need custom permissions

3. **Team Structure Assumptions**
   - Assumes clear vendor-employee hierarchy
   - Might not fit flat organizations
   - Could be complex for contractors

## Alternative Approaches

### 1. Role-Based Access Control (RBAC)
- **Pros:**
  * More flexible permission assignment
  * Can mix and match capabilities
  * Better for complex organizations
- **Cons:**
  * More complex to manage
  * Could lead to permission conflicts
  * Harder to understand structure

### 2. Attribute-Based Access Control (ABAC)
- **Pros:**
  * Very flexible and dynamic
  * Can handle complex rules
  * Supports fine-grained control
- **Cons:**
  * Much more complex to implement
  * Higher maintenance overhead
  * Could impact performance

### 3. Multi-Tenant with Custom Roles
- **Pros:**
  * Each organization defines their roles
  * Maximum flexibility
  * Supports unique workflows
- **Cons:**
  * Complex to implement
  * Harder to maintain
  * Could lead to inconsistencies

## Implementation Details

### Database Schema

The role system is implemented using the following database structure:

1. **Users Table**
   - Standard Devise authentication fields
   - Profile information

2. **Teams Table**
   - Organization information
   - Team settings and preferences

3. **Memberships Table**
   - Joins users and teams
   - Contains `role_ids` as a JSONB field
   - Stores role-specific settings

4. **Roles**
   - Defined in YAML configuration
   - Loaded as ApplicationHash objects
   - Referenced by ID in memberships

### Code Implementation

The role system is implemented in the following files:

1. **Role Definition**
   - `config/models/roles.yml` - Role definitions
   - `app/models/role.rb` - Role model with class methods

2. **Role Assignment**
   - `app/models/membership.rb` - Includes `Roles::Support`
   - `app/controllers/account/memberships_controller.rb` - Role assignment UI

3. **Authorization**
   - `app/models/ability.rb` - CanCanCan ability definitions
   - `app/controllers/application_controller.rb` - Authorization helpers

## Future Considerations

1. **Role Extensions**
   - Consider adding sub-roles
   - Support for temporary permissions
   - Role delegation capabilities

2. **Permission Inheritance**
   - More sophisticated inheritance rules
   - Custom permission templates
   - Role composition

3. **Integration Support**
   - SSO role mapping
   - API access control
   - Third-party integrations

4. **Audit and Compliance**
   - Role change tracking
   - Permission audit logs
   - Compliance reporting
