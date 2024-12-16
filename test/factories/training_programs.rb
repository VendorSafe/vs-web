FactoryBot.define do
  factory :training_program do
    association :team
    name { "MyString" }
    description { "MyText" }
    status { "MyString" }
    slides { "MyText" }
    published_at { "2024-12-15 19:12:44" }
  end
end
