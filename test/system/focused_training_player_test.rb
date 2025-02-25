require 'application_system_test_case'

class FocusedTrainingPlayerTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def setup
    # Configure headless mode based on environment variable
    Capybara.javascript_driver = ENV['OPEN_BROWSER'] ? :selenium_chrome : :selenium_chrome_headless

    # Create minimal test data
    @team = create(:team)
    @user = create(:user)
    @membership = create(:membership, user: @user, team: @team)

    # Create a training program with just one content type
    @program = create(:training_program,
                      team: @team,
                      name: 'Focused Test Program',
                      state: 'published')

    # Create just one video content for focused testing
    @video_content = create(:training_content, :video,
                            training_program: @program,
                            title: 'Video Module',
                            sort_order: 1)

    sign_in @user
  end

  # A single focused test that verifies just the state column fix
  test 'training program state transitions work correctly' do
    # First check what state the program is actually in
    initial_state = @program.state
    puts "Initial state: #{initial_state}"

    # Test each transition individually to avoid cascading failures

    # Test 1: If published, can transition to archived
    if @program.state == 'published'
      @program.archive!
      assert_equal 'archived', @program.state, 'Failed to transition from published to archived'
    end

    # Test 2: If archived, can transition to published
    if @program.state == 'archived'
      @program.restore!
      assert_equal 'published', @program.state, 'Failed to transition from archived to published'
    end

    # Test 3: If published, can transition to draft
    if @program.state == 'published'
      @program.unpublish!
      assert_equal 'draft', @program.state, 'Failed to transition from published to draft'
    end

    # Test 4: If draft, can transition to published
    if @program.state == 'draft'
      @program.publish!
      assert_equal 'published', @program.state, 'Failed to transition from draft to published'
    end

    # Final assertion to ensure we end in a known state
    assert_includes %w[draft published archived], @program.state,
                    "Program ended in an invalid state: #{@program.state}"
  end

  # A single focused test for the training content factory
  test 'training content factory creates valid content' do
    # Verify the video content was created correctly
    assert @video_content.valid?
    assert_equal 'video', @video_content.content_type
    assert @video_content.content_data['url'].present?

    # Create other content types to verify they work
    text_content = create(:training_content, :text,
                          training_program: @program,
                          title: 'Text Module',
                          sort_order: 2)
    assert text_content.valid?

    document_content = create(:training_content, :document,
                              training_program: @program,
                              title: 'Document Module',
                              sort_order: 3)
    assert document_content.valid?

    quiz_content = create(:training_content, :quiz,
                          training_program: @program,
                          title: 'Quiz Module',
                          sort_order: 4)
    assert quiz_content.valid?
  end
end
