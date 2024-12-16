puts "🌱 Generating development environment seeds."

# begin
  # We use this stub to test `seeding?` for ActiveRecord models.

  user_admin = User.create!(
    email: "jcsarda+admin@gmail.com",
    password: "password",
    first_name: "John",
    last_name: "Sarda",
    time_zone: ActiveSupport::TimeZone.all.first.name,
    locale: "en"
  )

  # user_facility = User.create!(email: "jcsarda+facility@gmail.com", password: "password", first_name: "Jane", last_name: "Doe")
  # user_editor = User.create!(email: "jcsarda+editor@gmail.com", password: "password", first_name: "Editor", last_name: "User")
  # user_vendor = User.create!(email: "jcsarda+vendor@gmail.com", password: "password", first_name: "Vendor", last_name: "User")
  # user_trainee = User.create!(email: "jcsarda+trainee@gmail.com", password: "password", first_name: "Trainee", last_name: "User")
  # team_admin = Team.create!(name: "Admins")
  # team_facility = Team.create!(name: "First Facility Team")
  # team_vendor = Team.create!(name: "First Vendor Team")

  # # Fix
  # user_admin.update(
  #   time_zone: ActiveSupport::TimeZone.all.first.name,
  #   locale: "en"
  #   # sign_in_count { 1 }
  #   # current_sign_in_at { Time.now }
  #   # last_sign_in_at { 1.day.ago }
  #   # current_sign_in_ip { "127.0.0.1" }
  #   # last_sign_in_ip { "127.0.0.2" }
  # )

  # Create a team for administrators
  team_admin = user_admin.teams.create!(
    name: "Developer Team",
    slug: "dev",
    time_zone: ActiveSupport::TimeZone.all.first.name,
    locale: "en"
  )

  user_admin
    .memberships
    .find_by(team: team_admin)
    .update(role_ids: [Role.admin.id])

  user_admin.update(current_team: team_admin)

  # Seed sample training programs.
  seed_training_programs 3, user_admin.current_team

  # DEMO - PacifiCorp Training Program
  TrainingProgram.create!(
    name: "(DEMO) PacifiCorp Safety Training",
    team: team_admin
  )

  # DEMO - PacifiCorp Training Program
  TrainingProgram.create!(
    name: "(DEMO) PacifiCorp Safety Training",
    team: team_admin
  )

  # DEMO - PacifiCorp Training Program
  TrainingProgram.create!(
    name: "(DEMO) PacifiCorp Safety Training",
    team: team_admin
  )
# rescue Exception => e
#   puts "An error occurred while seeding the database: #{e.message} \n#{e.to_json} \n#{e.inspect}"
#   # Optionally, you can also log the error or take other actions as needed
#   #   # Access the backtrace
#   backtrace = e.backtrace
#   # The backtrace is an array of strings, each representing a line in the call stack
#   # For example, to get the line number of the exception:
#   exception_line = backtrace.first.split(":").last.to_i
#   puts "Exception occurred at line #{exception_line}"
# ensure
#   # Ensure database connections are closed
#   ActiveRecord::Base.clear_active_connections!
# end
