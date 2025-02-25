require 'application_system_test_case'

class TrainingPlayerTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def setup
    # Configure headless mode based on environment variable
    Capybara.javascript_driver = ENV['OPEN_BROWSER'] ? :selenium_chrome : :selenium_chrome_headless

    # Create test data
    @team = create(:team)
    @user = create(:user)
    @membership = create(:membership, user: @user, team: @team)

    # Create a training program with various content types
    @program = create(:training_program,
                      team: @team,
                      name: 'Test Training Program',
                      state: 'published')

    # Create different types of content
    @video_content = create(:training_content, :video,
                            training_program: @program,
                            title: 'Video Module',
                            sort_order: 1)

    @document_content = create(:training_content, :document,
                               training_program: @program,
                               title: 'Document Module',
                               body: 'Test document content',
                               sort_order: 2)

    @quiz_content = create(:training_content, :quiz,
                           training_program: @program,
                           title: 'Quiz Module',
                           sort_order: 3)

    # Create additional content for filtering tests
    @video_content2 = create(:training_content, :video,
                             training_program: @program,
                             title: 'Advanced Video Module',
                             sort_order: 4)

    @document_content2 = create(:training_content, :document,
                                training_program: @program,
                                title: 'Advanced Document Module',
                                body: 'Advanced document content for testing',
                                sort_order: 5)

    # Create quiz questions
    create(:training_question,
           training_content: @quiz_content,
           title: 'Multiple Choice Question',
           body: 'What is the correct answer?',
           question_type: 'multiple_choice',
           options: [
             { id: 1, text: 'Correct Answer', correct: true },
             { id: 2, text: 'Wrong Answer 1', correct: false },
             { id: 3, text: 'Wrong Answer 2', correct: false }
           ])

    sign_in @user
  end

  test 'viewing training program player' do
    visit account_team_training_program_player_path(@team, @program)

    assert_selector 'h2', text: @program.name
    assert_selector '.module-navigation'
    assert_selector '.progress-bar'
  end

  test 'navigating between modules' do
    visit account_team_training_program_player_path(@team, @program)

    # First module should be active
    assert_selector '.module-button.active', text: 'Video Module'

    # Click second module
    click_on 'Document Module'
    assert_selector '.module-button.active', text: 'Document Module'
    assert_text 'Test document content'
  end

  test 'completing video module' do
    visit account_team_training_program_player_path(@team, @program)

    # Simulate video completion
    page.execute_script("document.querySelector('video').dispatchEvent(new Event('ended'))")

    # Wait for progress update
    assert_selector '.module-button.complete', text: 'Video Module'
  end

  test 'completing quiz module' do
    visit account_team_training_program_player_path(@team, @program)

    # Navigate to quiz
    click_on 'Quiz Module'

    # Answer question correctly
    choose 'Correct Answer'
    click_on 'Submit Answers'

    # Wait for completion
    assert_text 'Congratulations! You passed!'
    assert_selector '.module-button.complete', text: 'Quiz Module'
  end

  test 'generating certificate on completion' do
    # Mark all modules as complete
    @program.training_contents.each do |content|
      create(:training_progress,
             training_program: @program,
             training_content: content,
             membership: @membership,
             status: 'completed')
    end

    visit account_team_training_program_player_path(@team, @program)

    # Wait for certificate generation
    assert_text 'Training Completed!'
    assert_selector 'a', text: 'View Certificate'

    # Verify certificate
    click_on 'View Certificate'
    assert_selector '.certificate-number'
  end

  test 'progress persistence' do
    visit account_team_training_program_player_path(@team, @program)

    # Complete first module
    page.execute_script("document.querySelector('video').dispatchEvent(new Event('ended'))")

    # Reload page
    visit account_team_training_program_player_path(@team, @program)

    # Verify progress persisted
    assert_selector '.module-button.complete', text: 'Video Module'
  end

  test 'responsive design' do
    # Test mobile view
    page.driver.browser.manage.window.resize_to(375, 812) # iPhone X dimensions
    visit account_team_training_program_player_path(@team, @program)

    assert_selector '.training-player'
    assert_selector '.module-navigation'

    # Test desktop view
    page.driver.browser.manage.window.resize_to(1920, 1080)
    visit account_team_training_program_player_path(@team, @program)

    assert_selector '.training-player'
    assert_selector '.module-navigation'
  end

  test 'using content filters' do
    visit account_team_training_program_player_path(@team, @program)

    # Open filters panel
    click_on 'Filters'
    assert_selector '.filters-panel'

    # Filter by content type
    select 'Video', from: 'Content Type'
    click_on 'Apply Filters'

    # Should only show video content
    assert_selector '.module-button', text: 'Video Module'
    assert_selector '.module-button', text: 'Advanced Video Module'
    assert_no_selector '.module-button', text: 'Document Module'
    assert_no_selector '.module-button', text: 'Quiz Module'

    # Reset filters
    click_on 'Filters'
    click_on 'Reset'
    click_on 'Apply Filters'

    # Should show all content again
    assert_selector '.module-button', text: 'Video Module'
    assert_selector '.module-button', text: 'Document Module'
    assert_selector '.module-button', text: 'Quiz Module'
    assert_selector '.module-button', text: 'Advanced Video Module'
    assert_selector '.module-button', text: 'Advanced Document Module'

    # Search for content
    click_on 'Filters'
    fill_in 'Search', with: 'Advanced'
    click_on 'Apply Filters'

    # Should only show content with "Advanced" in the title
    assert_selector '.module-button', text: 'Advanced Video Module'
    assert_selector '.module-button', text: 'Advanced Document Module'
    assert_no_selector '.module-button', text: 'Video Module'
    assert_no_selector '.module-button', text: 'Document Module'
    assert_no_selector '.module-button', text: 'Quiz Module'
  end

  test 'certificate viewer functionality' do
    # Create a certificate for the user
    certificate = create(:training_certificate,
                         training_program: @program,
                         membership: @membership,
                         issued_at: Time.current,
                         expires_at: 1.year.from_now,
                         score: 95,
                         verification_code: SecureRandom.hex(10),
                         pdf_status: 'completed')

    # Mark all modules as complete
    @program.training_contents.each do |content|
      create(:training_progress,
             training_program: @program,
             training_content: content,
             membership: @membership,
             status: 'completed')
    end

    visit account_team_training_program_player_path(@team, @program)

    # Should show completion message and certificate
    assert_text 'Training Completed!'
    assert_selector '.certificate-section'

    # Certificate should show details
    within '.certificate-preview' do
      assert_text 'Certificate of Completion'
      assert_text @user.name
      assert_text @program.name
      assert_text 'Score: 95%'
      assert_text 'Valid Until'
      assert_text certificate.verification_code
    end

    # Should have download button
    assert_selector 'button', text: 'Download Certificate'

    # Should have regenerate button
    assert_selector 'button', text: 'Regenerate PDF'
  end

  test 'network status indicator' do
    visit account_team_training_program_player_path(@team, @program)

    # Should show network status indicator
    assert_selector '.network-status'

    # Should show online status by default
    within '.network-status' do
      assert_text 'Online'
    end

    # Simulate going offline
    page.execute_script("window.dispatchEvent(new Event('offline'))")

    # Should show offline status
    within '.network-status' do
      assert_text 'Offline'
    end

    # Should show offline notice
    assert_selector '.offline-notice'
    within '.offline-notice' do
      assert_text 'You are now working offline'
    end

    # Simulate going back online
    page.execute_script("window.dispatchEvent(new Event('online'))")

    # Should show online status again
    within '.network-status' do
      assert_text 'Online'
    end
  end

  test 'offline progress tracking' do
    # Simulate offline mode
    page.execute_script("window.navigator.onLine = false; window.dispatchEvent(new Event('offline'))")

    visit account_team_training_program_player_path(@team, @program)

    # Should show offline indicator
    within '.network-status' do
      assert_text 'Offline'
    end

    # Complete a module while offline
    page.execute_script("document.querySelector('video').dispatchEvent(new Event('ended'))")

    # Should mark as complete in UI
    assert_selector '.module-button.complete', text: 'Video Module'

    # Simulate going back online
    page.execute_script("window.navigator.onLine = true; window.dispatchEvent(new Event('online'))")

    # Should show syncing indicator
    assert_text 'Syncing changes'

    # Should still show module as complete after sync
    assert_selector '.module-button.complete', text: 'Video Module'
  end
end
