require 'test_helper'

class Api::V1::FocusedTrainingContentsControllerTest < ActionDispatch::IntegrationTest
  # This test suite focuses specifically on the TrainingContents API endpoints

  setup do
    # Set up authentication and necessary test data
    @user = create(:onboarded_user)
    @team = @user.current_team
    @membership = create(:membership, user: @user, team: @team)
    @training_program = create(:training_program, team: @team)
    @training_content = create(:training_content, training_program: @training_program)

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

    # Create other training contents for testing
    @other_training_contents = create_list(:training_content, 3)
    @another_training_content = create(:training_content, training_program: @training_program)
  end

  # Test 1: Happy Path - Index
  test 'should get index with proper authentication' do
    get "/api/v1/training_programs/#{@training_program.id}/training_contents", headers: @headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response

    # Verify our training content is in the response
    training_content_ids = json_response.map { |tc| tc['id'] }
    assert_includes training_content_ids, @training_content.id

    # Verify other training contents are not in the response
    @other_training_contents.each do |other_content|
      assert_not_includes training_content_ids, other_content.id
    end
  end

  # Test 2: Happy Path - Show
  test 'should get show with proper authentication' do
    get "/api/v1/training_contents/#{@training_content.id}", headers: @headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @training_content.id, json_response['id']
    assert_equal @training_content.title, json_response['title']
  end

  # Test 3: Happy Path - Create
  test 'should create training content with proper authentication' do
    training_content_data = {
      title: 'New Test Content',
      content_type: 'video',
      content_data: { url: 'https://example.com/video.mp4' }
    }

    assert_difference('TrainingContent.count') do
      post "/api/v1/training_programs/#{@training_program.id}/training_contents",
           params: { training_content: training_content_data },
           headers: @headers
    end

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 'New Test Content', json_response['title']
    assert_equal 'video', json_response['content_type']
  end

  # Test 4: Happy Path - Update
  test 'should update training content with proper authentication' do
    patch "/api/v1/training_contents/#{@training_content.id}",
          params: { training_content: { title: 'Updated Title' } },
          headers: @headers

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 'Updated Title', json_response['title']

    # Verify the database was updated
    @training_content.reload
    assert_equal 'Updated Title', @training_content.title
  end

  # Test 5: Happy Path - Delete
  test 'should delete training content with proper authentication' do
    assert_difference('TrainingContent.count', -1) do
      delete "/api/v1/training_contents/#{@training_content.id}", headers: @headers
    end

    assert_response :success
  end

  # Test 6: Edge Case - Empty Collection
  test 'should handle empty collection' do
    # Delete all training contents for this program
    @training_program.training_contents.destroy_all

    get "/api/v1/training_programs/#{@training_program.id}/training_contents", headers: @headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_empty json_response
  end

  # Test 7: Edge Case - Non-existent Resource
  test 'should return 404 for non-existent resource' do
    get '/api/v1/training_contents/9999', headers: @headers
    assert_response :not_found
  end

  # Test 8: Error Condition - Unauthorized
  test 'should return 401 without authentication' do
    get "/api/v1/training_programs/#{@training_program.id}/training_contents"
    assert_response :unauthorized
  end

  # Test 9: Error Condition - Forbidden
  test 'should return 403 or 404 when user lacks permission' do
    get "/api/v1/training_contents/#{@training_content.id}", headers: @another_headers
    assert_includes [403, 404], response.status
  end

  # Test 10: Error Condition - Validation Errors
  test 'should return validation errors on invalid create' do
    post "/api/v1/training_programs/#{@training_program.id}/training_contents",
         params: { training_content: { title: '' } },
         headers: @headers

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response.keys, 'errors'
  end
end
