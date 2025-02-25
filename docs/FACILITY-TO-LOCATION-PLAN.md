# Facility to Location Consolidation Plan

**Date: February 25, 2025**
**Author: Roo**

## Executive Summary

This document outlines a comprehensive plan to consolidate the Facilities model into the existing Locations model, enhancing it with GeoJSON capabilities. This consolidation will simplify the customer experience while providing more flexibility for organizing training programs by area, department, vendor type, or employee category.

## Background

Currently, our system has two similar but distinct models:

1. **Facilities**: A flat structure with basic attributes
2. **Locations**: A hierarchical structure with parent-child relationships

The Locations model is better suited for our needs as it already supports hierarchical organization, which aligns with our goal of allowing customers to break down training programs into areas or types of employees/vendors.

## Goals

1. Simplify the customer signup experience
2. Provide flexible organization of training programs
3. Add geospatial capabilities through GeoJSON
4. Consolidate redundant models
5. Document best practices for Bullet Train super-scaffolding
6. Create a reusable gem for GeoJSON fields that can be contributed back to the Bullet Train project

## Technical Implementation Plan

### 1. Create GeoJSON Fields Gem

We've created a new gem `bullet_train-fields-geojson` that provides:

- A `has_geojson_field` method for models
- Validation and helper methods for GeoJSON data
- Map-based input and display components
- Stimulus controllers for interactive maps
- View helpers and partials following Bullet Train conventions

This gem follows Bullet Train naming conventions and directory structure, making it easy to contribute back to the open source project.

### 2. Database Changes

#### 2.1 Add GeoJSON Support

Create a migration to add GeoJSON capabilities:

```ruby
class AddGeometryToLocations < ActiveRecord::Migration[7.2]
  def up
    # Enable PostGIS extension
    enable_extension "postgis" unless extension_enabled?("postgis")
    
    # Add geometry column
    add_column :locations, :geometry, :jsonb, default: {}, null: true
    add_index :locations, :geometry, using: :gin
  end
  
  def down
    remove_index :locations, :geometry
    remove_column :locations, :geometry
  end
end
```

#### 2.2 Data Migration

Create a migration to transfer data from Facilities to Locations:

```ruby
class ConsolidateFacilitiesToLocations < ActiveRecord::Migration[7.2]
  def up
    # Create a mapping table to track the relationship between facilities and locations
    create_table :facility_location_mappings do |t|
      t.references :facility, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.timestamps
    end
    
    # Copy data from facilities to locations
    execute <<-SQL
      INSERT INTO locations (team_id, name, location_type, address, created_at, updated_at)
      SELECT 
        team_id, 
        name, 
        other_attribute AS location_type, 
        url AS address, 
        created_at, 
        updated_at
      FROM facilities
    SQL
    
    # Create the mapping records
    # ...
  end
  
  def down
    # Rollback logic
  end
end
```

### 3. Model Updates

#### 3.1 Update Location Model

Enhance the Location model with GeoJSON support:

```ruby
class Location < ApplicationRecord
  # Use the GeoJSON field from our gem
  has_geojson_field :geometry, validate_format: true
  
  # Existing code...
  belongs_to :team
  belongs_to :parent, class_name: "Location", optional: true
  has_many :children, class_name: "Location", foreign_key: "parent_id", dependent: :nullify
  has_many :facility_location_mappings, dependent: :destroy
  has_many :facilities, through: :facility_location_mappings
  
  # Methods for hierarchical navigation
  def ancestors
    # ...
  end
  
  def descendants
    # ...
  end
  
  def full_path
    # ...
  end
end
```

#### 3.2 Create Mapping Model

Create a model for the facility_location_mappings table:

```ruby
class FacilityLocationMapping < ApplicationRecord
  belongs_to :facility
  belongs_to :location
  
  validates :facility_id, uniqueness: { scope: :location_id }
  
  # Ensure the facility and location belong to the same team
  validate :validate_same_team
  
  private
  
  def validate_same_team
    if facility&.team_id != location&.team_id
      errors.add(:base, "Facility and Location must belong to the same team")
    end
  end
end
```

#### 3.3 Update Facility Model

Update the Facility model to add the relationship to Location:

```ruby
class Facility < ApplicationRecord
  # Existing code...
  
  has_many :facility_location_mappings, dependent: :destroy
  has_many :locations, through: :facility_location_mappings
  
  # Deprecated facilities that have been migrated to locations
  scope :migrated, -> { where.not(migrated_to_location_id: nil) }
  
  # Facilities that haven't been migrated yet
  scope :not_migrated, -> { where(migrated_to_location_id: nil) }
  
  # Migration methods
  def migrated_location
    # ...
  end
  
  def migrated?
    # ...
  end
  
  def migrate_to_location(location = nil)
    # ...
  end
end
```

