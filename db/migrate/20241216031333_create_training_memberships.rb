class CreateTrainingMemberships < ActiveRecord::Migration[7.2]
  def change
    create_table :training_memberships do |t|
      t.references :training_program, null: false, foreign_key: true
      t.references :membership, null: false, foreign_key: true

      t.timestamps
    end
  end
end
