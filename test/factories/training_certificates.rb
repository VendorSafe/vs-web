FactoryBot.define do
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
end
