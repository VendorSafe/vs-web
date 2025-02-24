# Load and validate roles configuration
ROLES_CONFIG = YAML.load_file(Rails.root.join("config", "models", "roles.yml"))

# Validate required roles exist
required_roles = %w[admin vendor customer employee]
missing_roles = required_roles - ROLES_CONFIG.keys

if missing_roles.any?
  raise "Missing required roles in roles.yml: \#{missing_roles.join(', ')}"
end
