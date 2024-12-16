# Define a namespace for database tasks
namespace :db do
  # Task description for seeding sample training program data
  desc "Seed sample training program data"
  # Define the task to seed training programs
  task seed_training_programs: :environment do
    # Log message indicating the start of seeding
    puts "🌱 Seeding sample training program data."

    # Begin the seeding process
    # begin

      user_admin = create_user_and_team(
        "jcsarda+admin@gmail.com",
        "Dev Team",
        "dev",
        [Role.admin.id]
       )

      mmoser_vendor_teams = [
        create_user_and_team(
          "jcsarda+mmoservendor1@gmail.com",
          "M. Moser - Vendor Team 1",
          "mmoser-vendor-1",
          [Role.admin.id]
        ),
        create_user_and_team(
          "jcsarda+mmoservendor2@gmail.com",
          "M. Moser - Vendor Team 2",
          "mmoser-vendor-2",
          [Role.admin.id]
        ),
        create_user_and_team(
          "jcsarda+mmoservendor3@gmail.com",
          "M. Moser - Vendor Team 3",
          "mmoser-vendor-3",
          [Role.admin.id]
        )
      ]
      # user_admin.memberships.create!(
      #   user: user_admin,
      #   team: user_admin.current_team,
      #   # invitation_id: integer
      #   # user_profile_photo_id: 1,
      #   user_first_name: user_admin.first_name,
      #   user_last_name: user_admin.last_name,
      #   user_email: user_admin.email,
      #   role_ids: ["admin"]
      #   # platform_agent_of_id: nil
      #   # platform_agent: false
      #   # The `added_by` attribute is an optional foreign_key which points
      #   # to another membership and is automatically populated when someone
      #   # on a team invites another person.
      #   #
      #   # For now we can ignore this for the most part unless it becomes necessary.
      #   #
      #   # We do not give it a value in the factory because it will
      #   # cause an infinite loop. If you want to populate this value for
      #   # a Membership in your tests, you can do so by creating a Membership
      #   # and passing it to an :invitation factory:
      #   #
      #   # # (Where `test_team`, `issuer_email`, and `receiver_email` are all custom values)
      #   #
      #   # invitation_issuer_membership = Membership.new(team: test_team, user_email: issuer_email)
      #   # invitation_receiver_membership = Membership.new(team: test_team, user_email: receiver_email)
      #   # create :invitation, team: test_team, from_membership: invitation_issuer_membership, email: receiver_email, membership: invitation_receiver_membership
      #   #
      #   # This will automatically populate the `added_by` attribute for `invitation_receiver_membership`.
      #   # added_by_id:
      # )
      # debugger

      # Invitation.create!(
      #   team: team_admin,
      #   from_membership: user_admin.memberships.first,
      #   membership: team_membership,
      #   email: "jcsarda+admin@gmail.com"
      # )

      # TODO: I may need to do this:
      # invitation_issuer_membership = Membership.new(team: test_team, user_email: issuer_email)
      # invitation_receiver_membership = Membership.new(team: test_team, user_email: receiver_email)
      # create :invitation, team: test_team, from_membership: invitation_issuer_membership, email: receiver_email, membership: invitation_receiver_membership

      # debugger

      # Create a training program under the admin team
      # user_admin.current_team.training_program = TrainingProgram.create!(
      #   name: "Approach 1"
      # )

      seed_training_programs 3, user_admin.current_team

      # PacifiCorp Training Program Demo
      TrainingProgram.create!(
        name: "(DEMO) PacifiCorp Safety Training",
        team: user_admin.current_team
      )

      seed_mmoser_training_program(user_admin.current_team)

    # rescue Exception => e
    #   puts "An error occurred while seeding the training programs: #{e.message} \n#{e.to_json} \n#{e.inspect}"
    #   backtrace = e.backtrace
    #   exception_line = backtrace.first.split(":").last.to_i
    #   puts "Exception occurred at line #{exception_line}"
    # ensure
    #   # Ensure database connections are closed regardless of the outcome
    #   # Doesn't seem to be working.
    #   ActiveRecord::Base.clear_active_connections!
    # end
  end

  private

  # user_admin = create_user_and_team(
  #  "jcsarda+admin@gmail.com",
  #  "Dev Team",
  #  "dev",
  #  [Role.admin.id]
  # )
  def create_user_and_team(user_email, team_name, team_slug, role_ids)
      # Create a team for administrators
      u = User.find_by(email: user_email)


      u = User.create!(
        email: user_email,
        password: "TTSPW123!!!",
        # first_name: Faker::Name.first_name,
        # last_name: Faker::Name.last_name,
        first_name: "FirstName",
        last_name: "LastName",
        time_zone: ActiveSupport::TimeZone.all.first.name,
        locale: "en"
      ) if u.blank?

      u.update(
        time_zone: ActiveSupport::TimeZone.all.first.name,
        locale: "en"
        # sign_in_count { 1 }
        # current_sign_in_at { Time.now }
        # last_sign_in_at { 1.day.ago }
        # current_sign_in_ip { "127.0.0.1" }
        # last_sign_in_ip { "127.0.0.2" }
      )

      team = u.teams.create(
        name: team_name,
        slug: team_slug,
        time_zone: ActiveSupport::TimeZone.all.first.name,
        locale: "en"
      )

      # debugger

      u.memberships
        .find_by(team: team)
        .update(role_ids: role_ids)

      # debugger

      u.update(current_team: team)
      # debugger

      u
  end

  def seed_mmoser_training_program(team)
    training_program = TrainingProgram.create!(
      name: "M. Moser Worksite Safety Training",
      team: team
    )

    sections = [
      {
        title: "Site Security and Personal Identification",
        body: "All employees and visitors must sign in and sign out through Site Security, wear their M-MOSA ID at all times and attend a Site Safety Induction Brief.",
        questions: [
          {
            title: "What are the requirements for site access?",
            body: "Select all that apply:",
            answers: [
              { text: "Sign in and out through Site Security", correct: true },
              { text: "Wear M-MOSA ID at all times", correct: true },
              { text: "Attend Site Safety Induction Brief", correct: true },
              { text: "Bring your own safety equipment", correct: false }
            ]
          }
        ]
      },
      {
        title: "Personal Protective Equipment (PPE)",
        body: "Your Personal Protective Equipment can protect you from workplace hazards. PPE includes safety boots, long pants and shirt, high visibility vest, Helmet with chin strap, Safety glasses and gloves.",
        questions: [
          {
            title: "Which of the following is NOT part of the required PPE?",
            body: "Choose the correct answer:",
            answers: [
              { text: "Safety boots", correct: false },
              { text: "High visibility vest", correct: false },
              { text: "Helmet with chin strap", correct: false },
              { text: "Steel-toed sandals", correct: true }
            ]
          }
        ]
      },
      {
        title: "Safety Zones",
        body: "All M-MOSA worksites are designated with red and green zones. Full PPE must be worn at all times in the red zone areas, designated as a live construction site, but is optional in green zone areas designated as meeting areas and logistics spaces.",
        questions: [
          {
            title: "When is full PPE required?",
            body: "Select the correct statement:",
            answers: [
              { text: "Only in green zones", correct: false },
              { text: "At all times in red zones", correct: true },
              { text: "Never in green zones", correct: false },
              { text: "Only during working hours", correct: false }
            ]
          }
        ]
      }
    ]

    sections.each do |section|
      training_content = TrainingContent.create!(
        title: section[:title],
        body: section[:body],
        training_program: training_program
      )

      section[:questions].each do |question|
        good_answers = []
        bad_answers = []

        question[:answers].each do |answer|
          if answer[:correct]
            good_answers << answer[:text]
          else
            bad_answers << answer[:text]
          end
        end

        training_question = TrainingQuestion.create!(
          title: question[:title],
          body: question[:body],
          training_content: training_content,
          good_answers: good_answers.to_json,
          bad_answers: bad_answers.to_json
        )
      end
    end

    puts "🌱 Generated M. Moser Worksite Safety Training Program. \n #{training_program.inspect}"
  end

  # TODO: Get the iframe or some other version of the video showing in the content.
  def seed_training_programs(count, team)
    count.times do |i|
      training_program = TrainingProgram.create!(
        name: "SEEDED #{i + 1}",
        team: team
      )

      iframeVideoSample = <<~EOF
        <iframe
          src="https://player.cloudinary.com/embed/?public_id=b58fc7aae3f4ea3adb902c2b1c36c7fe_mchucq&cloud_name=dp96vkvin&player[showLogo]=false&player[fontFace]=Fira%20Sans&source[textTracks][subtitles][0][label]=Transcript&source[textTracks][subtitles][0][language]=en&source[textTracks][subtitles][0][default]=true"
          width="640"
          height="360"
          allow="autoplay; fullscreen; encrypted-media; picture-in-picture"
          undefined
          allowfullscreen
          frameborder="0"
        ></iframe>
      EOF

      # Loop to create 3 training contents
      3.times do |j|
        training_content = TrainingContent.create!(
          title: "Sample Content #{j + 1}",
          body: "Body of sample content #{j + 1}\n\n#{iframeVideoSample}",
          training_program: training_program
        )

        3.times do |k|
          TrainingQuestion.create!(
            title: "Sample Question #{k + 1}",
            body: "Body of sample question #{k + 1}",
            training_content: training_content
          )
        end
      end

      puts "🌱 Generted TrainingProgram. \n #{training_program.inspect}"
    end
  end
end
