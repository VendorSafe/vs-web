# frozen_string_literal: true

require "faker"

namespace :users do
  desc "Generate random users with different roles"
  task generate: :environment do
    def create_user_with_role(role)
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      email = Faker::Internet.email(name: "#{first_name} #{last_name}", domain: "example.com")

      # Create or find team based on role
      team_name = case role
                 when "admin"
                   "Administration Team"
                 when "vendor"
                   # All vendors belong to same team for invitations
                   "Vendor Team #{Faker::Company.name}"
                 when "customer"
                   "#{Faker::Company.name} Customer"
                 else
                   "#{Faker::Company.name} Organization"
                 end

      team = Team.find_or_create_by!(name: team_name) do |t|
        t.time_zone = "Pacific Time (US & Canada)"
        t.locale = "en"
      end

      # Create user with random password
      password = "password123" # Use fixed password for development
      user = User.create!(
        email: email,
        password: password,
        password_confirmation: password,
        first_name: first_name,
        last_name: last_name,
        time_zone: team.time_zone
      )

      # Create membership with role
      membership = Membership.create!(
        user: user,
        team: team,
        role_ids: [role]
      )

      # Add role-specific setup
      case role
      when "vendor"
        # First vendor in a team is considered primary and can invite others
        is_primary = team.memberships.where(role_ids: ["vendor"]).count == 0

        if is_primary
          # Create a sample training program for primary vendor
          TrainingProgram.create!(
            team: team,
            name: "#{Faker::Educator.course_name} Training",
            description: Faker::Lorem.paragraph,
            status: "active"
          )
          puts "  Primary Vendor: Yes (can invite other vendors)"
        else
          puts "  Primary Vendor: No (invited vendor)"
        end
      when "customer"
        # Create a sample location for customer
        Location.create!(
          team: team,
          name: Faker::Company.name,
          address: Faker::Address.full_address,
          location_type: ["office", "factory", "warehouse"].sample
        )
      end

      puts "Created #{role.upcase} user:"
      puts "  Name: #{user.first_name} #{user.last_name}"
      puts "  Email: #{user.email}"
      puts "  Password: #{password}"
      puts "  Team: #{team.name}"
      puts "  Role: #{role}"
      puts "----------------------------------"
    end

    # Generate one user for each role
    %w[admin vendor customer employee].each do |role|
      create_user_with_role(role)
    end
  end

  desc "Generate specified number of users for a role"
  task :generate_role, [:role, :count] => :environment do |_, args|
    role = args[:role]
    count = (args[:count] || 1).to_i

    unless %w[admin vendor customer employee].include?(role)
      puts "Invalid role. Please use: admin, vendor, customer, or employee"
      next
    end

    count.times do
      create_user_with_role(role)
    end
  end
end

# Usage:
# Generate one of each role:
#   rails users:generate
#
# Generate specific number of users for a role:
#   rails users:generate_role[vendor,3]
#   rails users:generate_role[customer,5]