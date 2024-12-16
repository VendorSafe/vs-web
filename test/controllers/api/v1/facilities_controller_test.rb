require "controllers/api/v1/test"

class Api::V1::FacilitiesControllerTest < Api::Test
  setup do
    # See `test/controllers/api/test.rb` for common set up for API tests.

    @facility = build(:facility, team: @team)
    @other_facilities = create_list(:facility, 3)

    @another_facility = create(:facility, team: @team)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @facility.save
    @another_facility.save

    @original_hide_things = ENV["HIDE_THINGS"]
    ENV["HIDE_THINGS"] = "false"
    Rails.application.reload_routes!
  end

  teardown do
    ENV["HIDE_THINGS"] = @original_hide_things
    Rails.application.reload_routes!
  end

  # This assertion is written in such a way that new attributes won't cause the tests to start failing, but removing
  # data we were previously providing to users _will_ break the test suite.
  def assert_proper_object_serialization(facility_data)
    # Fetch the facility in question and prepare to compare it's attributes.
    facility = Facility.find(facility_data["id"])

    assert_equal_or_nil facility_data['name'], facility.name
    assert_equal_or_nil facility_data['other_attribute'], facility.other_attribute
    assert_equal_or_nil facility_data['url'], facility.url
    assert_equal_or_nil facility_data['membership_id'], facility.membership_id
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal facility_data["team_id"], facility.team_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/teams/#{@team.id}/facilities", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    facility_ids_returned = response.parsed_body.map { |facility| facility["id"] }
    assert_includes(facility_ids_returned, @facility.id)

    # But not returning other people's resources.
    assert_not_includes(facility_ids_returned, @other_facilities[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/facilities/#{@facility.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/facilities/#{@facility.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    facility_data = JSON.parse(build(:facility, team: nil).api_attributes.to_json)
    facility_data.except!("id", "team_id", "created_at", "updated_at")
    params[:facility] = facility_data

    post "/api/v1/teams/#{@team.id}/facilities", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/teams/#{@team.id}/facilities",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/facilities/#{@facility.id}", params: {
      access_token: access_token,
      facility: {
        name: 'Alternative String Value',
        other_attribute: 'Alternative String Value',
        url: 'Alternative String Value',
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @facility.reload
    assert_equal @facility.name, 'Alternative String Value'
    assert_equal @facility.other_attribute, 'Alternative String Value'
    assert_equal @facility.url, 'Alternative String Value'
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/facilities/#{@facility.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("Facility.count", -1) do
      delete "/api/v1/facilities/#{@facility.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/facilities/#{@another_facility.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
