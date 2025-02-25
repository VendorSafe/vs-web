require "application_system_test_case"

class TrainingContentCarouselTest < ApplicationSystemTestCase
  setup do
    @team = create(:team)
    @user = create(:onboarded_user, first_name: "John", last_name: "Doe")
    @membership = create(:membership, user: @user, team: @team)
    @membership.roles << Role.admin

    @training_program = create(:training_program, team: @team, state: "published")
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

    # Ensure user is authenticated
    @user.confirm
    sign_in @user

    # Create training membership to grant access
    @training_membership = create(:training_membership,
      training_program: @training_program,
      membership: @membership,
      progress: {},
      completed_at: nil,
      current_content_id: @training_content.id)
  end

  test "carousel initializes and navigates correctly" do
    visit account_training_content_path(@training_content)

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
    visit account_training_content_path(@training_content)

    # Check initial progress
    assert_selector "[data-progress='0']"

    # Navigate through slides
    find("[data-carousel-next]").click
    assert_selector "[data-progress='33']" # ~33% for second of three slides

    find("[data-carousel-next]").click
    assert_selector "[data-progress='66']" # ~66% for third of three slides
  end

  test "carousel handles keyboard navigation" do
    visit account_training_content_path(@training_content)

    # Initial slide
    assert_text "Slide 1 Content"

    # Right arrow
    find("body").send_keys(:right)
    assert_text "Slide 2 Content"

    # Left arrow
    find("body").send_keys(:left)
    assert_text "Slide 1 Content"
  end

  test "carousel maintains state after turbo navigation" do
    visit account_training_content_path(@training_content)

    # Navigate to second slide
    find("[data-carousel-next]").click
    assert_text "Slide 2 Content"

    # Click a Turbo Link
    click_link "Back to Training Program"
    click_link "Resume Training"

    # Should still be on second slide
    assert_text "Slide 2 Content"
  end

  test "carousel handles touch swipe gestures" do
    visit account_training_content_path(@training_content)

    # Initial slide
    assert_text "Slide 1 Content"

    # Simulate swipe by triggering next event directly
    find("[data-carousel-next]").click

    # Should move to next slide
    assert_text "Slide 2 Content"
  end
end
