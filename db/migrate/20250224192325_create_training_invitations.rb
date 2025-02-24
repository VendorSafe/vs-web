class CreateTrainingInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :training_invitations do |t|
      t.references :training_program, null: false, foreign_key: true
      t.references :invitee, null: false, foreign_key: { to_table: :memberships }
      t.references :inviter, null: false, foreign_key: { to_table: :memberships }
      t.string :status, null: false, default: 'pending'
      t.datetime :expires_at
      t.datetime :completed_at
      t.timestamps
    end

    add_index :training_invitations, [:training_program_id, :invitee_id], unique: true, name: 'idx_training_invitations_unique_program_invitee'
  end
end