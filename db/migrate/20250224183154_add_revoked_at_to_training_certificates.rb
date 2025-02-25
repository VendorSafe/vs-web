class AddRevokedAtToTrainingCertificates < ActiveRecord::Migration[7.0]
  def change
    add_column :training_certificates, :revoked_at, :datetime
    add_index :training_certificates, :revoked_at
  end
end