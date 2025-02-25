# Configure PublicActivity to use unquoted table names
PublicActivity::Activity.table_name = 'activities'

# Disable activity tracking in test environment
PublicActivity.enabled = false if Rails.env.test?
