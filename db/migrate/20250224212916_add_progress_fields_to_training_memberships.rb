class AddProgressFieldsToTrainingMemberships < ActiveRecord::Migration[7.2]
  def change
    add_column :training_memberships, :completed_at, :datetime
    add_column :training_memberships, :completion_percentage, :integer, default: 0, null: false

    add_index :training_memberships, :completed_at
    add_index :training_memberships, :completion_percentage
  end
end
