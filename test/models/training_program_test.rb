require 'test_helper'

class TrainingProgramTest < ActiveSupport::TestCase
  test 'is valid with valid attributes' do
    training_program = build(:training_program)
    assert training_program.valid?
  end

  test 'is not valid without name' do
    training_program = build(:training_program, name: nil)
    assert_not training_program.valid?
    assert_includes training_program.errors.full_messages, "Name can't be blank"
  end

  test 'is not valid without description' do
    training_program = build(:training_program)
    training_program.description = nil
    assert_not training_program.valid?
    assert_includes training_program.errors.full_messages, "Description can't be blank"
  end

  test 'is not valid without team' do
    training_program = build(:training_program, team: nil)
    assert_not training_program.valid?
    assert_includes training_program.errors.full_messages, 'Team must exist'
  end

  test 'should not save program without title' do
    program = build(:training_program, name: nil)
    assert_not program.save, 'Saved program without name'
  end

  test 'should track completion status' do
    program = create(:training_program, :with_contents)
    trainee = create(:user, :trainee)

    program.enroll_trainee(trainee)
    assert_equal 0, program.completion_percentage_for(trainee)

    program.training_contents.first.mark_complete_for(trainee)
    expected = (1.0 / program.training_contents.count * 100).round
    assert_equal expected, program.completion_percentage_for(trainee)
  end
end
