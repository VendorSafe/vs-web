require 'test_helper'

class GenerateCertificatePdfJobTest < ActiveJob::TestCase
  setup do
    @program = create(:training_program, :with_contents, :published)
    @user = create(:user, :student)
    @team = create(:team)
    @membership = create(:membership, user: @user, team: @team)
    @certificate = create(:training_certificate,
                          membership: @membership,
                          training_program: @program,
                          issued_at: Time.current,
                          expires_at: 1.year.from_now,
                          score: 95,
                          verification_code: SecureRandom.hex(10))
  end

  test 'generates PDF certificate successfully' do
    assert_changes -> { @certificate.reload.pdf_status }, from: nil, to: 'completed' do
      GenerateCertificatePdfJob.perform_now(@certificate)
    end

    assert @certificate.pdf.attached?
    assert_equal 'application/pdf', @certificate.pdf.content_type
  end

  test 'handles PDF generation failure' do
    Prawn::Document.stub(:new, -> { raise StandardError.new('PDF generation failed') }) do
      assert_raises StandardError do
        GenerateCertificatePdfJob.perform_now(@certificate)
      end

      @certificate.reload
      assert_equal 'failed', @certificate.pdf_status
      assert_equal 'PDF generation failed', @certificate.pdf_error
      assert_not @certificate.pdf.attached?
    end
  end

  test 'updates status to processing while generating' do
    # Create a mock PDF generation that we can pause
    pdf_generation_started = false
    pdf_thread = nil

    Prawn::Document.stub(:new, lambda { |*|
      pdf_generation_started = true
      # Wait until the test gives us the signal to continue
      sleep 0.1 until pdf_thread&.status == false
      raise 'Cancelled'
    }) do
      # Run the job in a separate thread so we can check the processing status
      pdf_thread = Thread.new { GenerateCertificatePdfJob.perform_now(@certificate) }

      # Wait for PDF generation to start
      sleep 0.1 until pdf_generation_started

      # Check processing status
      assert_equal 'processing', @certificate.reload.pdf_status

      # Allow the PDF thread to complete
      pdf_thread.kill
      pdf_thread.join
    end
  end
end
