require 'test_helper'

class Api::V1::FocusedTrainingProgramsControllerTest < ActionDispatch::IntegrationTest
  # This test suite focuses specifically on the TrainingPrograms API endpoints

  setup do
    # Set up authentication and necessary test data
    @user = create(:onboarded_user)
    @team = @user.current_team
    @membership = create(:membership, user: @user, team: @team)
    @training_program = create(:training_program, team: @team)

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

    # Create other training programs for testing
    @other_training_programs = create_list(:training_program, 3)
    @another_training_program = create(:training_program, team: @team)
  end

  # Test 1: Happy Path - Index
  test 'should get index with proper authentication' do
    get "/api/v1/teams/#{@team.id}/training_programs", headers: @headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response

    # Verify our training program is in the response
    training_program_ids = json_response.map { |tp| tp['id'] }
    assert_includes training_program_ids, @training_program.id

    # Verify other teams' training programs are not in the response
    @other_training_programs.each do |other_program|
      assert_not_includes training_program_ids, other_program.id
    end
  end

  # Test 2: Happy Path - Show
  test 'should get show with proper authentication' do
    get "/api/v1/training_programs/#{@training_program.id}", headers: @headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @training_program.id, json_response['id']
    assert_equal @training_program.name, json_response['name']
  end

  # Test 3: Happy Path - Create
  test 'should create training program with proper authentication' do
    training_program_data = {
      name: 'New Test Program',
      description: 'Test description',
      status: 'draft'
    }

    assert_difference('TrainingProgram.count') do
      post "/api/v1/teams/#{@team.id}/training_programs",
           params: { training_program: training_program_data },
           headers: @headers
    end

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 'New Test Program', json_response['name']
    assert_equal 'Test description', json_response['description']
    assert_equal 'draft', json_response['status']
  end

  # Test 4: Happy Path - Update
  test 'should update training program with proper authentication' do
    patch "/api/v1/training_programs/#{@training_program.id}",
          params: { training_program: { name: 'Updated Name' } },
          headers: @headers

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 'Updated Name', json_response['name']

    # Verify the database was updated
    @training_program.reload
    assert_equal 'Updated Name', @training_program.name
  end

  # Test 5: Happy Path - Delete
  test 'should delete training program with proper authentication' do
    assert_difference('TrainingProgram.count', -1) do
      delete "/api/v1/training_programs/#{@training_program.id}", headers: @headers
    end

    assert_response :success
  end

  # Test 6: Edge Case - Empty Collection
  test 'should handle empty collection' do
    # Delete all training programs for this team
    @team.training_programs.destroy_all

    get "/api/v1/teams/#{@team.id}/training_programs", headers: @headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_empty json_response
  end

  # Test 7: Edge Case - Non-existent Resource
  test 'should return 404 for non-existent resource' do
    get '/api/v1/training_programs/9999', headers: @headers
    assert_response :not_found
  end

  # Test 8: Error Condition - Unauthorized
  test 'should return 401 without authentication' do
    get "/api/v1/teams/#{@team.id}/training_programs"
    assert_response :unauthorized
  end

  # Test 9: Error Condition - Forbidden
  test 'should return 403 or 404 when user lacks permission' do
    get "/api/v1/training_programs/#{@training_program.id}", headers: @another_headers
    assert_includes [403, 404], response.status
  end

  # Test 10: Error Condition - Validation Errors
  test 'should return validation errors on invalid create' do
    post "/api/v1/teams/#{@team.id}/training_programs",
         params: { training_program: { name: '' } },
         headers: @headers

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response.keys, 'errors'
  end

  # Test 11: Progress Tracking
  test 'should update progress for a training program' do
    progress_data = {
      '1' => { 'completed' => true, 'time_spent' => 300 },
      '2' => { 'completed' => false, 'time_spent' => 120 }
    }

    put "/api/v1/training_programs/#{@training_program.id}/update_progress",
        params: { progress: progress_data },
        headers: @headers

    assert_response :success
  end

  # Test 12: Certificate Generation
  test 'should generate certificate for completed training' do
    # First, create a training membership and mark it as complete
    training_membership = create(:training_membership,
                                 membership: @membership,
                                 training_program: @training_program,
                                 progress: { 'all' => { 'completed' => true } },
                                 completion_percentage: 100)

    post "/api/v1/training_programs/#{@training_program.id}/generate_certificate",
         headers: @headers

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_not_nil json_response['id']
    assert_equal @training_program.id, json_response['training_program_id']
  end
end
