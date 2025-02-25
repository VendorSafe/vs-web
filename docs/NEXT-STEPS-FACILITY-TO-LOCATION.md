# Next Steps: Facility to Location Consolidation

This document outlines the next steps to complete the Facility to Location consolidation with GeoJSON support. Follow these steps in order to ensure a smooth transition.

## Phase 1: Setup and Installation

### 1. Install the GeoJSON Fields Gem

```bash
bin/install-geojson-fields-gem.sh
```

This script will:
- Add the gem to your Gemfile
- Install the gem via Bundler
- Register the Stimulus controllers
- Add Mapbox API key to your environment
- Create a test location with GeoJSON data

### 2. Run the Database Migrations

```bash
bin/rails db:migrate
```

This will:
- Add the geometry column to the Locations table
- Enable PostGIS extension if not already enabled
- Create the facility_location_mappings table

### 3. Apply the Locations API Implementation

```bash
bin/apply-locations-api.sh
```

This script will:
- Back up existing files
- Apply the new controller and routes
- Run tests
- Roll back changes if tests fail

## Phase 2: Data Migration

### 4. Perform the Data Migration

```bash
bin/consolidate-facilities-to-locations.sh
```

This script will:
- Run the migrations if not already run
- Verify the data migration
- Migrate any remaining facilities
- Output statistics about the migration

### 5. Test the Implementation

```bash
bin/run-focused-locations-api-tests.sh
```

This will run the focused tests for the Locations API to ensure everything is working correctly.

## Phase 3: Frontend Updates

### 6. Update Location Forms

Create or update forms for Locations with GeoJSON support:

1. Create a new form partial for Locations:
   ```erb
   # app/views/account/locations/_form.html.erb
   <%= form_with model: [team, location], url: location.new_record? ? account_team_locations_path(team) : account_location_path(location), local: true do |form| %>
     <div class="field">
       <%= form.label :name, class: "label" %>
       <%= form.text_field :name, class: "input" %>
     </div>
     
     <div class="field">
       <%= form.label :location_type, class: "label" %>
       <%= form.select :location_type, ["office", "warehouse", "store", "facility"], {}, class: "select" %>
     </div>
     
     <div class="field">
       <%= form.label :address, class: "label" %>
       <%= form.text_field :address, class: "input" %>
     </div>
     
     <div class="field">
       <%= form.label :parent_id, class: "label" %>
       <%= form.collection_select :parent_id, location.valid_parents, :id, :name, { include_blank: "None" }, class: "select" %>
     </div>
     
     <%= render 'fields/geojson/field', form: form, method: :geometry %>
     
     <div class="field">
       <%= form.submit class: "button is-primary" %>
     </div>
   <% end %>
   ```

2. Create views for new, edit, and show actions:
   - `app/views/account/locations/new.html.erb`
   - `app/views/account/locations/edit.html.erb`
   - `app/views/account/locations/show.html.erb`

### 7. Add Map Visualization

Create a partial for displaying locations on a map:

```erb
# app/views/account/locations/_map.html.erb
<div class="card">
  <div class="card-header">
    <div class="card-header-title">
      Location Map
    </div>
  </div>
  <div class="card-content">
    <% if locations.any? %>
      <div data-controller="bullet-train--fields--geojson--map-display"
           data-bullet-train--fields--geojson--map-display-api-key-value="<%= ENV['MAPBOX_API_KEY'] %>"
           data-bullet-train--fields--geojson--map-display-geojson-value="<%= {
             type: 'FeatureCollection',
             features: locations.map { |loc| loc.geometry_to_geojson }
           }.to_json %>">
        
        <div data-bullet-train--fields--geojson--map-display-target="map" 
             style="height: 400px; width: 100%; border-radius: 0.375rem;"></div>
        
        <div data-bullet-train--fields--geojson--map-display-target="info" 
             class="text-sm mt-2"></div>
      </div>
    <% else %>
      <p class="help text-gray-500">No locations available</p>
    <% end %>
  </div>
</div>
```

### 8. Update Navigation and Routes

Update the navigation to include Locations:

```erb
# app/views/layouts/_account_navbar.html.erb
<div class="navbar-item has-dropdown is-hoverable">
  <a class="navbar-link">
    Locations
  </a>
  <div class="navbar-dropdown">
    <%= link_to "All Locations", account_team_locations_path(current_team), class: "navbar-item" %>
    <%= link_to "New Location", new_account_team_location_path(current_team), class: "navbar-item" %>
  </div>
</div>
```

Add routes for the account namespace:

```ruby
# config/routes.rb
namespace :account do
  resources :teams do
    resources :locations
  end
  
  resources :locations, only: [:show, :edit, :update, :destroy] do
    member do
      get :children
    end
  end
end
```

## Phase 4: API Updates

### 9. Deprecate Facilities API

Create a wrapper for the Facilities API that redirects to the Locations API:

