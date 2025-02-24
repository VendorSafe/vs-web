class AddContentFieldsToTrainingContents < ActiveRecord::Migration[7.2]
  def change
    # Skip content_type as it already exists
    add_column :training_contents, :content_data, :jsonb, null: false, default: {}
    add_column :training_contents, :completion_criteria, :jsonb, null: false, default: {}
    add_column :training_contents, :dependencies, :integer, array: true, default: []
    add_column :training_contents, :time_limit, :integer
    add_column :training_contents, :is_required, :boolean, null: false, default: true

    # Skip content_type index as the column already exists
    add_index :training_contents, :dependencies, using: :gin
    add_index :training_contents, :is_required
  end
end
