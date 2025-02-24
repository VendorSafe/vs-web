FactoryBot.define do
  factory :training_question do
    training_content
    sequence(:title) { |n| "Question #{n}" }
    body { "What is the correct answer?" }
    question_type { "multiple_choice" }
    options do
      [
        {id: 1, text: "Correct Answer", correct: true},
        {id: 2, text: "Wrong Answer 1", correct: false},
        {id: 3, text: "Wrong Answer 2", correct: false}
      ]
    end
    passing_score { 70 }

    trait :multiple_choice do
      question_type { "multiple_choice" }
    end

    trait :true_false do
      question_type { "true_false" }
      options do
        [
          {id: 1, text: "True", correct: true},
          {id: 2, text: "False", correct: false}
        ]
      end
    end

    trait :short_answer do
      question_type { "short_answer" }
      options { [] }  # Short answer questions don't have predefined options
    end
  end
end
