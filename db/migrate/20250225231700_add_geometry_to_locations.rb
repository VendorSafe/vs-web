class AddGeometryToLocations < ActiveRecord::Migration[7.2]
  def up
    # Enable PostGIS extension if not already enabled
    enable_extension "postgis" unless extension_enabled?("postgis")
    
    # Add geometry column as JSONB for storing GeoJSON
    add_column :locations, :geometry, :jsonb, default: {}, null: true
    
    # Add index for faster querying
    add_index :locations, :geometry, using: :gin
    
    # Add comment to explain the purpose of the column
    execute "COMMENT ON COLUMN locations.geometry IS 'GeoJSON representation of the location boundaries'"
  end
  
  def down
    # Remove index
    remove_index :locations, :geometry
    
    # Remove column
    remove_column :locations, :geometry
    
    # Note: We don't disable the PostGIS extension as it might be used by other tables
  end
end