require 'test_helper'

class GenerateCertificatePdfJobTest < ActiveJob::TestCase
  setup do
    @program = create(:training_program, :with_contents, :published)
    @user = create(:user, :trainee)
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
    # Save the original method
    original_new = Prawn::Document.method(:new)

    # Replace with our mock
    Prawn::Document.define_singleton_method(:new) do |*args|
      raise StandardError.new('PDF generation failed')
    end

    begin
      assert_raises StandardError do
        GenerateCertificatePdfJob.perform_now(@certificate)
      end

      @certificate.reload
      assert_equal 'failed', @certificate.pdf_status
      assert_equal 'PDF generation failed', @certificate.pdf_error
      assert_not @certificate.pdf.attached?
    ensure
      Prawn::Document.define_singleton_method(:new, original_new)
    end
  end

  test 'updates status to processing while generating' do
    # Create a mock PDF generation that we can pause
    pdf_generation_started = false
    pdf_thread = nil

    # Save the original method
    original_new = Prawn::Document.method(:new)

    # Replace with our mock
    Prawn::Document.define_singleton_method(:new) do |*args|
      pdf_generation_started = true
      # Wait until the test gives us the signal to continue
      sleep 0.1 until pdf_thread&.status == false
      raise 'Cancelled'
    end

    begin
      # Run the job in a separate thread so we can check the processing status
      pdf_thread = Thread.new { GenerateCertificatePdfJob.perform_now(@certificate) }

      # Wait for PDF generation to start
      sleep 0.1 until pdf_generation_started

      # Check processing status
      assert_equal 'processing', @certificate.reload.pdf_status

      # Allow the PDF thread to complete
      pdf_thread.kill
      pdf_thread.join
    ensure
      Prawn::Document.define_singleton_method(:new, original_new)
    end
  end
end
