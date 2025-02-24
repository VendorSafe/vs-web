FactoryBot.define do
  factory :training_program do
    team
    sequence(:name) { |n| "Training Program #{n}" }
    description { "Test training program description" }
    state { "draft" }
    passing_percentage { 70 }
    certificate_validity_period { 365 }
    certificate_template { "default" }
    custom_certificate_fields { {company_name: "Test Company"} }

    trait :published do
      state { "published" }
    end

    trait :archived do
      state { "archived" }
    end

    trait :with_contents do
      after(:create) do |program|
        create(:training_content, :video, training_program: program, sort_order: 1)
        create(:training_content, :document, training_program: program, sort_order: 2)
        create(:training_content, :quiz, training_program: program, sort_order: 3)
      end
    end
  end

  factory :training_content do
    training_program
    sequence(:title) { |n| "Content #{n}" }
    content_type { "document" }
    body { "Test content body" }
    sort_order { 1 }

    trait :video do
      content_type { "video" }
      after(:create) do |content|
        # Attach a sample video file
        content.video.attach(
          io: File.open(Rails.root.join("test/fixtures/files/sample.mp4")),
          filename: "sample.mp4",
          content_type: "video/mp4"
        )
      end
    end

    trait :document do
      content_type { "document" }
      body { "Test document content with **markdown** support" }
    end

    trait :quiz do
      content_type { "quiz" }
      after(:create) do |content|
        create(:training_question, :multiple_choice, training_content: content)
        create(:training_question, :true_false, training_content: content)
      end
    end
  end

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
  end

  factory :training_progress do
    training_program
    training_content
    membership
    status { "not_started" }
    score { nil }
    time_spent { 0 }

    trait :completed do
      status { "completed" }
      score { 100 }
      time_spent { 300 } # 5 minutes
      last_accessed_at { Time.current }
    end

    trait :in_progress do
      status { "in_progress" }
      time_spent { 150 } # 2.5 minutes
      last_accessed_at { Time.current }
    end
  end

  factory :training_certificate do
    training_program
    membership
    issued_at { Time.current }
    sequence(:certificate_number) { |n| "CERT-#{Time.current.strftime("%Y-%m")}-#{n.to_s.rjust(6, "0")}" }
    score { 85 }

    trait :expired do
      issued_at { 2.years.ago }
      expires_at { 1.year.ago }
    end

    trait :valid do
      issued_at { 6.months.ago }
      expires_at { 6.months.from_now }
    end
  end

  factory :training_membership do
    training_program
    membership
    completion_percentage { 0 }
    progress { {} }

    trait :completed do
      completion_percentage { 100 }
      completed_at { Time.current }
      progress do
        {
          completed_modules: [1, 2, 3],
          total_time: 900, # 15 minutes
          last_accessed_at: Time.current
        }
      end
    end

    trait :in_progress do
      completion_percentage { 33 }
      progress do
        {
          completed_modules: [1],
          current_position: 0,
          total_time: 300 # 5 minutes
        }
      end
    end
  end
end
