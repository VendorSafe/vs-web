class AddParentIdToLocations < ActiveRecord::Migration[7.2]
  def change
    add_reference :locations, :parent, null: true, foreign_key: {to_table: "locations"}
  end
end
