class AddStateToTrainingPrograms < ActiveRecord::Migration[7.2]
  def change
    add_column :training_programs, :workflow_state, :string, default: "draft", null: false
    add_index :training_programs, :workflow_state
  end
end
