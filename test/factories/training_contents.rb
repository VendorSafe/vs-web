FactoryBot.define do
  factory :training_content do
    training_program
    sequence(:title) { |n| "Content #{n}" }
    content_type { 'text' }
    body { 'Test content body' }
    position { 1 }
    content_data { { 'text' => body } }
    completion_criteria { { 'required_percentage' => 100 } }
    is_required { true }

    trait :video do
      content_type { 'video' }
      content_data { { 'url' => 'https://example.com/test-video.mp4' } }
      completion_criteria { { 'required_percentage' => 80 } }
    end

    trait :text do
      content_type { 'text' }
      content_data { { 'text' => body } }
      completion_criteria { { 'required_percentage' => 100 } }
    end

    trait :quiz do
      content_type { 'quiz' }
      content_data do
        {
          'questions' => [
            {
              'question' => 'Test question 1',
              'answers' => [
                { 'text' => 'Correct answer', 'correct' => true },
                { 'text' => 'Wrong answer', 'correct' => false }
              ]
            }
          ]
        }
      end
      completion_criteria { { 'passing_score' => 80 } }
      after(:create) do |content|
        create(:training_question, :multiple_choice, training_content: content)
        create(:training_question, :true_false, training_content: content)
      end
    end

    trait :slides do
      content_type { 'slides' }
      content_data do
        {
          'slides' => [
            { 'id' => 1, 'content' => 'Slide 1 content' },
            { 'id' => 2, 'content' => 'Slide 2 content' }
          ]
        }
      end
      completion_criteria { { 'required_slides' => [1, 2] } }
    end

    trait :audio do
      content_type { 'audio' }
      content_data { { 'url' => 'https://example.com/test-audio.mp3' } }
      completion_criteria { { 'required_percentage' => 80 } }
    end

    trait :document do
      content_type { 'document' }
      content_data { { 'url' => 'https://example.com/test-document.pdf' } }
      completion_criteria { { 'required_percentage' => 100 } }
    end
  end
end
