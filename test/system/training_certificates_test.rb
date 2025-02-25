require 'application_system_test_case'

class TrainingCertificatesTest < BaseSystemTestCase
  setup do
    @admin = create(:user, :admin)
    @student = create(:user, :student)
    @program = create(:training_program, :with_contents, :published)
    # Create a membership for the student in the program's team
    @team = @program.team
    @membership = create(:membership, user: @student, team: @team)

    @certificate = create(:training_certificate,
                          membership: @membership,
                          training_program: @program,
                          issued_at: Time.current,
                          expires_at: 1.year.from_now,
                          score: 95,
                          verification_code: SecureRandom.hex(10))
  end

  test 'admin can generate and manage certificates' do
    sign_in_as(@admin)
    visit team_training_program_path(@program.team, @program)

    click_on 'Generate Certificate'
    fill_in 'Student Email', with: @student.email
    fill_in 'Grade', with: '85'
    select 'Passed', from: 'Status'

    # Set custom expiry
    fill_in 'Valid Until', with: 2.years.from_now.strftime('%Y-%m-%d')

    click_on 'Create Certificate'
    wait_for_ajax

    assert_text 'Certificate was successfully generated'

    # Verify certificate details
    within('.certificate-details') do
      assert_text @student.name
      assert_text @program.title
      assert_text '85%'
      assert_text 'Passed'
      assert_text 'Valid until'
    end

    # Test certificate management
    click_on 'Revoke Certificate'
    accept_confirm
    wait_for_ajax

    assert_text 'Certificate has been revoked'
    within('.certificate-status') do
      assert_text 'Revoked'
    end

    # Verify PDF generation was triggered
    within('.pdf-status') do
      assert_text 'PDF Generation: processing'

      # Simulate PDF completion (in real app this would happen in background)
      @certificate.reload.update!(pdf_status: 'completed')
      wait_for_ajax

      assert_button 'Download PDF'
    end

    # Test regeneration of PDF
    click_on 'Regenerate PDF'
    wait_for_ajax

    assert_text 'PDF generation has been triggered'
    within('.pdf-status') do
      assert_text 'Processing...'
    end
  end

  test 'student can view and download their certificates' do
    sign_in_as(@student)
    visit team_training_certificates_path(@student.current_team)
    wait_for_ajax

    within('.certificates-list') do
      assert_text @program.name
      assert_text "Issued: #{@certificate.issued_at.strftime('%B %d, %Y')}"
      assert_text "Expires: #{@certificate.expires_at.strftime('%B %d, %Y')}"
      assert_text 'Score: 95%'
    end

    # View certificate details
    click_on 'View Certificate'
    wait_for_ajax

    within('.certificate-detail') do
      assert_text 'Certificate of Completion'
      assert_text @student.name
      assert_text @program.name
      assert_text 'has successfully completed'
      assert_text 'with a grade of 95%' # Text in the view might still say "grade" even though the field is "score"
    end

    # Verify PDF generation status
    within('.pdf-status') do
      if @certificate.pdf_status == 'completed'
        assert_button 'Download PDF'
      else
        assert_text "PDF Generation: #{@certificate.pdf_status}"
        assert_text 'Processing...' if @certificate.pdf_status == 'processing'
      end
    end

    # Test PDF download if available
    if @certificate.pdf_status == 'completed'
      click_on 'Download PDF'
      wait_for_ajax
      assert_text 'Download started'
    end

    # Verify verification code
    within('.verification') do
      assert_text 'Certificate Verification Code'
      assert_text @certificate.verification_code
      assert_selector 'img.qr-code' # QR code image
    end
  end

  test 'student sees expiry warning for certificates' do
    @certificate.update!(expires_at: 2.weeks.from_now)

    sign_in_as(@student)
    visit team_training_certificates_path(@student.current_team)
    wait_for_ajax

    within('.certificate-warning') do
      assert_text 'Certificate expires soon'
      assert_text '2 weeks remaining'
      assert_link 'Renew Now'
    end
  end

  test 'handles PDF generation errors gracefully' do
    @certificate.update!(pdf_status: 'failed', pdf_error: 'PDF generation failed')

    sign_in_as(@student)
    visit team_training_certificates_path(@team)
    wait_for_ajax

    click_on 'View Certificate'
    wait_for_ajax

    within('.pdf-status') do
      assert_text 'PDF Generation Failed'
      assert_text 'Please contact support'
      assert_button 'Retry Generation'
    end

    # Test retry functionality
    click_on 'Retry Generation'
    wait_for_ajax

    assert_text 'PDF generation has been restarted'
    assert_text 'Processing...'
  end
end
