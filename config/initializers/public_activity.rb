# Configure PublicActivity to use unquoted table names
PublicActivity::Activity.table_name = "activities"

# Disable parameters serialization warning
PublicActivity.enabled = false if Rails.env.test?
