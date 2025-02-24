require "application_system_test_case"

class TrainingPlayerTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def setup
    # Configure headless mode based on environment variable
    Capybara.javascript_driver = ENV["OPEN_BROWSER"] ? :selenium_chrome : :selenium_chrome_headless

    # Create test data
    @team = create(:team)
    @user = create(:user)
    @membership = create(:membership, user: @user, team: @team)

    # Create a training program with various content types
    @program = create(:training_program,
      team: @team,
      name: "Test Training Program",
      state: "published")

    # Create different types of content
    @video_content = create(:training_content,
      training_program: @program,
      title: "Video Module",
      content_type: "video",
      sort_order: 1)

    @document_content = create(:training_content,
      training_program: @program,
      title: "Document Module",
      content_type: "document",
      body: "Test document content",
      sort_order: 2)

    @quiz_content = create(:training_content,
      training_program: @program,
      title: "Quiz Module",
      content_type: "quiz",
      sort_order: 3)

    # Create quiz questions
    create(:training_question,
      training_content: @quiz_content,
      title: "Multiple Choice Question",
      body: "What is the correct answer?",
      question_type: "multiple_choice",
      options: [
        {id: 1, text: "Correct Answer", correct: true},
        {id: 2, text: "Wrong Answer 1", correct: false},
        {id: 3, text: "Wrong Answer 2", correct: false}
      ])

    sign_in @user
  end

  test "viewing training program player" do
    visit account_team_training_program_player_path(@team, @program)

    assert_selector "h2", text: @program.name
    assert_selector ".module-navigation"
    assert_selector ".progress-bar"
  end

  test "navigating between modules" do
    visit account_team_training_program_player_path(@team, @program)

    # First module should be active
    assert_selector ".module-button.active", text: "Video Module"

    # Click second module
    click_on "Document Module"
    assert_selector ".module-button.active", text: "Document Module"
    assert_text "Test document content"
  end

  test "completing video module" do
    visit account_team_training_program_player_path(@team, @program)

    # Simulate video completion
    page.execute_script("document.querySelector('video').dispatchEvent(new Event('ended'))")

    # Wait for progress update
    assert_selector ".module-button.complete", text: "Video Module"
  end

  test "completing quiz module" do
    visit account_team_training_program_player_path(@team, @program)

    # Navigate to quiz
    click_on "Quiz Module"

    # Answer question correctly
    choose "Correct Answer"
    click_on "Submit Answers"

    # Wait for completion
    assert_text "Congratulations! You passed!"
    assert_selector ".module-button.complete", text: "Quiz Module"
  end

  test "generating certificate on completion" do
    # Mark all modules as complete
    @program.training_contents.each do |content|
      create(:training_progress,
        training_program: @program,
        training_content: content,
        membership: @membership,
        status: "completed")
    end

    visit account_team_training_program_player_path(@team, @program)

    # Wait for certificate generation
    assert_text "Training Completed!"
    assert_selector "a", text: "View Certificate"

    # Verify certificate
    click_on "View Certificate"
    assert_selector ".certificate-number"
  end

  test "progress persistence" do
    visit account_team_training_program_player_path(@team, @program)

    # Complete first module
    page.execute_script("document.querySelector('video').dispatchEvent(new Event('ended'))")

    # Reload page
    visit account_team_training_program_player_path(@team, @program)

    # Verify progress persisted
    assert_selector ".module-button.complete", text: "Video Module"
  end

  test "responsive design" do
    # Test mobile view
    page.driver.browser.manage.window.resize_to(375, 812) # iPhone X dimensions
    visit account_team_training_program_player_path(@team, @program)

    assert_selector ".training-player"
    assert_selector ".module-navigation"

    # Test desktop view
    page.driver.browser.manage.window.resize_to(1920, 1080)
    visit account_team_training_program_player_path(@team, @program)

    assert_selector ".training-player"
    assert_selector ".module-navigation"
  end
end
