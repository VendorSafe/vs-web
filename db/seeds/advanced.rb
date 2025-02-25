# Advanced scenario seed file
# This file populates the database with more complex data for the advanced demo scenario
# Run with: bin/rails db:seed:advanced

puts 'Creating advanced scenario seed data...'

# Create admin user
admin_email = 'admin@vendorsafe.com'
admin = User.find_by(email: admin_email)

if admin.nil?
  begin
    admin = User.create!(
      email: admin_email,
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Admin',
      last_name: 'User',
      confirmed_at: Time.current
    )
    puts "Created admin user: #{admin.email}"
  rescue ActiveRecord::RecordInvalid => e
    puts "Warning: Could not create admin user: #{e.message}"
    admin = User.find_by(email: admin_email)
    if admin.nil?
      puts 'Error: Could not find or create admin user'
    else
      puts "Using existing admin user: #{admin.email}"
    end
  end
else
  puts "Using existing admin user: #{admin.email}"
end

# Create customer organization
customer_team = Team.find_or_create_by!(name: 'Example Power Plant') do |team|
  team.time_zone = 'Pacific Time (US & Canada)'
  puts "Created customer team: #{team.name}"
end

# Create customer user
customer_email = 'customer@example.com'
customer = User.find_by(email: customer_email)

if customer.nil?
  begin
    customer = User.create!(
      email: customer_email,
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Customer',
      last_name: 'User',
      confirmed_at: Time.current
    )
    puts "Created customer user: #{customer.email}"
  rescue ActiveRecord::RecordInvalid => e
    puts "Warning: Could not create customer user: #{e.message}"
    customer = User.find_by(email: customer_email)
    if customer.nil?
      puts 'Error: Could not find or create customer user'
    else
      puts "Using existing customer user: #{customer.email}"
    end
  end
else
  puts "Using existing customer user: #{customer.email}"
end

# Add customer to team with customer role
if customer
  customer_membership = Membership.find_by(user: customer, team: customer_team)
  if customer_membership.nil?
    begin
      customer_membership = Membership.create!(
        user: customer,
        team: customer_team,
        role_ids: ['customer']
      )
      puts 'Added customer user to team with customer role'
    rescue ActiveRecord::RecordInvalid => e
      puts "Warning: Could not add customer to team: #{e.message}"
    end
  else
    puts 'Customer is already a member of the team'
  end
end

# Create vendor organization
vendor_team = Team.find_or_create_by!(name: 'CEMS Technology Inc.') do |team|
  team.time_zone = 'Pacific Time (US & Canada)'
  puts "Created vendor team: #{team.name}"
end

# Create vendor user
vendor_email = 'vendor@cemstech.com'
vendor = User.find_by(email: vendor_email)

if vendor.nil?
  begin
    vendor = User.create!(
      email: vendor_email,
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Vendor',
      last_name: 'User',
      confirmed_at: Time.current
    )
    puts "Created vendor user: #{vendor.email}"
  rescue ActiveRecord::RecordInvalid => e
    puts "Warning: Could not create vendor user: #{e.message}"
    vendor = User.find_by(email: vendor_email)
    if vendor.nil?
      puts 'Error: Could not find or create vendor user'
    else
      puts "Using existing vendor user: #{vendor.email}"
    end
  end
else
  puts "Using existing vendor user: #{vendor.email}"
end

# Add vendor to customer team with vendor role
if vendor
  vendor_membership = Membership.find_by(user: vendor, team: customer_team)
  if vendor_membership.nil?
    begin
      vendor_membership = Membership.create!(
        user: vendor,
        team: customer_team,
        role_ids: ['vendor']
      )
      puts 'Added vendor user to customer team with vendor role'
    rescue ActiveRecord::RecordInvalid => e
      puts "Warning: Could not add vendor to team: #{e.message}"
    end
  else
    puts 'Vendor is already a member of the team'
  end
end

