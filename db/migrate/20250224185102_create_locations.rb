class CreateLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :locations do |t|
      t.references :team, null: false, foreign_key: true
      t.integer :sort_order
      t.string :name
      t.string :address
      t.string :location_type

      t.timestamps
    end
  end
end
