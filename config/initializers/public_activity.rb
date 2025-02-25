# Configure PublicActivity to use unquoted table names
PublicActivity::Activity.table_name = 'activities'

# Disable parameters serialization warning and silence deprecation warnings in test environment
if Rails.env.test?
  PublicActivity.enabled = false
  ActiveSupport::Deprecation.silenced = true if defined?(ActiveSupport::Deprecation)
end
