# Completion Report: 10-Step Testing Process for API Locations Controller with GeoJSON Support

**Date: February 25, 2025**
**Time: 3:31 PM PST**

## Summary

This report outlines a systematic 10-step process for implementing the API Locations controller with GeoJSON support in the VendorSafe training platform. Following the golden rules established in our documentation, this approach will help us methodically implement this new functionality.

## 10-Step Process for API Locations Controller Implementation

### 1. Identify the Scope

The scope of this task is to implement a fully-featured API controller for the Locations model with GeoJSON support, specifically focusing on:

- CRUD operations for Locations
- Hierarchical location structure (parent-child relationships)
- GeoJSON data storage and retrieval
- Geospatial queries (e.g., finding locations within a radius)

**Action Items:**
- Define the API endpoints for Locations
- Determine the required parameters for each endpoint
- Identify the response format for GeoJSON data
- Plan for geospatial query capabilities

### 2. Create a Focused Test File

For the Locations API controller, we'll create a focused test file that tests all the required functionality:

```ruby
# test/controllers/api/v1/focused_locations_controller_test.rb
require "test_helper"

class Api::V1::FocusedLocationsControllerTest < ActionDispatch::IntegrationTest
  # This test suite focuses specifically on the Locations API endpoints with GeoJSON support
  
  setup do
    # Set up authentication and necessary test data
    @user = create(:onboarded_user)
    @team = @user.current_team
    @membership = create(:membership, user: @user, team: @team)
    
    # Create test locations with GeoJSON data
    @location = create(:location, team: @team, geometry: {
      type: "Point",
      coordinates: [-122.4194, 37.7749]
    })
    
    @child_location = create(:location, team: @team, parent: @location, geometry: {
      type: "Polygon",
      coordinates: [[
        [-122.42, 37.78],
        [-122.41, 37.78],
        [-122.41, 37.77],
        [-122.42, 37.77],
        [-122.42, 37.78]
      ]]
    })
    
    # Set up authentication token
    @token = create(:api_token, user: @user)
    @headers = { "Authorization" => "Bearer #{@token.token}" }
  end
  
  # Tests will be added here
end
```

**Action Items:**
- Create focused test file for the Locations API controller
- Set up proper authentication and test data with GeoJSON
- Prepare test data for hierarchical relationships

### 3. Isolate Dependencies

To focus on the API controllers themselves, we'll mock or stub external dependencies:

```ruby
# Example of isolating dependencies
def setup
  # Mock the authentication service
  ApiAuthenticationService.stubs(:authenticate).returns(@user)
  
  # Mock the serializer
  LocationSerializer.stubs(:new).returns(mock_serializer)
  
  # Mock geospatial calculations for testing
  Location.any_instance.stubs(:distance_to).returns(1.5) # km
end

def mock_serializer
  serializer = mock
  serializer.stubs(:as_json).returns({
    id: 1,
    name: "Test Location",
    geometry: {
      type: "Point",
      coordinates: [-122.4194, 37.7749]
    }
  })
  serializer
end
```

**Action Items:**
- Identify external dependencies for the controller
- Create appropriate mocks or stubs
- Ensure test isolation

### 4. Test Happy Path First

For the Locations API controller, we'll first verify that the basic functionality works under normal conditions:

```ruby
# Example of testing the happy path
test "should get index with proper authentication" do
  get api_v1_team_locations_url(@team), headers: @headers
  assert_response :success
  
  json_response = JSON.parse(response.body)
  assert_not_nil json_response
  assert_includes json_response.map { |loc| loc["id"] }, @location.id
end

test "should get show with proper authentication" do
  get api_v1_location_url(@location), headers: @headers
  assert_response :success
  
  json_response = JSON.parse(response.body)
  assert_equal @location.id, json_response["id"]
  assert_equal "Point", json_response["geometry"]["type"]
  assert_equal [-122.4194, 37.7749], json_response["geometry"]["coordinates"]
end

test "should create location with GeoJSON data" do
  location_data = {
    name: "New Location",
    location_type: "office",
    address: "123 Main St",
    parent_id: nil,
    geometry: {
      type: "Point",
      coordinates: [-122.4194, 37.7749]
    }
  }
  
  assert_difference("Location.count") do
    post api_v1_team_locations_url(@team), 
         params: { location: location_data }, 
         headers: @headers
  end
  
  assert_response :success
  
  json_response = JSON.parse(response.body)
  assert_equal "New Location", json_response["name"]
  assert_equal "Point", json_response["geometry"]["type"]
end
```

**Action Items:**
- Write tests for basic CRUD operations
- Ensure GeoJSON data is properly serialized
- Verify proper response codes and formats

### 5. Test Edge Cases

After verifying the happy path, we'll test boundary conditions and edge cases:

```ruby
# Example of testing edge cases
test "should handle empty collection" do
  # Delete all locations for this team
  @team.locations.destroy_all
  
  get api_v1_team_locations_url(@team), headers: @headers
  assert_response :success
  
  json_response = JSON.parse(response.body)
  assert_empty json_response
end

test "should handle invalid GeoJSON data" do
  location_data = {
    name: "Invalid GeoJSON",
    location_type: "office",
    geometry: {
      type: "Invalid",
      coordinates: "not an array"
    }
  }
  
  post api_v1_team_locations_url(@team), 
       params: { location: location_data }, 
       headers: @headers
  
  assert_response :unprocessable_entity
  
  json_response = JSON.parse(response.body)
  assert_includes json_response["errors"].keys, "geometry"
end

test "should prevent circular parent references" do
  # Try to set a child as its own parent's parent
  patch api_v1_location_url(@location), 
        params: { location: { parent_id: @child_location.id } }, 
        headers: @headers
  
  assert_response :unprocessable_entity
  
  json_response = JSON.parse(response.body)
  assert_includes json_response["errors"].keys, "parent_id"
end
```

