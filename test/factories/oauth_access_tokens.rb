FactoryBot.define do
  factory :oauth_access_token do
    association :application, factory: :oauth_application
    resource_owner_id { create(:user).id }
    token { SecureRandom.hex(32) }
    refresh_token { SecureRandom.hex(32) }
    expires_in { 7200 }
    created_at { Time.current }
    scopes { '' }
    previous_refresh_token { '' }
  end
end
