class ConsolidateFacilitiesToLocations < ActiveRecord::Migration[7.2]
  def up
    # Create a mapping table to track the relationship between facilities and locations
    create_table :facility_location_mappings do |t|
      t.references :facility, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.timestamps
    end
    
    # Copy data from facilities to locations
    execute <<-SQL
      INSERT INTO locations (team_id, name, location_type, address, created_at, updated_at)
      SELECT 
        team_id, 
        name, 
        other_attribute AS location_type, 
        url AS address, 
        created_at, 
        updated_at
      FROM facilities
    SQL
    
    # Create the mapping records
    execute <<-SQL
      INSERT INTO facility_location_mappings (facility_id, location_id, created_at, updated_at)
      SELECT 
        facilities.id AS facility_id, 
        locations.id AS location_id, 
        NOW(), 
        NOW()
      FROM facilities
      JOIN locations ON 
        facilities.team_id = locations.team_id AND 
        facilities.name = locations.name AND 
        facilities.other_attribute = locations.location_type
    SQL
    
    # Add a column to facilities to mark them as migrated
    add_column :facilities, :migrated_to_location_id, :bigint
    add_index :facilities, :migrated_to_location_id
    
    # Update the facilities with their corresponding location IDs
    execute <<-SQL
      UPDATE facilities
      SET migrated_to_location_id = facility_location_mappings.location_id
      FROM facility_location_mappings
      WHERE facilities.id = facility_location_mappings.facility_id
    SQL
    
    # Output migration statistics
    migrated_count = execute("SELECT COUNT(*) FROM facilities WHERE migrated_to_location_id IS NOT NULL").first["count"]
    total_count = execute("SELECT COUNT(*) FROM facilities").first["count"]
    
    puts "Migrated #{migrated_count} out of #{total_count} facilities to locations"
    
    # Note: We don't drop the facilities table yet to allow for a transition period
    # This will be done in a future migration after verifying the data is correctly migrated
  end
  
  def down
    # Remove the migrated_to_location_id column
    remove_index :facilities, :migrated_to_location_id
    remove_column :facilities, :migrated_to_location_id
    
    # Delete locations that were created from facilities
    execute <<-SQL
      DELETE FROM locations
      WHERE id IN (
        SELECT location_id FROM facility_location_mappings
      )
    SQL
    
    # Drop the mapping table
    drop_table :facility_location_mappings
  end
end