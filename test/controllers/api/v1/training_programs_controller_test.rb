require "controllers/api/v1/test"

class Api::V1::TrainingProgramsControllerTest < Api::Test
  setup do
    # See `test/controllers/api/test.rb` for common set up for API tests.

    @training_program = build(:training_program, team: @team)
    @other_training_programs = create_list(:training_program, 3)

    @another_training_program = create(:training_program, team: @team)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @training_program.save
    @another_training_program.save

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
  def assert_proper_object_serialization(training_program_data)
    # Fetch the training_program in question and prepare to compare it's attributes.
    training_program = TrainingProgram.find(training_program_data["id"])

    assert_equal_or_nil training_program_data['name'], training_program.name
    assert_equal_or_nil training_program_data['status'], training_program.status
    assert_equal_or_nil training_program_data['slides'], training_program.slides
    assert_equal_or_nil DateTime.parse(training_program_data['published_at']), training_program.published_at
    assert_equal_or_nil training_program_data['pricing_model_id'], training_program.pricing_model_id
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal training_program_data["team_id"], training_program.team_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/teams/#{@team.id}/training_programs", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    training_program_ids_returned = response.parsed_body.map { |training_program| training_program["id"] }
    assert_includes(training_program_ids_returned, @training_program.id)

    # But not returning other people's resources.
    assert_not_includes(training_program_ids_returned, @other_training_programs[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/training_programs/#{@training_program.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/training_programs/#{@training_program.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    training_program_data = JSON.parse(build(:training_program, team: nil).api_attributes.to_json)
    training_program_data.except!("id", "team_id", "created_at", "updated_at")
    params[:training_program] = training_program_data

    post "/api/v1/teams/#{@team.id}/training_programs", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/teams/#{@team.id}/training_programs",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/training_programs/#{@training_program.id}", params: {
      access_token: access_token,
      training_program: {
        name: 'Alternative String Value',
        status: 'Alternative String Value',
        slides: 'Alternative String Value',
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @training_program.reload
    assert_equal @training_program.name, 'Alternative String Value'
    assert_equal @training_program.status, 'Alternative String Value'
    assert_equal @training_program.slides, 'Alternative String Value'
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/training_programs/#{@training_program.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("TrainingProgram.count", -1) do
      delete "/api/v1/training_programs/#{@training_program.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/training_programs/#{@another_training_program.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
