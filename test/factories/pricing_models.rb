FactoryBot.define do
  factory :pricing_model do
    association :team
    sequence(:name) { |n| "Pricing Model #{n}" }
    price_type { 'fixed' }
    base_price { 100.0 }
    volume_discount { 10 }
    description { 'Test pricing model description' }

    trait :variable do
      price_type { 'variable' }
    end
  end
end