# Create employee users
employees = []
3.times do |i|
  email = "employee#{i + 1}@cemstech.com"

  # First check if user exists
  employee = User.find_by(email: email)

  # If not found, create a new user
  if employee.nil?
    begin
      employee = User.create!(
        email: email,
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'Employee',
        last_name: "#{i + 1}",
        confirmed_at: Time.current
      )
      puts "Created employee user: #{email}"
    rescue ActiveRecord::RecordInvalid => e
      # If creation fails, try to find the user again (might have been created by another process)
      puts "Warning: Could not create employee user: #{e.message}"
      employee = User.find_by(email: email)
      if employee.nil?
        puts "Error: Could not find or create employee user with email: #{email}"
        next
      end
    end
  else
    puts "Using existing employee user: #{email}"
  end

  employees << employee

  # Add employee to customer team with employee role if not already a member
  membership = Membership.find_by(user: employee, team: customer_team)
  if membership.nil?
    begin
      membership = Membership.create!(
        user: employee,
        team: customer_team,
        role_ids: ['employee']
      )
      puts "Added employee #{i + 1} to customer team with employee role"
    rescue ActiveRecord::RecordInvalid => e
      puts "Warning: Could not add employee to team: #{e.message}"
    end
  else
    puts "Employee #{i + 1} is already a member of the team"
  end
end

# Create multiple training programs
training_programs = []

# Create pricing models
begin
  standard_pricing = PricingModel.find_or_create_by!(name: 'Standard', team: customer_team) do |pm|
    # Try different attribute names for price
    if pm.respond_to?(:price=)
      pm.price = 199.99
    elsif pm.respond_to?(:price_type=)
      pm.price_type = 'fixed'
      pm.price_amount = 199.99
    elsif pm.respond_to?(:amount=)
      pm.amount = 199.99
    end
    puts 'Created Standard pricing model'
  end

  basic_pricing = PricingModel.find_or_create_by!(name: 'Basic', team: customer_team) do |pm|
    # Try different attribute names for price
    if pm.respond_to?(:price=)
      pm.price = 149.99
    elsif pm.respond_to?(:price_type=)
      pm.price_type = 'fixed'
      pm.price_amount = 149.99
    elsif pm.respond_to?(:amount=)
      pm.amount = 149.99
    end
    puts 'Created Basic pricing model'
  end

  economy_pricing = PricingModel.find_or_create_by!(name: 'Economy', team: customer_team) do |pm|
    # Try different attribute names for price
    if pm.respond_to?(:price=)
      pm.price = 99.99
    elsif pm.respond_to?(:price_type=)
      pm.price_type = 'fixed'
      pm.price_amount = 99.99
    elsif pm.respond_to?(:amount=)
      pm.amount = 99.99
    end
    puts 'Created Economy pricing model'
  end
rescue StandardError => e
  puts "Warning: Could not create pricing models: #{e.message}"
  # Try to find existing pricing models
  standard_pricing = PricingModel.find_by(name: 'Standard', team: customer_team)
  basic_pricing = PricingModel.find_by(name: 'Basic', team: customer_team)
  economy_pricing = PricingModel.find_by(name: 'Economy', team: customer_team)

  # If no pricing models found, create dummy ones
  if standard_pricing.nil? && basic_pricing.nil? && economy_pricing.nil?
    puts 'Creating dummy pricing model references'
    standard_pricing = PricingModel.first
    basic_pricing = standard_pricing
    economy_pricing = standard_pricing
  end
end

# CEMS Certification Program
cems_program = TrainingProgram.find_or_create_by!(
  team: customer_team,
  name: 'CEMS Certification Program'
) do |program|
  program.description = 'Comprehensive training for Continuous Emissions Monitoring Systems (CEMS)'
  program.pricing_model = standard_pricing
  # Don't set workflow_state directly, it will be set to 'draft' by default
  puts 'Created CEMS Certification Program'
end
# Publish the program using the workflow event
if cems_program.workflow_state == 'draft'
  cems_program.publish!
  puts 'Published CEMS Certification Program'
end
training_programs << cems_program

