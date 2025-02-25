require 'application_system_test_case'

class TrainingContentsTest < ApplicationSystemTestCase
  setup do
    @instructor = create(:user, :instructor)
    @program = create(:training_program)
  end

  test 'instructor can create and manage content' do
    sign_in_as(@instructor)
    visit training_program_path(@program)

    click_on 'Add Content'
    fill_in 'Title', with: 'Safety Basics'
    fill_in 'Description', with: 'Introduction to safety protocols'
    attach_file 'Content File', Rails.root.join('test/fixtures/files/sample.pdf')
    click_on 'Create Content'

    assert_text 'Content was successfully created'
    assert_text 'Safety Basics'
  end

  test 'instructor can reorder content' do
    sign_in_as(@instructor)
    visit training_program_contents_path(@program)

    # Assuming we have drag-and-drop functionality
    assert_text 'Drag to reorder'
    # Add drag-and-drop simulation here
  end
end
