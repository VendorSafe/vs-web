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

  test "basic carousel navigation" do
    visit account_training_content_path(@training_content)

    # Check initial state
    assert_text "Slide 1 Content"
    refute_text "Slide 2 Content"

    # Test next navigation
    find("[data-carousel-target='next']").click
    assert_text "Slide 2 Content"
    refute_text "Slide 1 Content"

    # Test previous navigation
    find("[data-carousel-target='prev']").click
    assert_text "Slide 1 Content"
    refute_text "Slide 2 Content"
  end

  test "basic progress tracking" do
    visit account_training_content_path(@training_content)

    # Initial progress
    progress = find("[data-carousel-target='progress']")
    assert_equal "0", progress["data-progress"]

    # Progress after navigation
    find("[data-carousel-target='next']").click
    progress = find("[data-carousel-target='progress']")
    assert_equal "50", progress["data-progress"]
  end

  test "basic keyboard navigation" do
    visit account_training_content_path(@training_content)

    # Initial state
    assert_selector "[data-carousel-target='slide'].active", text: "Slide 1 Content"

    # Navigate with keyboard
    find("body").send_keys(:right)
    assert_selector "[data-carousel-target='slide'].active", text: "Slide 2 Content"

    find("body").send_keys(:left)
    assert_selector "[data-carousel-target='slide'].active", text: "Slide 1 Content"
  end
end
