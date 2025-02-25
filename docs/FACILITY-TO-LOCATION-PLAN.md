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

## Technical Implementation Plan

### 1. Database Changes

#### 1.1 Data Migration

Create a migration to transfer data from Facilities to Locations:

```ruby
class ConsolidateFacilitiesToLocations < ActiveRecord::Migration[7.2]
  def up
    # Copy data from facilities to locations
    Facility.find_each do |facility|
      Location.create!(
        team_id: facility.team_id,
        name: facility.name,
        location_type: facility.other_attribute,
        address: facility.url,
        parent_id: nil
      )
    end
    
    # Update any references to facilities
    # This would depend on your specific associations
  end
  
  def down
    # Rollback logic if needed
  end
end
```

#### 1.2 Add GeoJSON Support

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

#### 1.3 Update Model

Enhance the Location model with GeoJSON validation and geospatial methods:

```ruby
class Location < ApplicationRecord
  belongs_to :team
  belongs_to :parent, class_name: 'Location', optional: true
  has_many :children, class_name: 'Location', foreign_key: 'parent_id'
  
  validates :geometry, json: { schema: -> { GeoJSON_SCHEMA } }, allow_blank: true
  
  def self.GeoJSON_SCHEMA
    {
      type: "object",
      required: ["type", "coordinates"],
      properties: {
        type: { type: "string", enum: ["Point", "LineString", "Polygon", "MultiPoint", "MultiLineString", "MultiPolygon"] },
        coordinates: { type: "array" }
      }
    }
  end
  
  # Find locations within a radius of a point
  scope :near, ->(lat, lng, radius_km) {
    # Implementation using PostGIS
  }
  
  # Get GeoJSON representation
  def to_geojson
    return nil if geometry.blank?
    
    {
      type: "Feature",
      geometry: geometry,
      properties: {
        id: id,
        name: name,
        location_type: location_type
      }
    }
  end
end
```

### 2. API Controller Updates

#### 2.1 Rename Controllers

Rename and update all Facility-related controllers to use Locations:

1. Rename `facilities_controller_fixed.rb` to `locations_controller_fixed.rb`
2. Update controller class names and references
3. Add support for GeoJSON in the controllers

Example controller with GeoJSON support:

```ruby
class Api::V1::LocationsController < Api::V1::ApplicationController
  account_load_and_authorize_resource :location, through: :team, through_association: :locations

  # GET /api/v1/teams/:team_id/locations
  def index
    # Support for geospatial filtering
    if params[:lat] && params[:lng] && params[:radius]
      @locations = @locations.near(params[:lat].to_f, params[:lng].to_f, params[:radius].to_f)
    end
    
    render json: @locations
  end
  
  # Other actions...
  
  # GET /api/v1/locations/:id/geojson
  def geojson
    render json: @location.to_geojson
  end
  
  private
  
  def location_params
    params.require(:location).permit(
      :name, 
      :address, 
      :location_type, 
      :parent_id,
      geometry: {}
    )
  end
end
```

#### 2.2 Update Routes

Update routes to support Locations and geospatial queries:

```ruby
# config/routes/api/v1_locations_fixed.rb
namespace :v1 do
  resources :teams do
    resources :locations, concerns: [:sortable] do
      collection do
        get :nearby
      end
      
      member do
        get :geojson
        get :children
      end
    end
  end
  
  resources :locations, only: [:show, :update, :destroy] do
    member do
      get :geojson
      get :children
    end
  end
end
```

#### 2.3 Update Tests

Update all test files to use Locations instead of Facilities and add tests for GeoJSON functionality:

```ruby
test "should return location as geojson" do
  @location.update(geometry: {
    type: "Point",
    coordinates: [-122.4194, 37.7749]
  })
  
  get "/api/v1/locations/#{@location.id}/geojson", headers: @headers
  assert_response :success
  
  json_response = JSON.parse(response.body)
  assert_equal "Feature", json_response["type"]
  assert_equal "Point", json_response["geometry"]["type"]
  assert_equal [-122.4194, 37.7749], json_response["geometry"]["coordinates"]
  assert_equal @location.id, json_response["properties"]["id"]
end
```

### 3. UI Implementation

#### 3.1 Form Components

Create UI components for GeoJSON input:

1. Map-based input component using Mapbox or Leaflet
2. Drawing tools for points, lines, and polygons
3. Simple coordinate input for basic locations
4. Preview of the defined area

Example implementation:

