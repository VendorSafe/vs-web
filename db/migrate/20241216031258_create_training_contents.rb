class CreateTrainingContents < ActiveRecord::Migration[7.2]
  def change
    create_table :training_contents do |t|
      t.references :training_program, null: false, foreign_key: true
      t.integer :sort_order
      t.string :title
      t.text :body
      t.string :content_type
      t.datetime :published_at

      t.timestamps
    end
  end
end
