FactoryBot.define do
  factory :facility do
    association :team
    name { "MyString" }
    other_attribute { "MyString" }
    url { "MyString" }
  end
end
