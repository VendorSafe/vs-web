class AddSequentialProgressionToTrainingMemberships < ActiveRecord::Migration[7.2]
  def change
    add_column :training_memberships, :current_content_id, :bigint
    add_column :training_memberships, :last_completed_content_id, :bigint
    add_column :training_memberships, :content_access_history, :jsonb, default: {}, null: false
    add_column :training_memberships, :content_dependencies_met, :jsonb, default: {}, null: false

    add_index :training_memberships, :current_content_id
    add_index :training_memberships, :last_completed_content_id
    add_index :training_memberships, :content_access_history, using: :gin
    add_index :training_memberships, :content_dependencies_met, using: :gin

    add_foreign_key :training_memberships, :training_contents, column: :current_content_id
    add_foreign_key :training_memberships, :training_contents, column: :last_completed_content_id
  end
end
