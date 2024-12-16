FactoryBot.define do
  factory :training_question do
    association :training_content
    title { "MyString" }
    body { "MyText" }
    good_answers { "MyText" }
    bad_answers { "MyText" }
    published_at { "2024-12-15 19:13:14" }
  end
end
