class CreateTrainingProgress < ActiveRecord::Migration[7.1]
  def change
    create_table :training_progress do |t|
      t.references :membership, null: false, foreign_key: true
      t.references :training_program, null: false, foreign_key: true
      t.references :training_content, null: false, foreign_key: true
      t.string :status, null: false, default: 'not_started'
      t.integer :score
      t.integer :time_spent, default: 0
      t.datetime :last_accessed_at
      t.timestamps
    end

    add_index :training_progress, [:membership_id, :training_program_id, :training_content_id],
              unique: true,
              name: 'idx_training_progress_unique_membership_program_content'
  end
end