class CreateTrainingPrograms < ActiveRecord::Migration[7.2]
  def change
    create_table :training_programs do |t|
      t.references :team, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.string :status
      t.text :slides
      t.datetime :published_at

      t.timestamps
    end
  end
end
