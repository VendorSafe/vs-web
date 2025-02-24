class AddProgressToTrainingMemberships < ActiveRecord::Migration[7.2]
  def change
    add_column :training_memberships, :progress, :jsonb, default: {}
  end
end
