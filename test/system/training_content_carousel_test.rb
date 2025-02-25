require 'application_system_test_case'

class TrainingContentCarouselTest < ApplicationSystemTestCase
  setup do
    @team = create(:team)
    @user = create(:user, :student)
    @team.memberships.create(user: @user)

    @program = create(:training_program, :published, team: @team)
    @user.training_enrollments.create!(training_program: @program)

    @content = create(:training_content, :presentation, training_program: @program, content_data: {
                        slides: [
                          { content: 'Introduction to Safety', description: 'Learn about workplace safety basics' },
                          { content: 'Safety Equipment', description: 'Essential protective gear' },
                          { content: 'Emergency Procedures', description: 'What to do in emergencies' }
                        ]
                      })
  end

  test 'basic carousel navigation and content visibility' do
    visit training_program_path(@program)
    click_on @content.title
    wait_for_carousel

    # Verify initial slide
    assert_current_slide 'Introduction to Safety'
    assert_text 'Learn about workplace safety basics'
    assert_carousel_progress(33)

    # Navigate to second slide
    navigate_carousel('next')
    assert_current_slide 'Safety Equipment'
    assert_text 'Essential protective gear'
    assert_carousel_progress(66)

    # Navigate to third slide
    navigate_carousel('next')
    assert_current_slide 'Emergency Procedures'
    assert_text 'What to do in emergencies'
    assert_carousel_progress(100)

    # Navigate back
    navigate_carousel('prev')
    assert_current_slide 'Safety Equipment'
    assert_carousel_progress(66)
  end

  test 'carousel progress updates with navigation' do
    visit training_program_path(@program)
    click_on @content.title
    wait_for_carousel

    # Initial state
    assert_carousel_progress(33)
    assert_selector '[data-carousel-prev]', class: 'disabled'
    assert_selector '[data-carousel-next]', class: 'enabled'

    # Navigate forward
    navigate_carousel('next')
    assert_carousel_progress(66)
    assert_selector '[data-carousel-prev]', class: 'enabled'
    assert_selector '[data-carousel-next]', class: 'enabled'

    # Navigate to end
    navigate_carousel('next')
    assert_carousel_progress(100)
    assert_selector '[data-carousel-prev]', class: 'enabled'
    assert_selector '[data-carousel-next]', class: 'disabled'

    # Verify completion tracking
    assert_selector "[data-status='completed']"
    within('.progress-indicator') do
      assert_text '3/3 slides completed'
    end
  end

  test 'swipe navigation with touch gestures' do
    visit training_program_path(@program)
    click_on @content.title
    wait_for_carousel

    # Initial slide
    assert_current_slide 'Introduction to Safety'

    # Swipe left to next slide
    simulate_swipe(:left)
    wait_for_ajax
    assert_current_slide 'Safety Equipment'

    # Swipe left to last slide
    simulate_swipe(:left)
    wait_for_ajax
    assert_current_slide 'Emergency Procedures'

    # Swipe right back to middle
    simulate_swipe(:right)
    wait_for_ajax
    assert_current_slide 'Safety Equipment'

    # Verify slide transitions
    assert_selector '.slide-transition-enter-active', count: 0
  end
end
