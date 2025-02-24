puts "🌱 Generating development environment seeds."

require_relative "../../config/seeder_config"

# Get a valid time zone from Rails
default_time_zone = ActiveSupport::TimeZone.all.first.name

# Create admin user and team
admin_data = SEEDER_CONFIG[:admin]
puts "Creating admin user with email: #{admin_data[:email]}"
user_admin = User.new(
  email: admin_data[:email],
  password: admin_data[:password],
  first_name: admin_data[:first_name],
  last_name: admin_data[:last_name],
  time_zone: default_time_zone,
  locale: admin_data[:locale]
)
user_admin.skip_confirmation!
user_admin.save!

# Create admin team
team_admin = user_admin.teams.create!(
  name: "System Administrators",
  slug: "sys-admin",
  time_zone: default_time_zone,
  locale: admin_data[:locale]
)

# Set admin role and current team
user_admin
  .memberships
  .find_by(team: team_admin)
  .update(role_ids: ["admin"])

user_admin.update(current_team: team_admin)

# Create customer teams and their training programs
customer_teams = {}
SEEDER_CONFIG[:customers].each do |customer_data|
  # Create customer user
  puts "Creating customer user with email: #{customer_data[:email]}"
  customer = User.new(
    email: customer_data[:email],
    password: customer_data[:password],
    first_name: customer_data[:first_name],
    last_name: customer_data[:last_name],
    time_zone: default_time_zone,
    locale: "en"
  )
  customer.skip_confirmation!
  customer.save!

  # Create team for each customer
  team = customer.teams.create!(
    name: customer_data[:company],
    slug: customer_data[:company].parameterize,
    time_zone: default_time_zone,
    locale: "en"
  )

  # Store team for later use
  customer_teams[customer_data[:company]] = team

  # Set customer role
  customer
    .memberships
    .find_by(team: team)
    .update(role_ids: ["customer"])

  customer.update(current_team: team)

  # Create locations
  customer_data[:locations].each do |location_name|
    Location.create!(
      name: location_name,
      team: team
    )
  end

  # Create training programs
  customer_data[:training_programs].each do |program|
    training_program = TrainingProgram.new(
      name: program[:name],
      team: team
    )
    training_program.description = program[:description]
    training_program.save!
  end
end

# Create vendors and associate them with customers
SEEDER_CONFIG[:vendors].each do |vendor_data|
  # Create vendor user
  puts "Creating vendor user with email: #{vendor_data[:email]}"
  vendor = User.new(
    email: vendor_data[:email],
    password: vendor_data[:password],
    first_name: vendor_data[:first_name],
    last_name: vendor_data[:last_name],
    time_zone: default_time_zone,
    locale: "en"
  )
  vendor.skip_confirmation!
  vendor.save!

  # Create team for vendor
  vendor_team = vendor.teams.create!(
    name: vendor_data[:company],
    slug: vendor_data[:company].parameterize,
    time_zone: default_time_zone,
    locale: "en"
  )

  # Set vendor role for their own team
  vendor
    .memberships
    .find_by(team: vendor_team)
    .update(role_ids: ["vendor"])

  vendor.update(current_team: vendor_team)

  # Associate vendor with customer teams
  vendor_data[:serves_customers].each do |customer_company|
    if customer_team = customer_teams[customer_company]
      # Create membership with vendor_associate role for customer teams
      Membership.create!(
        user: vendor,
        team: customer_team,
        role_ids: ["vendor_associate"],
        user_first_name: vendor.first_name,
        user_last_name: vendor.last_name,
        user_email: vendor.email
      )
    end
  end
end

# Create employees
SEEDER_CONFIG[:employees].each do |employee_data|
  # Create employee user
  puts "Creating employee user with email: #{employee_data[:email]}"
  employee = User.new(
    email: employee_data[:email],
    password: employee_data[:password],
    first_name: employee_data[:first_name],
    last_name: employee_data[:last_name],
    time_zone: default_time_zone,
    locale: "en"
  )
  employee.skip_confirmation!
  employee.save!

  # Associate with company team
  if company_team = customer_teams[employee_data[:company]]
    membership = Membership.create!(
      user: employee,
      team: company_team,
      role_ids: ["employee"],
      user_first_name: employee.first_name,
      user_last_name: employee.last_name,
      user_email: employee.email
    )
    employee.update(current_team: company_team)
  end
end

# Create trainees
SEEDER_CONFIG[:trainees].each do |trainee_data|
  # Create trainee user
  puts "Creating trainee user with email: #{trainee_data[:email]}"
  trainee = User.new(
    email: trainee_data[:email],
    password: trainee_data[:password],
    first_name: trainee_data[:first_name],
    last_name: trainee_data[:last_name],
    time_zone: default_time_zone,
    locale: "en"
  )
  trainee.skip_confirmation!
  trainee.save!

  # Associate with company team
  if company_team = customer_teams[trainee_data[:company]]
    membership = Membership.create!(
      user: trainee,
      team: company_team,
      role_ids: ["trainee"],
      user_first_name: trainee.first_name,
      user_last_name: trainee.last_name,
      user_email: trainee.email
    )
    trainee.update(current_team: company_team)

    # Assign training programs
    trainee_data[:assigned_programs].each do |program_name|
      if program = TrainingProgram.find_by(name: program_name, team: company_team)
        # Create training membership for the trainee
        TrainingMembership.create!(
          training_program: program,
          membership: membership
        )
      end
    end
  end
end

puts "✅ Seeding completed successfully!"