# EPA Compliance Training
epa_program = TrainingProgram.find_or_create_by!(
  team: customer_team,
  name: 'EPA Compliance Training'
) do |program|
  program.description = 'Essential training for EPA regulations and compliance requirements'
  program.pricing_model = basic_pricing
  # Don't set workflow_state directly, it will be set to 'draft' by default
  puts 'Created EPA Compliance Training'
end
# Publish the program using the workflow event
if epa_program.workflow_state == 'draft'
  epa_program.publish!
  puts 'Published EPA Compliance Training'
end
training_programs << epa_program

# Safety Protocols Training
safety_program = TrainingProgram.find_or_create_by!(
  team: customer_team,
  name: 'Safety Protocols Training'
) do |program|
  program.description = 'Critical safety procedures for power plant operations'
  program.pricing_model = economy_pricing
  # Don't set workflow_state directly, it will be set to 'draft' by default
  puts 'Created Safety Protocols Training'
end
# Publish the program using the workflow event
if safety_program.workflow_state == 'draft'
  safety_program.publish!
  puts 'Published Safety Protocols Training'
end
training_programs << safety_program

# Add content to training programs
training_programs.each do |program|
  # Video content
  video_content = TrainingContent.find_or_create_by!(
    training_program: program,
    title: "Introduction to #{program.name.split(' ').first}"
  ) do |content|
    content.description = "Overview of #{program.name}"
    content.content_type = 'video'
    content.content_data = { video_url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' }
    content.duration = '30 minutes'
    puts "Added video content to #{program.name}"
  end

  # Quiz content
  quiz_content = TrainingContent.find_or_create_by!(
    training_program: program,
    title: "#{program.name.split(' ').first} Knowledge Check"
  ) do |content|
    content.description = "Test your knowledge of #{program.name}"
    content.content_type = 'quiz'
    content.duration = '15 minutes'
    puts "Added quiz content to #{program.name}"
  end

  # Add questions to quiz
  3.times do |i|
    TrainingQuestion.find_or_create_by!(
      training_content: quiz_content,
      question_text: "Sample question #{i + 1} for #{program.name}"
    ) do |question|
      question.answer_options = [
        "Correct answer for question #{i + 1}",
        "Wrong answer 1 for question #{i + 1}",
        "Wrong answer 2 for question #{i + 1}",
        "Wrong answer 3 for question #{i + 1}"
      ]
      question.correct_answer = 0 # First option is correct
      puts "Added question #{i + 1} to #{program.name} quiz"
    end
  end

  # Assign training to employees
  employees.each do |employee|
    # Find the membership for this employee
    employee_membership = Membership.find_by(user: employee, team: customer_team)
    next unless employee_membership

    # Create training membership through the program's enroll_trainee method
    training_membership = program.enroll_trainee(employee)
    next unless training_membership && training_membership.new_record?

    training_membership.progress_data = { completed: false, percentage: 0 }
    training_membership.save!
    puts "Assigned #{program.name} to #{employee.email}"
  end

  # Complete first program for first employee
  next unless program == cems_program

  # Find the membership for the first employee
  employee_membership = Membership.find_by(user: employees.first, team: customer_team)
  next unless employee_membership

  # Find or create the training membership
  training_membership = TrainingMembership.find_by(
    membership: employee_membership,
    training_program: program
  )
  next unless training_membership

  # Update progress
  training_membership.update!(
    progress_data: { completed: true, percentage: 100 }
  )
  puts "Updated progress for #{employees.first.email} on #{program.name}"

  # Create certificate
  TrainingCertificate.find_or_create_by!(
    membership: employee_membership,
    training_program: program,
    team: customer_team
  ) do |certificate|
    certificate.issued_at = 1.week.ago
    certificate.expires_at = 1.year.from_now
    certificate.verification_code = SecureRandom.hex(10)
    puts "Created certificate for #{employees.first.email} for #{program.name}"
  end
end

puts 'Advanced scenario seed data created successfully!'
