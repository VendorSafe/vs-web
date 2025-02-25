require_relative '../../lib/company_generator'

def create_demo_environment(env_data)
  # Create organizations
  power_company = Team.create!(
    name: env_data[:power_company],
    time_zone: 'America/Los_Angeles'
  )

  vendor_company = Team.create!(
    name: env_data[:vendor_company],
    time_zone: 'America/Los_Angeles'
  )

  # Create users with appropriate roles
  customer = User.create!(
    email: env_data[:emails][:customer],
    password: 'demo123',
    password_confirmation: 'demo123',
    first_name: 'Plant',
    last_name: 'Manager',
    team: power_company
  )
  customer.add_role(:customer)

  vendor = User.create!(
    email: env_data[:emails][:vendor],
    password: 'demo123',
    password_confirmation: 'demo123',
    first_name: 'CEMS',
    last_name: 'Supervisor',
    team: vendor_company
  )
  vendor.add_role(:vendor)

  employee = User.create!(
    email: env_data[:emails][:employee],
    password: 'demo123',
    password_confirmation: 'demo123',
    first_name: 'CEMS',
    last_name: 'Technician',
    team: vendor_company
  )
  employee.add_role(:employee)

  # Create sample CEMS training program
  training_program = TrainingProgram.create!(
    title: 'CEMS Certification - Part 40 CFR 75',
    description: 'Comprehensive training for Continuous Emissions Monitoring Systems (CEMS) certification and maintenance procedures.',
    team: power_company,
    state: 'published'
  )

  # Create sample content
  video_content = TrainingContent.create!(
    training_program: training_program,
    title: 'CEMS Installation and Calibration',
    content_type: 'video',
    duration: 1800, # 30 minutes
    video_url: 'https://example.com/cems-training.mp4'
  )

  quiz_content = TrainingContent.create!(
    training_program: training_program,
    title: 'CEMS Certification Quiz',
    content_type: 'quiz',
    good_answers: [
      'Perform daily calibration drift assessments',
      'Document all maintenance activities',
      'Follow QA/QC procedures strictly',
      'Maintain backup data collection'
    ].join("\n"),
    bad_answers: [
      'Skip weekly maintenance checks',
      'Ignore calibration errors',
      'Use uncertified calibration gases',
      'Disable data backup systems'
    ].join("\n")
  )

  # Assign program to vendor
  TrainingMembership.create!(
    user: vendor,
    training_program: training_program,
    role: 'assignee'
  )

  {
    power_company: power_company,
    vendor_company: vendor_company,
    users: {
      customer: customer,
      vendor: vendor,
      employee: employee
    }
  }
end

# Get number of environments from command line or default to 1
env_count = ARGV[0]&.to_i || 1

# Generate and create environments
environments = CompanyGenerator.generate_environment(env_count)
created_environments = environments.map do |env_data|
  create_demo_environment(env_data)
end

# Print setup information
puts "\n=== Demo Environments Created ==="
created_environments.each_with_index do |env, index|
  puts "\nEnvironment #{index + 1}:"
  puts "Power Company: #{env[:power_company].name}"
  puts "CEMS Vendor: #{env[:vendor_company].name}"
  puts "\nLogin Credentials (password: demo123):"
  puts "Plant Manager: #{env[:users][:customer].email}"
  puts "CEMS Supervisor: #{env[:users][:vendor].email}"
  puts "CEMS Technician: #{env[:users][:employee].email}"
  puts "\n" + ('=' * 40)
end
