FactoryBot.define do
  factory :pricing_model do
    association :team
    name { "MyString" }
    price_type { "MyString" }
    base_price { 1 }
    volume_discount { 1 }
    description { "MyText" }
  end
end
