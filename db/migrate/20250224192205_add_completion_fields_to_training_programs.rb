class AddCompletionFieldsToTrainingPrograms < ActiveRecord::Migration[7.2]
  def change
    add_column :training_programs, :completion_deadline, :datetime
    add_column :training_programs, :completion_timeframe, :integer
    add_column :training_programs, :passing_percentage, :integer
    add_column :training_programs, :time_limit, :integer
    add_column :training_programs, :is_published, :boolean
  end
end
