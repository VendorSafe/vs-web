FactoryBot.define do
  factory :training_content do
    association :training_program
    title { "MyString" }
    body { "MyText" }
    content_type { "MyString" }
    published_at { "2024-12-15 19:12:58" }
  end
end
