FactoryBot.define do
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
end
