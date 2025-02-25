require "application_system_test_case"

class TrainingContentCarouselTest < ApplicationSystemTestCase
  setup do
    @team = create(:team)
    @user = create(:onboarded_user, first_name: "John", last_name: "Doe")
    @membership = create(:membership, user: @user, team: @team)
    @training_program = create(:training_program, team: @team)
    @training_content = create(:training_content,
      training_program: @training_program,
      content_type: "slides",
      content_data: {
        "slides" => [
          {"id" => 1, "content" => "Slide 1 Content"},
          {"id" => 2, "content" => "Slide 2 Content"},
          {"id" => 3, "content" => "Slide 3 Content"}
        ]
      })
    login_as(@user, scope: :user)
  end

  test "carousel initializes and navigates correctly" do
    visit training_program_training_content_path(@training_program, @training_content)

    # Wait for carousel to initialize
    assert_selector ".carousel", visible: true

    # Check initial slide
    assert_text "Slide 1 Content"

    # Test next button
    find("[data-carousel-next]").click
    assert_text "Slide 2 Content"

    # Test previous button
    find("[data-carousel-prev]").click
    assert_text "Slide 1 Content"

    # Test indicator buttons
    all("[data-carousel-slide-to]").last.click
    assert_text "Slide 3 Content"
  end

  test "carousel tracks slide progress" do
    visit training_program_training_content_path(@training_program, @training_content)

    # Check initial progress
    assert_selector "[data-progress='0']"

    # Navigate through slides
    find("[data-carousel-next]").click
    assert_selector "[data-progress='33']" # ~33% for second of three slides

    find("[data-carousel-next]").click
    assert_selector "[data-progress='66']" # ~66% for third of three slides
  end

  test "carousel handles keyboard navigation" do
    visit training_program_training_content_path(@training_program, @training_content)

    # Initial slide
    assert_text "Slide 1 Content"

    # Right arrow
    find("body").send_keys(:arrow_right)
    assert_text "Slide 2 Content"

    # Left arrow
    find("body").send_keys(:arrow_left)
    assert_text "Slide 1 Content"
  end

  test "carousel maintains state after turbo navigation" do
    visit training_program_training_content_path(@training_program, @training_content)

    # Navigate to second slide
    find("[data-carousel-next]").click
    assert_text "Slide 2 Content"

    # Click a Turbo Link
    click_link "Back to Program"
    click_link "Resume Content"

    # Should still be on second slide
    assert_text "Slide 2 Content"
  end

  test "carousel handles touch swipe gestures", js: true do
    visit training_program_training_content_path(@training_program, @training_content)

    # Initial slide
    assert_text "Slide 1 Content"

    # Simulate swipe left
    page.driver.browser.action
      .move_to(page.find(".carousel").native)
      .click_and_hold
      .move_by(-200, 0)
      .release
      .perform

    # Should move to next slide
    assert_text "Slide 2 Content"
  end
end
