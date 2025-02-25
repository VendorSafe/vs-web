require 'test_helper'

class TrainingProgramsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @trainee = create(:user, :trainee)
    @program = create(:training_program)
  end

  test 'should get index' do
    sign_in(@admin)
    get training_programs_url
    assert_response :success
  end

  test 'should create program when admin' do
    sign_in(@admin)
    assert_difference('TrainingProgram.count') do
      post training_programs_url, params: {
        training_program: {
          title: 'New Program',
          description: 'Description'
        }
      }
    end
    assert_redirected_to training_program_url(TrainingProgram.last)
  end

  test 'should not create program when trainee' do
    sign_in(@trainee)
    assert_no_difference('TrainingProgram.count') do
      post training_programs_url, params: {
        training_program: {
          title: 'New Program',
          description: 'Description'
        }
      }
    end
    assert_redirected_to root_url
  end
end