**Action Items:**
- Identify edge cases for each API endpoint
- Test invalid GeoJSON data
- Test hierarchical relationship constraints
- Test pagination and filtering

### 6. Test Geospatial Queries

Next, we'll test the geospatial query capabilities:

```ruby
# Example of testing geospatial queries
test "should find locations near a point" do
  get "/api/v1/teams/#{@team.id}/locations/near", 
      params: { lat: 37.7749, lng: -122.4194, radius: 10 }, 
      headers: @headers
  
  assert_response :success
  
  json_response = JSON.parse(response.body)
  assert_not_empty json_response
  assert_includes json_response.map { |loc| loc["id"] }, @location.id
end

test "should find locations by geometry type" do
  get "/api/v1/teams/#{@team.id}/locations", 
      params: { geometry_type: "Polygon" }, 
      headers: @headers
  
  assert_response :success
  
  json_response = JSON.parse(response.body)
  assert_not_empty json_response
  assert_includes json_response.map { |loc| loc["id"] }, @child_location.id
  assert_not_includes json_response.map { |loc| loc["id"] }, @location.id
end
```

**Action Items:**
- Implement tests for geospatial queries
- Test filtering by geometry type
- Test radius-based searches

### 7. Implement the Controller

Now we'll implement the controller with all the required functionality:

```ruby
# app/controllers/api/v1/locations_controller.rb
class Api::V1::LocationsController < Api::V1::ApplicationController
  account_load_and_authorize_resource :location, through: :team, through_association: :locations

  # GET /api/v1/teams/:team_id/locations
  def index
    # Filter by geometry type if specified
    if params[:geometry_type].present?
      @locations = @locations.with_geometry_type(params[:geometry_type])
    end
    
    render json: @locations
  end
  
  # GET /api/v1/teams/:team_id/locations/near
  def near
    # Find locations near a point
    @locations = @team.locations.near_geometry(
      params[:lat].to_f,
      params[:lng].to_f,
      params[:radius].to_f
    )
    
    render json: @locations
  end
  
  # GET /api/v1/locations/:id
  def show
    render json: @location
  end
  
  # POST /api/v1/teams/:team_id/locations
  def create
    @location = @team.locations.build(location_params)
    
    if @location.save
      render json: @location, status: :created
    else
      render json: { errors: @location.errors }, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT /api/v1/locations/:id
  def update
    if @location.update(location_params)
      render json: @location
    else
      render json: { errors: @location.errors }, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/v1/locations/:id
  def destroy
    @location.destroy
    head :ok
  end
  
  # GET /api/v1/locations/:id/children
  def children
    @children = @location.children
    render json: @children
  end
  
  private
  
  def location_params
    params.require(:location).permit(
      :name,
      :location_type,
      :address,
      :parent_id,
      geometry: {}
    )
  end
end
```

**Action Items:**
- Implement the controller with all required actions
- Add support for geospatial queries
- Ensure proper error handling
- Implement hierarchical relationship endpoints

### 8. Update Routes

We'll update the routes to support all the required endpoints:

```ruby
# config/routes/api/v1.rb
namespace :v1 do
  resources :teams do
    resources :locations do
      collection do
        get :near
      end
    end
  end
  
  resources :locations, only: [:show, :update, :destroy] do
    member do
      get :children
    end
  end
end
```

**Action Items:**
- Update routes to support all required endpoints
- Add routes for geospatial queries
- Add routes for hierarchical relationships

### 9. Implement Serialization

We'll implement proper serialization for the Location model with GeoJSON support:

```ruby
# app/serializers/location_serializer.rb
class LocationSerializer < ApplicationSerializer
  attributes :id, :name, :location_type, :address, :geometry, :parent_id, :team_id
  
  attribute :full_path do |location|
    location.full_path
  end
  
  attribute :has_children do |location|
    location.children.exists?
  end
  
  attribute :children_count do |location|
    location.children.count
  end
end
```

**Action Items:**
- Implement serialization for the Location model
- Include GeoJSON data in the serialization
- Add hierarchical relationship information

### 10. Test and Document

Finally, we'll run the tests and document the API endpoints:

```ruby
# Run the tests
bin/rails test test/controllers/api/v1/focused_locations_controller_test.rb
```

**API Documentation:**

```markdown
# Locations API

## Endpoints

### GET /api/v1/teams/:team_id/locations
Get all locations for a team.

### GET /api/v1/teams/:team_id/locations/near?lat=37.7749&lng=-122.4194&radius=10
Get locations within a radius (in km) of a point.

### GET /api/v1/locations/:id
Get a specific location.

### POST /api/v1/teams/:team_id/locations
Create a new location.

### PATCH/PUT /api/v1/locations/:id
Update a location.

### DELETE /api/v1/locations/:id
Delete a location.

### GET /api/v1/locations/:id/children
Get all child locations of a location.
```

**Action Items:**
- Run all tests to ensure everything works
- Document the API endpoints
- Create examples for API usage

## Implementation Plan

1. Create the focused test file
2. Implement the controller
3. Update the routes
4. Implement serialization
5. Run the tests
6. Document the API endpoints

## Expected Outcomes

- A fully-featured API controller for Locations with GeoJSON support
- Support for hierarchical location structure
- Support for geospatial queries
- Comprehensive test coverage
- Clear API documentation