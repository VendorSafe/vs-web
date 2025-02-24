require "test_helper"

class TrainingProgramTest < ActiveSupport::TestCase
  # Test that a training program is valid with a name, description, and team
  test "is valid with name, description, and team" do
    training_program = TrainingProgram.new(name: "Test Program", description: "This is a test program", team: Team.first)
    puts training_program.errors.full_messages
    assert training_program.valid?
    assert training_program.valid?
  end

  # Test that a training program is not valid without a name
  test "is not valid without name" do
    training_program = TrainingProgram.new(description: "This is a test program", team: Team.first)
    refute training_program.valid?
  end

  # Test that a training program is not valid without a description
  test "is not valid without description" do
    training_program = TrainingProgram.new(name: "Test Program", team: Team.first)
    refute training_program.valid?
  end

  # Test that a training program is not valid without a team
  test "is not valid without team" do
    training_program = TrainingProgram.new(name: "Test Program", description: "This is a test program")
    refute training_program.valid?
  end
end
