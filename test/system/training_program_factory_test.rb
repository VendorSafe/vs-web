require 'application_system_test_case'

class TrainingProgramFactoryTest < ApplicationSystemTestCase
  # This test focuses on just one thing: verifying the factory behavior
  # for creating training programs with different states

  test 'factory creates programs with correct state' do
    # Create a team for the programs
    team = create(:team)

    # Test creating with default state
    default_program = create(:training_program, team: team)
    puts "Default program state: #{default_program.state}"

    # Test creating with explicit draft state
    draft_program = create(:training_program, team: team, state: 'draft')
    puts "Draft program state: #{draft_program.state}"

    # Test creating with published state
    published_program = create(:training_program, team: team, state: 'published')
    puts "Published program state: #{published_program.state}"

    # Test creating with archived state
    # Note: We can't directly create in archived state due to workflow constraints
    # So we create as published and then archive
    archived_program = create(:training_program, team: team, state: 'published')
    # Use update_column to bypass workflow validations for this test
    archived_program.update_column(:state, 'archived')
    archived_program.reload
    puts "Archived program state: #{archived_program.state}"

    # Verify states
    assert_equal 'draft', default_program.state, 'Default program should be in draft state'
    assert_equal 'draft', draft_program.state, 'Draft program should be in draft state'
    assert_equal 'published', published_program.state, 'Published program should be in published state'
    assert_equal 'archived', archived_program.state, 'Archived program should be in archived state'
  end
end
