class AddOptionsToTrainingQuestions < ActiveRecord::Migration[7.2]
  def change
    add_column :training_questions, :options, :json, default: {}
  end
end