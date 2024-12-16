require "controllers/api/v1/test"

class Api::V1::TrainingQuestionsControllerTest < Api::Test
  setup do
    # See `test/controllers/api/test.rb` for common set up for API tests.

    @training_program = create(:training_program, team: @team)
    @training_content = create(:training_content, training_program: @training_program)
    @training_question = build(:training_question, training_content: @training_content)
    @other_training_questions = create_list(:training_question, 3)

    @another_training_question = create(:training_question, training_content: @training_content)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @training_question.save
    @another_training_question.save

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
  def assert_proper_object_serialization(training_question_data)
    # Fetch the training_question in question and prepare to compare it's attributes.
    training_question = TrainingQuestion.find(training_question_data["id"])

    assert_equal_or_nil training_question_data['title'], training_question.title
    assert_equal_or_nil training_question_data['good_answers'], training_question.good_answers
    assert_equal_or_nil training_question_data['bad_answers'], training_question.bad_answers
    assert_equal_or_nil DateTime.parse(training_question_data['published_at']), training_question.published_at
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal training_question_data["training_content_id"], training_question.training_content_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/training_contents/#{@training_content.id}/training_questions", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    training_question_ids_returned = response.parsed_body.map { |training_question| training_question["id"] }
    assert_includes(training_question_ids_returned, @training_question.id)

    # But not returning other people's resources.
    assert_not_includes(training_question_ids_returned, @other_training_questions[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/training_questions/#{@training_question.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/training_questions/#{@training_question.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    training_question_data = JSON.parse(build(:training_question, training_content: nil).api_attributes.to_json)
    training_question_data.except!("id", "training_content_id", "created_at", "updated_at")
    params[:training_question] = training_question_data

    post "/api/v1/training_contents/#{@training_content.id}/training_questions", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/training_contents/#{@training_content.id}/training_questions",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/training_questions/#{@training_question.id}", params: {
      access_token: access_token,
      training_question: {
        title: 'Alternative String Value',
        good_answers: 'Alternative String Value',
        bad_answers: 'Alternative String Value',
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @training_question.reload
    assert_equal @training_question.title, 'Alternative String Value'
    assert_equal @training_question.good_answers, 'Alternative String Value'
    assert_equal @training_question.bad_answers, 'Alternative String Value'
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/training_questions/#{@training_question.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("TrainingQuestion.count", -1) do
      delete "/api/v1/training_questions/#{@training_question.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/training_questions/#{@another_training_question.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
