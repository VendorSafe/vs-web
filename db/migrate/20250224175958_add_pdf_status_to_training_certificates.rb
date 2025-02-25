class AddPdfStatusToTrainingCertificates < ActiveRecord::Migration[7.1]
  def change
    add_column :training_certificates, :pdf_status, :string
    add_column :training_certificates, :pdf_error, :text
    add_column :training_certificates, :verification_code, :string
    add_index :training_certificates, :verification_code, unique: true
  end
end