require 'test_helper'

class Api::V1::FocusedLocationsControllerTest < ActionDispatch::IntegrationTest
  # This test suite focuses specifically on the Locations API endpoints with GeoJSON support

  setup do
    # Set up authentication and necessary test data
    @user = create(:onboarded_user)
    @team = @user.current_team
    @membership = create(:membership, user: @user, team: @team)

    # Create test locations with GeoJSON data
    @location = create(:location, team: @team, geometry: {
                         type: 'Point',
                         coordinates: [-122.4194, 37.7749]
                       })

    @child_location = create(:location, team: @team, parent: @location, geometry: {
                               type: 'Polygon',
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
    @headers = { 'Authorization' => "Bearer #{@token.token}" }
  end

  # Basic CRUD tests

  test 'should get index with proper authentication' do
    get api_v1_team_locations_url(@team), headers: @headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    assert_includes json_response.map { |loc| loc['id'] }, @location.id
  end

  test 'should get show with proper authentication' do
    get api_v1_location_url(@location), headers: @headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @location.id, json_response['id']
    assert_equal 'Point', json_response['geometry']['type']
    assert_equal [-122.4194, 37.7749], json_response['geometry']['coordinates']
  end

  test 'should create location with GeoJSON data' do
    location_data = {
      name: 'New Location',
      location_type: 'office',
      address: '123 Main St',
      parent_id: nil,
      geometry: {
        type: 'Point',
        coordinates: [-122.4194, 37.7749]
      }
    }

    assert_difference('Location.count') do
      post api_v1_team_locations_url(@team),
           params: { location: location_data },
           headers: @headers
    end

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 'New Location', json_response['name']
    assert_equal 'Point', json_response['geometry']['type']
  end

  test 'should update location' do
    patch api_v1_location_url(@location),
          params: { location: { name: 'Updated Location' } },
          headers: @headers

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 'Updated Location', json_response['name']
  end

  test 'should delete location' do
    assert_difference('Location.count', -1) do
      delete api_v1_location_url(@location), headers: @headers
    end

    assert_response :success
  end

  # Edge cases

  test 'should handle empty collection' do
    # Delete all locations for this team
    @team.locations.destroy_all

    get api_v1_team_locations_url(@team), headers: @headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_empty json_response
  end

  test 'should handle invalid GeoJSON data' do
    location_data = {
      name: 'Invalid GeoJSON',
      location_type: 'office',
      geometry: {
        type: 'Invalid',
        coordinates: 'not an array'
      }
    }

    post api_v1_team_locations_url(@team),
         params: { location: location_data },
         headers: @headers

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response['errors'].keys, 'geometry'
  end

  test 'should prevent circular parent references' do
    # Try to set a child as its own parent's parent
    patch api_v1_location_url(@location),
          params: { location: { parent_id: @child_location.id } },
          headers: @headers

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response['errors'].keys, 'parent_id'
  end

  # Hierarchical relationship tests

  test 'should get children of a location' do
    get "/api/v1/locations/#{@location.id}/children", headers: @headers

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_not_empty json_response
    assert_includes json_response.map { |loc| loc['id'] }, @child_location.id
  end

  # Geospatial query tests

  test 'should find locations near a point' do
    get "/api/v1/teams/#{@team.id}/locations/near",
        params: { lat: 37.7749, lng: -122.4194, radius: 10 },
        headers: @headers

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_not_empty json_response
    assert_includes json_response.map { |loc| loc['id'] }, @location.id
  end

  test 'should find locations by geometry type' do
    get "/api/v1/teams/#{@team.id}/locations",
        params: { geometry_type: 'Polygon' },
        headers: @headers

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_not_empty json_response
    assert_includes json_response.map { |loc| loc['id'] }, @child_location.id
    assert_not_includes json_response.map { |loc| loc['id'] }, @location.id
  end

  # Authentication tests

  test 'should not allow access without authentication' do
    get api_v1_team_locations_url(@team)
    assert_response :unauthorized
  end

  test "should not allow access to other team's locations" do
    other_team = create(:team)

    get api_v1_team_locations_url(other_team), headers: @headers
    assert_response :forbidden
  end
end
