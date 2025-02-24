FactoryBot.define do
  factory :training_membership do
    training_program
    membership
    completion_percentage { 0 }
    progress { {} }

    trait :completed do
      completion_percentage { 100 }
      completed_at { Time.current }
      progress do
        {
          completed_modules: [1, 2, 3],
          total_time: 900, # 15 minutes
          last_accessed_at: Time.current
        }
      end
    end

    trait :in_progress do
      completion_percentage { 33 }
      progress do
        {
          completed_modules: [1],
          current_position: 0,
          total_time: 300 # 5 minutes
        }
      end
    end
  end
end
