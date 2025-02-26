FactoryBot.define do
  factory :oauth_application do
    association :team
    name { 'Test Application' }
    uid { SecureRandom.hex(8) }
    secret { SecureRandom.hex(16) }
    redirect_uri { 'https://example.com/callback' }
    scopes { 'read write' }
    confidential { true }
  end
end
