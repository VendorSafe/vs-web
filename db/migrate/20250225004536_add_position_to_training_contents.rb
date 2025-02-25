class AddPositionToTrainingContents < ActiveRecord::Migration[7.2]
  def change
    add_column :training_contents, :position, :integer, default: 0, null: false
    add_index :training_contents, [:training_program_id, :position]
  end
end
