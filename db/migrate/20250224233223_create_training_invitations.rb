class CreateTrainingInvitations < ActiveRecord::Migration[7.2]
  def change
    create_table :training_invitations do |t|
      t.references :training_program, null: false, foreign_key: true
      t.references :invitee, null: false, foreign_key: {to_table: :users}
      t.references :inviter, null: false, foreign_key: {to_table: :users}
      t.string :status, null: false, default: "pending"
      t.datetime :expires_at
      t.datetime :completed_at
      t.jsonb :metadata, null: false, default: {}

      t.timestamps

      t.index :status
      t.index :expires_at
      t.index :completed_at
    end
  end
end
