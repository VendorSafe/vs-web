class CreateActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :activities do |t|
      t.belongs_to :trackable, polymorphic: true
      t.belongs_to :owner, polymorphic: true
      t.string :key
      t.jsonb :parameters, null: false, default: {}
      t.belongs_to :recipient, polymorphic: true

      t.timestamps
    end

    add_index :activities, [:trackable_id, :trackable_type]
    add_index :activities, [:owner_id, :owner_type]
    add_index :activities, [:recipient_id, :recipient_type]
  end
end