```javascript
// app/javascript/controllers/map_input_controller.js
import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl'
import MapboxDraw from '@mapbox/mapbox-gl-draw'

export default class extends Controller {
  static targets = ["map", "input"]
  
  connect() {
    this.initializeMap()
    this.initializeDrawTools()
    this.loadExistingGeometry()
  }
  
  initializeMap() {
    // Initialize Mapbox map
  }
  
  initializeDrawTools() {
    // Initialize drawing tools
  }
  
  updateGeometry(event) {
    const data = this.draw.getAll()
    if (data.features.length > 0) {
      // Get the first feature's geometry
      const geometry = data.features[0].geometry
      this.inputTarget.value = JSON.stringify(geometry)
    } else {
      this.inputTarget.value = ""
    }
  }
  
  loadExistingGeometry() {
    // Load existing geometry from input
  }
}
```

#### 3.2 Display Components

Create components for displaying location data:

1. Map view of location boundaries
2. Hierarchical tree view of locations
3. Toggle between map and list views

### 4. Documentation Updates

#### 4.1 Update Existing Documentation

Update all relevant documentation files:

1. CHANGELOG.md
2. COMPLETION_REPORT files
3. TEST_FAILURES.md
4. IMPLEMENTATION-STATUS.md
5. INTEGRATION-PLAN.md
6. DIRECTORY-STRUCTURE.md

#### 4.2 Add New Golden Rule

Add a new rule to GOLDEN-RULES.md about super-scaffolding:

```markdown
## Super-Scaffolding Best Practices

### When to Use Super-Scaffolding

**Rule**: Use super-scaffolding at the beginning of model development, before making manual modifications to generated files.

**Why It's Good**:
- Ensures consistency across the application
- Saves development time
- Follows Bullet Train conventions
- Generates tests and UI components automatically

**When to Avoid**:
- After making manual modifications to controllers, views, or tests
- When you need custom behavior that deviates significantly from Bullet Train patterns
- For temporary or experimental features

### Adding Fields After Manual Modifications

**Rule**: You can still use super-scaffolding to add new fields to models even after manual modifications, but with caution.

**Process**:
1. Back up all manually modified files before running super-scaffolding
2. Run the super-scaffolding command to add the new field
3. Compare the newly generated files with your backups
4. Manually merge your custom code with the newly generated code
5. Run tests to ensure everything still works

**Example**:
```bash
# 1. Back up your modified files
cp app/controllers/api/v1/locations_controller.rb app/controllers/api/v1/locations_controller.rb.bak

# 2. Run super-scaffolding to add a new field
bin/super-scaffold field Location map_url:text

# 3. Compare and merge changes
diff app/controllers/api/v1/locations_controller.rb app/controllers/api/v1/locations_controller.rb.bak

# 4. Run tests
bin/rails test test/controllers/api/v1/locations_controller_test.rb
```

### Preserving Custom Code

**Rule**: Use the designated "safe areas" in generated files for custom code.

**Example**:
```ruby
# 🚅 super scaffolding will insert new fields above this line.
# Add your custom code below this line to preserve it during regeneration.
def custom_method
  # Your custom code here
end
```

**Why It's Good**:
- Allows you to use super-scaffolding throughout the development lifecycle
- Preserves custom functionality during regeneration
- Maintains a balance between automation and customization
- Follows Bullet Train conventions
```

## Implementation Timeline

### Phase 1: Database Changes (Week 1)

1. Create migration for adding GeoJSON support
2. Update Location model with GeoJSON validation
3. Create migration for transferring data from Facilities to Locations

### Phase 2: API Updates (Week 2)

1. Rename and update controllers
2. Update routes
3. Update tests
4. Add geospatial query support

### Phase 3: UI Implementation (Week 3)

1. Create map-based input component
2. Create location display components
3. Update forms to include GeoJSON input

### Phase 4: Documentation and Testing (Week 4)

1. Update all documentation
2. Add new golden rule about super-scaffolding
3. Comprehensive testing
4. Finalize the consolidation

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Data loss during migration | Create backups before migration and implement rollback plan |
| Performance issues with geospatial queries | Use proper indexing and optimize queries |
| UI complexity for GeoJSON input | Implement progressive enhancement with simple defaults |
| Breaking changes to API | Version the API and provide migration path |
| Super-scaffolding conflicts | Follow the new golden rule and back up files before using super-scaffolding |

## Conclusion

This consolidation plan will simplify our data model while enhancing its capabilities with geospatial features. By leveraging the existing hierarchical structure of the Locations model and adding GeoJSON support, we'll provide a more flexible and powerful way for customers to organize their training programs.

The addition of the super-scaffolding golden rule will help ensure that we can continue to use Bullet Train's powerful scaffolding features even as we make custom modifications to our codebase.