### 4. UI Implementation

#### 4.1 Map Input Component

We've created a Stimulus controller for map-based input:

```javascript
// app/javascript/controllers/bullet_train/fields/geojson/map_input_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["map", "input", "coordinates"]
  
  static values = {
    apiKey: String,
    initial: Object,
    center: { type: Array, default: [-122.4194, 37.7749] },
    zoom: { type: Number, default: 12 }
  }
  
  // Methods for map interaction
  // ...
}
```

#### 4.2 Map Display Component

We've created a Stimulus controller for map-based display:

```javascript
// app/javascript/controllers/bullet_train/fields/geojson/map_display_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["map", "info"]
  
  static values = {
    apiKey: String,
    geojson: Object,
    center: { type: Array, default: [-122.4194, 37.7749] },
    zoom: { type: Number, default: 12 }
  }
  
  // Methods for map display
  // ...
}
```

#### 4.3 View Partials

We've created a view partial for the GeoJSON field:

```erb
<%# app/views/fields/geojson/_field.html.erb %>
<div class="field">
  <% if form %>
    <%# Form context - editable field %>
    <%= form.label method, class: "label" %>
    
    <div data-controller="bullet-train--fields--geojson--map-input"
         data-bullet-train--fields--geojson--map-input-api-key-value="<%= api_key %>"
         data-bullet-train--fields--geojson--map-input-center-value="<%= center.to_json %>"
         data-bullet-train--fields--geojson--map-input-zoom-value="<%= zoom %>">
      
      <div data-bullet-train--fields--geojson--map-input-target="map" 
           style="height: <%= map_height %>; width: 100%; border-radius: 0.375rem; margin-bottom: 0.5rem;"></div>
      
      <%= form.hidden_field method, 
                           data: { "bullet-train--fields--geojson--map-input-target": "input" },
                           class: "input" %>
      
      <div data-bullet-train--fields--geojson--map-input-target="coordinates" 
           class="text-sm text-gray-500 mt-1"></div>
    </div>
  <% else %>
    <%# Show context - display only %>
    <%# ... %>
  <% end %>
</div>
```

### 5. API Controller Updates

Update all Facility-related controllers to use Locations:

1. Rename and update controllers
2. Update routes to support Locations and geospatial queries
3. Add support for GeoJSON in the controllers

### 6. Documentation Updates

Update all relevant documentation files:

1. CHANGELOG.md
2. COMPLETION_REPORT files
3. TEST_FAILURES.md
4. IMPLEMENTATION-STATUS.md
5. INTEGRATION-PLAN.md
6. DIRECTORY-STRUCTURE.md

## Implementation Timeline

### Phase 1: Gem Creation and Database Changes (Week 1)

1. Create the `bullet_train-fields-geojson` gem
2. Create migration for adding GeoJSON support
3. Create migration for transferring data from Facilities to Locations

### Phase 2: Model and UI Updates (Week 2)

1. Update Location model with GeoJSON support
2. Create FacilityLocationMapping model
3. Update Facility model with migration capabilities
4. Create map input and display components

### Phase 3: API and Documentation Updates (Week 3)

1. Update API controllers and routes
2. Update documentation
3. Create tests for the new functionality

### Phase 4: Testing and Deployment (Week 4)

1. Comprehensive testing
2. Finalize the consolidation
3. Deploy to production

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Data loss during migration | Create backups before migration and implement rollback plan |
| Performance issues with geospatial queries | Use proper indexing and optimize queries |
| UI complexity for GeoJSON input | Implement progressive enhancement with simple defaults |
| Breaking changes to API | Version the API and provide migration path |
| Super-scaffolding conflicts | Follow the new golden rule and back up files before using super-scaffolding |

## Contribution to Bullet Train

The `bullet_train-fields-geojson` gem has been designed to be contributed back to the Bullet Train open source project. It follows all Bullet Train conventions and provides a valuable addition to the ecosystem.

Benefits of contributing:

1. Helps other Bullet Train users with geospatial needs
2. Increases the visibility of our team in the Bullet Train community
3. Allows us to benefit from community improvements to the gem
4. Demonstrates our commitment to open source

## Conclusion

This consolidation plan will simplify our data model while enhancing its capabilities with geospatial features. By leveraging the existing hierarchical structure of the Locations model and adding GeoJSON support, we'll provide a more flexible and powerful way for customers to organize their training programs.

The creation of the `bullet_train-fields-geojson` gem ensures that we follow Bullet Train conventions and can contribute our work back to the community.