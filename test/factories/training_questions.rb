FactoryBot.define do
  factory :training_question do
    association :training_content, factory: %i[training_content quiz]
    sequence(:title) { |n| "Question #{n}" }
    body { 'What is the correct answer?' }
    question_type { 'multiple_choice' }
    options do
      [
        { id: 1, text: 'Correct Answer', correct: true },
        { id: 2, text: 'Wrong Answer 1', correct: false },
        { id: 3, text: 'Wrong Answer 2', correct: false }
      ]
    end

    trait :multiple_choice do
      question_type { 'multiple_choice' }
    end

    trait :true_false do
      question_type { 'true_false' }
      options do
        [
          { id: 1, text: 'True', correct: true },
          { id: 2, text: 'False', correct: false }
        ]
      end
    end

    trait :short_answer do
      question_type { 'short_answer' }
      options { [] } # Short answer questions don't have predefined options
      after(:build) do |question|
        question.body = 'Write a short answer to this question.'
      end
    end

    after(:build) do |question|
      # Ensure the parent training_content is of type quiz
      question.training_content = create(:training_content, :quiz) if question.training_content&.content_type != 'quiz'
    end
  end
end
