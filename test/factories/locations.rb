FactoryBot.define do
  factory :location do
    association :team
    name { "MyString" }
    address { "MyString" }
    location_type { "MyString" }
  end
end
