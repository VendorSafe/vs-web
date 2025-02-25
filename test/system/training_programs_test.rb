require 'application_system_test_case'

class TrainingProgramsTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin)
    @training_manager = create(:user, :training_manager)
    @instructor = create(:user, :instructor)
    @student = create(:user, :student)
    @program = create(:training_program, :with_contents)
    @student_program = create(:training_program, :with_contents, :published)
    @student.training_enrollments.create!(training_program: @student_program)
  end

  test 'admin can create and manage training programs' do
    sign_in_as(@admin)
    visit training_programs_path

    assert_text 'Training Programs'

    click_on 'New Training Program'
    fill_in 'Title', with: 'Advanced Safety Training'
    fill_in 'Description', with: 'Comprehensive safety protocols'
    # Add initial content
    click_on 'Add Content'
    select 'Video', from: 'Content Type'
    fill_in 'Title', with: 'Safety Basics Video'
    fill_in 'Video URL', with: 'https://example.com/safety-video.mp4'
    click_on 'Add Content'

    wait_for_ajax
    click_on 'Create Training Program'
    wait_for_ajax

    assert_text 'Training program was successfully created'
    assert_text 'Advanced Safety Training'
    assert_text 'Safety Basics Video'
  end

  test 'training manager can edit but not delete programs' do
    sign_in_as(@training_manager)
    visit training_program_path(@program)

    assert_text 'Edit'
    assert_no_text 'Delete Program'

    click_on 'Edit'
    fill_in 'Title', with: 'Updated Program Title'

    # Edit existing content
    within('.content-list') do
      click_on 'Edit', match: :first
      fill_in 'Title', with: 'Updated Content Title'
      click_on 'Update Content'
    end
    wait_for_ajax

    click_on 'Update Training Program'
    wait_for_ajax

    assert_text 'Training program was successfully updated'
    assert_text 'Updated Program Title'
    assert_text 'Updated Content Title'
  end

  test 'student can only view and access assigned programs' do
    sign_in_as(@student)
    visit training_programs_path

    # Verify management buttons are not visible
    assert_no_text 'New Training Program'
    assert_no_text 'Edit'
    assert_no_text 'Delete'

    # Verify only assigned program is visible
    assert_text @student_program.name
    assert_no_text @program.name

    # Verify can access assigned program content
    click_on @student_program.name
    wait_for_ajax

    assert_text 'Start Training'
    within('.content-list') do
      assert_selector '.training-content', count: 3
      assert_text 'Video Content'
      assert_text 'Document Content'
      assert_text 'Quiz Content'
    end
  end
end
