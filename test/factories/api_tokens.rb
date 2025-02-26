FactoryBot.define do
  # Create an alias for api_token that points to oauth_access_token
  factory :api_token, parent: :oauth_access_token do
    # Any specific overrides for API tokens can be added here
  end
end
