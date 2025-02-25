require 'application_system_test_case'

class TrainingProgramStateTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def setup
    # Create minimal test data
    @team = create(:team)
    @user = create(:user)
    @membership = create(:membership, user: @user, team: @team)
    sign_in @user
  end

  # Test each state transition individually in separate tests
  # This approach is more reliable and easier to debug

  test 'draft to published transition works' do
    # Create a program in draft state (default)
    program = create(:training_program, team: @team, name: 'Draft Program Test')

    # Verify initial state
    assert_equal 'draft', program.state

    # Test transition
    program.publish!
    assert_equal 'published', program.state
  end

  test 'published to archived transition works' do
    # Create a program and set it to published state using update_column
    program = create(:training_program, team: @team, name: 'Published Program Test')
    program.update_column(:state, 'published')
    program.reload

    # Verify initial state
    assert_equal 'published', program.state

    # Test transition
    program.archive!
    assert_equal 'archived', program.state
  end

  test 'archived to published transition works' do
    # Create a program and set it to archived state using update_column
    program = create(:training_program, team: @team, name: 'Archived Program Test')
    program.update_column(:state, 'archived')
    program.reload

    # Verify initial state
    assert_equal 'archived', program.state

    # Test transition
    program.restore!
    assert_equal 'published', program.state
  end

  test 'published to draft transition works' do
    # Create a program and set it to published state using update_column
    program = create(:training_program, team: @team, name: 'Published Program Test 2')
    program.update_column(:state, 'published')
    program.reload

    # Verify initial state
    assert_equal 'published', program.state

    # Test transition
    program.unpublish!
    assert_equal 'draft', program.state
  end

  test 'invalid transitions are prevented' do
    # Create programs in different states
    draft_program = create(:training_program,
                           team: @team,
                           name: 'Draft Program Invalid Test')
    # Default state is draft, so no need to set it

    archived_program = create(:training_program,
                              team: @team,
                              name: 'Archived Program Invalid Test')
    archived_program.update_column(:state, 'archived')
    archived_program.reload

    # Test invalid transitions
    assert_raises(Workflow::NoTransitionAllowed) do
      draft_program.archive!
    end

    assert_raises(Workflow::NoTransitionAllowed) do
      draft_program.unpublish!
    end

    assert_raises(Workflow::NoTransitionAllowed) do
      archived_program.unpublish!
    end
  end
end
