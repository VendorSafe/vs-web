class AddExpiresAtToTrainingCertificates < ActiveRecord::Migration[7.2]
  def change
    add_column :training_certificates, :expires_at, :datetime
    add_index :training_certificates, :expires_at
  end
end