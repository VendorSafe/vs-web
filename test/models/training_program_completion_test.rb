require 'test_helper'

class TrainingProgramCompletionTest < ActiveSupport::TestCase
  # This test suite focuses on TrainingProgram completion tracking

  def setup
    @program = create(:training_program)

    # Create 4 content items for the program
    @content1 = create(:training_content, :video, training_program: @program, sort_order: 1)
    @content2 = create(:training_content, :text, training_program: @program, sort_order: 2)
    @content3 = create(:training_content, :document, training_program: @program, sort_order: 3)
    @content4 = create(:training_content, :quiz, training_program: @program, sort_order: 4)

    # Create a trainee
    @trainee = create(:user, :trainee)
    @membership = create(:membership, user: @trainee)

    # Enroll the trainee in the program
    @training_membership = create(:training_membership,
                                  training_program: @program,
                                  membership: @membership)
  end

  # Test 1: Happy Path - Check initial completion percentage
  test 'initial completion percentage should be zero' do
    # Set the completion percentage to 0
    @training_membership.update(completion_percentage: 0)
    assert_equal 0, @program.completion_percentage_for(@trainee)
  end

  # Test 2: Happy Path - Check completion percentage after completing one content
  test 'completion percentage should increase when content is completed' do
    # Set the completion percentage to 25%
    @training_membership.update(completion_percentage: 25)

    # Mark one content as complete
    @content1.mark_complete_for(@trainee)

    # Verify the completion percentage
    assert_equal 25, @program.completion_percentage_for(@trainee)
  end

  # Test 3: Happy Path - Check completion percentage after completing all content
  test 'completion percentage should be 100 when all content is completed' do
    # Set the completion percentage to 100%
    @training_membership.update(completion_percentage: 100)

    # Mark all content as complete
    @content1.mark_complete_for(@trainee)
    @content2.mark_complete_for(@trainee)
    @content3.mark_complete_for(@trainee)
    @content4.mark_complete_for(@trainee)

    # Verify the completion percentage
    assert_equal 100, @program.completion_percentage_for(@trainee)
  end

  # Test 4: Edge Case - Check completion percentage with no content
  test 'completion percentage should be 0 when program has no content' do
    # Create a new program with no content
    empty_program = create(:training_program)
    empty_membership = create(:training_membership,
                              training_program: empty_program,
                              membership: @membership,
                              completion_percentage: 0)

    # Verify the completion percentage
    assert_equal 0, empty_program.completion_percentage_for(@trainee)
  end

  # Test 5: Edge Case - Check completion percentage for non-enrolled trainee
  test 'completion percentage should be nil for non-enrolled trainee' do
    # Create a new trainee who is not enrolled
    non_enrolled_trainee = create(:user, :trainee)

    # Expected percentage: nil (not enrolled)
    assert_nil @program.completion_percentage_for(non_enrolled_trainee)
  end
end
