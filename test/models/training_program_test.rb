require "test_helper"

class TrainingProgramTest < ActiveSupport::TestCase
  test "is valid with valid attributes" do
    training_program = build(:training_program)
    assert training_program.valid?
  end

  test "is not valid without name" do
    training_program = build(:training_program, name: nil)
    refute training_program.valid?
    assert_includes training_program.errors.full_messages, "Name can't be blank"
  end

  test "is not valid without description" do
    training_program = build(:training_program)
    training_program.description = nil
    refute training_program.valid?
    assert_includes training_program.errors.full_messages, "Description can't be blank"
  end

  test "is not valid without team" do
    training_program = build(:training_program, team: nil)
    refute training_program.valid?
    assert_includes training_program.errors.full_messages, "Team must exist"
  end
end
