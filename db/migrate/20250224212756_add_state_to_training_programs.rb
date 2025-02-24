class AddStateToTrainingPrograms < ActiveRecord::Migration[7.2]
  def change
    add_column :training_programs, :state, :string, default: "draft", null: false
    add_index :training_programs, :state
  end
end
