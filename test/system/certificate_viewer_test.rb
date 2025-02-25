require 'application_system_test_case'

class CertificateViewerTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def setup
    # Configure headless mode based on environment variable
    Capybara.javascript_driver = ENV['OPEN_BROWSER'] ? :selenium_chrome : :selenium_chrome_headless

    # Create test data
    @team = create(:team)
    @user = create(:user)
    @membership = create(:membership, user: @user, team: @team)

    # Create a training program with content
    @program = create(:training_program,
                      team: @team,
                      name: 'Certificate Test Program',
                      state: 'published')

    # Create content
    @video_content = create(:training_content,
                            training_program: @program,
                            title: 'Video Module',
                            content_type: 'video',
                            sort_order: 1)

    # Create a certificate
    @certificate = create(:training_certificate,
                          training_program: @program,
                          membership: @membership,
                          issued_at: Time.current,
                          expires_at: 1.year.from_now,
                          score: 95,
                          verification_code: SecureRandom.hex(10),
                          pdf_status: 'completed')

    # Mark all content as completed
    @program.training_contents.each do |content|
      create(:training_progress,
             training_program: @program,
             training_content: content,
             membership: @membership,
             status: 'completed')
    end

    sign_in @user
  end

  test 'certificate viewer displays certificate details' do
    visit account_team_training_program_player_path(@team, @program)

    # Should show completion message
    assert_text 'Training Completed!'

    # Should show certificate section
    assert_selector '.certificate-section'

    # Certificate should show details
    within '.certificate-preview' do
      assert_text 'Certificate of Completion'
      assert_text @user.name
      assert_text @program.name
      assert_text 'Score: 95%'

      # Should show dates
      assert_text 'Issued On'
      assert_text 'Valid Until'

      # Should show verification code
      assert_text 'Verification Code'
      assert_text @certificate.verification_code
    end
  end

  test 'certificate viewer shows different statuses' do
    # Test expired certificate
    @certificate.update!(expires_at: 1.day.ago)

    visit account_team_training_program_player_path(@team, @program)

    within '.certificate-preview' do
      assert_selector '.badge.bg-yellow-100.text-yellow-800'
      assert_text 'Expired'
    end

    # Test revoked certificate
    @certificate.update!(revoked_at: Time.current)

    visit account_team_training_program_player_path(@team, @program)

    within '.certificate-preview' do
      assert_selector '.badge.bg-red-100.text-red-800'
      assert_text 'Revoked'
    end

    # Test valid certificate
    @certificate.update!(revoked_at: nil, expires_at: 1.year.from_now)

    visit account_team_training_program_player_path(@team, @program)

    within '.certificate-preview' do
      assert_selector '.badge.bg-green-100.text-green-800'
      assert_text 'Valid'
    end
  end

  test 'certificate viewer shows different PDF statuses' do
    # Test processing PDF
    @certificate.update!(pdf_status: 'processing')

    visit account_team_training_program_player_path(@team, @program)

    within '.pdf-actions' do
      assert_text 'Generating PDF certificate'
      assert_selector 'button[disabled]', text: 'Download Certificate'
    end

    # Test failed PDF
    @certificate.update!(pdf_status: 'failed', pdf_error: 'PDF generation failed')

    visit account_team_training_program_player_path(@team, @program)

    within '.pdf-actions' do
      assert_text 'Failed to generate PDF'
      assert_selector 'button[disabled]', text: 'Download Certificate'
      assert_selector 'button:not([disabled])', text: 'Regenerate PDF'
    end

    # Test completed PDF
    @certificate.update!(pdf_status: 'completed')

    visit account_team_training_program_player_path(@team, @program)

    within '.pdf-actions' do
      assert_selector 'button:not([disabled])', text: 'Download Certificate'
      assert_selector 'button:not([disabled])', text: 'Regenerate PDF'
    end
  end

  test 'certificate viewer handles PDF actions' do
    # Ensure PDF is completed
    @certificate.update!(pdf_status: 'completed')

    visit account_team_training_program_player_path(@team, @program)

    # Test regenerate PDF
    click_on 'Regenerate PDF'

    # Should show processing state
    assert_text 'Generating PDF certificate'

    # Simulate PDF completion
    @certificate.reload.update!(pdf_status: 'completed')
    visit account_team_training_program_player_path(@team, @program)

    # Should show download button enabled
    within '.pdf-actions' do
      assert_selector 'button:not([disabled])', text: 'Download Certificate'
    end
  end

  test 'certificate verification code is displayed' do
    visit account_team_training_program_player_path(@team, @program)

    # Should show verification code
    within '.certificate-preview' do
      assert_text 'Verification Code'
      assert_text @certificate.verification_code
    end
  end
end
