FactoryBot.define do
  factory :training_program do
    team
    sequence(:name) { |n| "Training Program #{n}" }
    description { 'Test training program description' }
    workflow_state { 'draft' }
    passing_percentage { 70 }
    certificate_validity_period { 365 }
    certificate_template { 'default' }
    custom_certificate_fields { { company_name: 'Test Company' } }

    trait :published do
      workflow_state { 'published' }
    end

    trait :archived do
      workflow_state { 'archived' }
    end

    trait :with_contents do
      after(:create) do |program|
        create(:training_content, :video, training_program: program, sort_order: 1)
        create(:training_content, :document, training_program: program, sort_order: 2)
        create(:training_content, :quiz, training_program: program, sort_order: 3)
      end
    end
  end
end
