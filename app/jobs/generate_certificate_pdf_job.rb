class GenerateCertificatePdfJob < ApplicationJob
  queue_as :default

  def perform(certificate)
    # Set status to processing
    certificate.update!(pdf_status: 'processing')

    begin
      # Generate PDF using Prawn or similar
      pdf = Prawn::Document.new do |doc|
        doc.font_families.update(
          'Open Sans' => {
            normal: Rails.root.join('app/assets/fonts/OpenSans-Regular.ttf'),
            bold: Rails.root.join('app/assets/fonts/OpenSans-Bold.ttf')
          }
        )

        doc.font 'Open Sans'
        if certificate.training_program.logo.attached?
          doc.image certificate.training_program.logo.variant(resize: '200x200'),
                    at: [50, 700]
        end

        doc.move_down 50
        doc.text 'Certificate of Completion', size: 24, align: :center, style: :bold

        doc.move_down 30
        doc.text 'This is to certify that', size: 16, align: :center

        doc.move_down 20
        doc.text "#{certificate.membership.user_first_name} #{certificate.membership.user_last_name}", size: 20,
                                                                                                       align: :center, style: :bold

        doc.move_down 20
        doc.text 'has successfully completed', size: 16, align: :center

        doc.move_down 20
        doc.text certificate.training_program.name, size: 20, align: :center, style: :bold

        doc.move_down 20
        doc.text "with a grade of #{certificate.score}%", size: 16, align: :center if certificate.score.present?

        doc.move_down 30
        doc.text "Issued on: #{certificate.issued_at.strftime('%B %d, %Y')}", size: 14, align: :center
        doc.text "Valid until: #{certificate.expires_at.strftime('%B %d, %Y')}", size: 14, align: :center

        # Add QR code for verification
        qr_code = RQRCode::QRCode.new(verify_training_certificate_url(certificate.verification_code))
        doc.image StringIO.new(qr_code.as_png.to_s), at: [450, 100], width: 100
      end

      # Store the generated PDF
      certificate.pdf.attach(
        io: StringIO.new(pdf.render),
        filename: "certificate_#{certificate.id}.pdf",
        content_type: 'application/pdf'
      )

      # Update status to complete
      certificate.update!(pdf_status: 'completed')
    rescue StandardError => e
      # Log error and update status
      Rails.logger.error "Failed to generate PDF for certificate #{certificate.id}: #{e.message}"
      certificate.update!(pdf_status: 'failed', pdf_error: e.message)
      raise e # Re-raise to trigger job retry
    end
  end

  private

  def verify_training_certificate_url(code)
    # Use the correct route helper based on your routes configuration
    # This assumes you have a route like: get '/certificates/verify/:code', to: 'training_certificates#verify', as: :verify_training_certificate
    Rails.application.routes.url_helpers.verify_training_certificate_url(code,
                                                                         host: Rails.application.config.action_mailer.default_url_options[:host] || 'example.com')
  end
end
