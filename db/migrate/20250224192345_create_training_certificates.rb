class CreateTrainingCertificates < ActiveRecord::Migration[7.1]
  def change
    create_table :training_certificates do |t|
      t.references :membership, null: false, foreign_key: true
      t.references :training_program, null: false, foreign_key: true
      t.datetime :issued_at, null: false
      t.string :certificate_number, null: false
      t.integer :score
      t.timestamps
    end

    add_index :training_certificates, :certificate_number, unique: true
    add_index :training_certificates, [:membership_id, :training_program_id],
              unique: true,
              name: 'idx_training_certificates_unique_membership_program'
  end
end