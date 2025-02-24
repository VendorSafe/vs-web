class RemoveTrainingInvitations < ActiveRecord::Migration[7.2]
  def change
    drop_table :training_invitations
  end
end
