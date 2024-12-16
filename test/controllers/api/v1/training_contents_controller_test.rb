require "controllers/api/v1/test"

class Api::V1::TrainingContentsControllerTest < Api::Test
  setup do
    # See `test/controllers/api/test.rb` for common set up for API tests.

    @training_program = create(:training_program, team: @team)
    @training_content = build(:training_content, training_program: @training_program)
    @other_training_contents = create_list(:training_content, 3)

    @another_training_content = create(:training_content, training_program: @training_program)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @training_content.save
    @another_training_content.save

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
  def assert_proper_object_serialization(training_content_data)
    # Fetch the training_content in question and prepare to compare it's attributes.
    training_content = TrainingContent.find(training_content_data["id"])

    assert_equal_or_nil training_content_data['title'], training_content.title
    assert_equal_or_nil training_content_data['content_type'], training_content.content_type
    assert_equal_or_nil DateTime.parse(training_content_data['published_at']), training_content.published_at
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal training_content_data["training_program_id"], training_content.training_program_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/training_programs/#{@training_program.id}/training_contents", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    training_content_ids_returned = response.parsed_body.map { |training_content| training_content["id"] }
    assert_includes(training_content_ids_returned, @training_content.id)

    # But not returning other people's resources.
    assert_not_includes(training_content_ids_returned, @other_training_contents[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/training_contents/#{@training_content.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/training_contents/#{@training_content.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    training_content_data = JSON.parse(build(:training_content, training_program: nil).api_attributes.to_json)
    training_content_data.except!("id", "training_program_id", "created_at", "updated_at")
    params[:training_content] = training_content_data

    post "/api/v1/training_programs/#{@training_program.id}/training_contents", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/training_programs/#{@training_program.id}/training_contents",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/training_contents/#{@training_content.id}", params: {
      access_token: access_token,
      training_content: {
        title: 'Alternative String Value',
        content_type: 'Alternative String Value',
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @training_content.reload
    assert_equal @training_content.title, 'Alternative String Value'
    assert_equal @training_content.content_type, 'Alternative String Value'
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/training_contents/#{@training_content.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("TrainingContent.count", -1) do
      delete "/api/v1/training_contents/#{@training_content.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/training_contents/#{@another_training_content.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
