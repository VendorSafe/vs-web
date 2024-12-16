class CreateTrainingQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :training_questions do |t|
      t.references :training_content, null: false, foreign_key: true
      t.string :title
      t.text :body
      t.text :good_answers
      t.text :bad_answers
      t.datetime :published_at

      t.timestamps
    end
  end
end
