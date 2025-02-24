class AddCertificateFieldsToTrainingPrograms < ActiveRecord::Migration[7.1]
  def change
    add_column :training_programs, :certificate_validity_period, :integer, comment: "Number of days the certificate is valid for"
    add_column :training_programs, :certificate_template, :string, null: true, comment: "Template identifier for certificate generation"
    add_column :training_programs, :custom_certificate_fields, :jsonb, null: false, default: {}, comment: "Custom fields to display on certificates"

    add_index :training_programs, :certificate_template
    add_index :training_programs, :custom_certificate_fields, using: :gin
  end
end
