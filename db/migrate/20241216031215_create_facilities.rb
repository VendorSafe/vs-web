class CreateFacilities < ActiveRecord::Migration[7.2]
  def change
    create_table :facilities do |t|
      t.references :team, null: false, foreign_key: true
      t.integer :sort_order
      t.string :name
      t.string :other_attribute
      t.string :url

      t.timestamps
    end
  end
end
