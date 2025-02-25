require 'test_helper'

class Api::V1::FocusedFacilitiesControllerTest < ActionDispatch::IntegrationTest
  # This test suite focuses specifically on the Facilities API endpoints

  setup do
    # Set up authentication and necessary test data
    @user = create(:onboarded_user)
    @team = @user.current_team
    @membership = create(:membership, user: @user, team: @team)
    @facility = create(:facility, team: @team)

    # Set up authentication token
    @platform_application = create(:platform_application, team: @team)
    @token = Doorkeeper::AccessToken.create!(
      resource_owner_id: @user.id,
      token: SecureRandom.hex,
      application: @platform_application,
      scopes: 'read write delete'
    )
    @headers = { 'Authorization' => "Bearer #{@token.token}" }

    # Set up another user for negative testing
    @another_user = create(:onboarded_user)
    @another_team = @another_user.current_team
    @another_platform_application = create(:platform_application, team: @another_team)
    @another_token = Doorkeeper::AccessToken.create!(
      resource_owner_id: @another_user.id,
      token: SecureRandom.hex,
      application: @another_platform_application,
      scopes: 'read write delete'
    )
    @another_headers = { 'Authorization' => "Bearer #{@another_token.token}" }

    # Create other facilities for testing
    @other_facilities = create_list(:facility, 3)
    @another_facility = create(:facility, team: @team)
  end

  # Test 1: Happy Path - Index
  test 'should get index with proper authentication' do
    get "/api/v1/teams/#{@team.id}/facilities", headers: @headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response

    # Verify our facility is in the response
    facility_ids = json_response.map { |f| f['id'] }
    assert_includes facility_ids, @facility.id

    # Verify other facilities are not in the response
    @other_facilities.each do |other_facility|
      assert_not_includes facility_ids, other_facility.id
    end
  end

  # Test 2: Happy Path - Show
  test 'should get show with proper authentication' do
    get "/api/v1/facilities/#{@facility.id}", headers: @headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @facility.id, json_response['id']
    assert_equal @facility.name, json_response['name']
  end

  # Test 3: Happy Path - Create
  test 'should create facility with proper authentication' do
    facility_data = {
      name: 'New Test Facility',
      other_attribute: 'Test Attribute',
      url: 'https://example.com'
    }

    assert_difference('Facility.count') do
      post "/api/v1/teams/#{@team.id}/facilities",
           params: { facility: facility_data },
           headers: @headers
    end

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 'New Test Facility', json_response['name']
    assert_equal 'Test Attribute', json_response['other_attribute']
    assert_equal 'https://example.com', json_response['url']
  end

  # Test 4: Happy Path - Update
  test 'should update facility with proper authentication' do
    patch "/api/v1/facilities/#{@facility.id}",
          params: { facility: { name: 'Updated Name' } },
          headers: @headers

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 'Updated Name', json_response['name']

    # Verify the database was updated
    @facility.reload
    assert_equal 'Updated Name', @facility.name
  end

  # Test 5: Happy Path - Delete
  test 'should delete facility with proper authentication' do
    assert_difference('Facility.count', -1) do
      delete "/api/v1/facilities/#{@facility.id}", headers: @headers
    end

    assert_response :success
  end

  # Test 6: Edge Case - Empty Collection
  test 'should handle empty collection' do
    # Delete all facilities for this team
    @team.facilities.destroy_all

    get "/api/v1/teams/#{@team.id}/facilities", headers: @headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_empty json_response
  end

  # Test 7: Edge Case - Non-existent Resource
  test 'should return 404 for non-existent resource' do
    get '/api/v1/facilities/9999', headers: @headers
    assert_response :not_found
  end

  # Test 8: Error Condition - Unauthorized
  test 'should return 401 without authentication' do
    get "/api/v1/teams/#{@team.id}/facilities"
    assert_response :unauthorized
  end

  # Test 9: Error Condition - Forbidden
  test 'should return 403 or 404 when user lacks permission' do
    get "/api/v1/facilities/#{@facility.id}", headers: @another_headers
    assert_includes [403, 404], response.status
  end

  # Test 10: Error Condition - Validation Errors
  test 'should return validation errors on invalid create' do
    post "/api/v1/teams/#{@team.id}/facilities",
         params: { facility: { name: '' } },
         headers: @headers

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response.keys, 'errors'
  end
end