```ruby
# app/controllers/api/v1/facilities_controller.rb
module Api
  module V1
    class FacilitiesController < Api::V1::ApplicationController
      before_action :deprecation_warning
      
      # GET /api/v1/teams/:team_id/facilities
      def index
        @team = Team.find(params[:team_id])
        @locations = @team.locations
        
        render json: @locations
      end
      
      # Other actions...
      
      private
      
      def deprecation_warning
        response.headers["X-API-Deprecation"] = "The Facilities API is deprecated. Please use the Locations API instead."
      end
    end
  end
end
```

### 10. Update API Documentation

Update the API documentation to include deprecation notices for the Facilities API:

```markdown
# Facilities API (DEPRECATED)

> **DEPRECATED**: The Facilities API is deprecated and will be removed in a future version. Please use the [Locations API](API-LOCATIONS.md) instead.

...
```

## Phase 5: Testing and Validation

### 11. Create System Tests

Create system tests for the Locations UI:

```ruby
# test/system/locations_test.rb
require "application_system_test_case"

class LocationsTest < ApplicationSystemTestCase
  setup do
    @user = create(:onboarded_user)
    @team = @user.current_team
    @location = create(:location, team: @team)
    
    login_as @user
  end
  
  test "visiting the index" do
    visit account_team_locations_path(@team)
    assert_selector "h1", text: "Locations"
  end
  
  test "creating a location" do
    visit account_team_locations_path(@team)
    click_on "New Location"
    
    fill_in "Name", with: "Test Location"
    select "office", from: "Location type"
    fill_in "Address", with: "123 Test St"
    
    # Note: Testing the map input would require JavaScript testing
    
    click_on "Create Location"
    
    assert_text "Location was successfully created"
  end
  
  # Other tests...
end
```

### 12. Run Full Test Suite

```bash
bin/rails test
```

This will run all tests to ensure everything is working correctly.

## Phase 6: Documentation and Training

### 13. Update User Documentation

Create user documentation for the new Location features:

```markdown
# Using Locations with GeoJSON

This guide explains how to use the new Location features with GeoJSON support.

## What is GeoJSON?

GeoJSON is a format for encoding geographic data structures. It allows you to represent points, lines, and polygons on a map.

## Creating a Location

1. Navigate to Locations > New Location
2. Fill in the basic information (name, type, address)
3. Use the map to draw the location's geometry:
   - Click the point tool to create a point
   - Click the line tool to create a line
   - Click the polygon tool to create a polygon
4. Click "Create Location"

## Viewing Locations on a Map

1. Navigate to Locations > All Locations
2. The map will display all locations
3. Click on a location to view its details

## Hierarchical Locations

Locations can have a parent-child relationship. For example:

- Headquarters (parent)
  - Floor 1 (child)
    - Room 101 (grandchild)
    - Room 102 (grandchild)
  - Floor 2 (child)
    - Room 201 (grandchild)
    - Room 202 (grandchild)

To create a child location:

1. Navigate to Locations > New Location
2. Fill in the basic information
3. Select a parent location from the dropdown
4. Click "Create Location"
```

### 14. Developer Documentation

Create developer documentation for the GeoJSON fields gem:

```markdown
# Using the GeoJSON Fields Gem

This guide explains how to use the GeoJSON fields gem in your own models.

## Adding GeoJSON Support to a Model

1. Add a JSONB column to your model:

```ruby
class AddGeometryToYourModel < ActiveRecord::Migration[7.2]
  def change
    add_column :your_models, :geometry, :jsonb, default: {}, null: true
    add_index :your_models, :geometry, using: :gin
  end
end
```

2. Add the `has_geojson_field` method to your model:

```ruby
class YourModel < ApplicationRecord
  has_geojson_field :geometry, validate_format: true
end
```

3. Use the field in your views:

```erb
<%= render 'fields/geojson/field', form: form, method: :geometry %>
```

## Available Methods

The `has_geojson_field` method adds the following methods to your model:

- `geometry_point?` - Returns true if the geometry is a Point
- `geometry_polygon?` - Returns true if the geometry is a Polygon
- `geometry_to_geojson` - Returns a GeoJSON Feature representation of the geometry

## Available Scopes

The `has_geojson_field` method adds the following scopes to your model:

- `near_geometry(lat, lng, radius_km)` - Finds records within a radius of a point
- `with_geometry_type(type)` - Finds records by geometry type
```

## Phase 7: Contribution and Open Source

### 15. Prepare GeoJSON Fields Gem for Contribution

1. Clean up the code and ensure it follows Bullet Train conventions
2. Add comprehensive tests
3. Update documentation
4. Create a pull request to the Bullet Train project

### 16. Monitor and Support

1. Monitor the new API for any issues
2. Provide support for teams transitioning from Facilities to Locations
3. Gather feedback for future improvements

## Timeline

- Phase 1 (Setup and Installation): Week 1
- Phase 2 (Data Migration): Week 1
- Phase 3 (Frontend Updates): Week 2
- Phase 4 (API Updates): Week 2
- Phase 5 (Testing and Validation): Week 3
- Phase 6 (Documentation and Training): Week 3
- Phase 7 (Contribution and Open Source): Week 4

## Conclusion

Following these steps will ensure a smooth transition from Facilities to Locations with GeoJSON support. The new system will provide more flexibility and powerful geospatial capabilities while following Bullet Train conventions and best practices.