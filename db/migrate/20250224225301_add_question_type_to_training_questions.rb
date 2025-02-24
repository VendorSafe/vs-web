class AddQuestionTypeToTrainingQuestions < ActiveRecord::Migration[7.2]
  def change
    add_column :training_questions, :question_type, :string, null: false, default: "multiple_choice"
  end
end
