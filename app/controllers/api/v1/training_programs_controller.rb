# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::TrainingProgramsController < Api::V1::ApplicationController
    account_load_and_authorize_resource :training_program, through: :team, through_association: :training_programs

    # GET /api/v1/teams/:team_id/training_programs
    def index
    end

    # GET /api/v1/training_programs/:id
    def show
      membership = current_user.memberships.find_by(team: @training_program.team)
      training_membership = if membership
                              TrainingMembership.find_by(membership: membership,
                                                         training_program: @training_program)
                            else
                              nil
                            end
      progress_data = training_membership&.progress || {}
      render json: @training_program.as_json(
        include: [:training_contents, { training_contents: [:training_questions] }]
      ).merge(progress: progress_data)
    end

    # PUT /api/v1/training_programs/:id/update_progress
    def update_progress
      membership = current_user.memberships.find_by(team: @training_program.team)
      training_membership = if membership
                              TrainingMembership.find_by(membership: membership,
                                                         training_program: @training_program)
                            else
                              nil
                            end
      if training_membership
        training_membership.update(progress: params[:progress])
        head :ok
      else
        render json: { error: 'Training membership not found' }, status: :not_found
      end
    end

    # GET /api/v1/training_programs/:id/certificate
    def certificate
      membership = current_user.memberships.find_by(team: @training_program.team)

      if membership
        certificate = TrainingCertificate.find_by(
          training_program: @training_program,
          membership: membership
        )

        if certificate
          render json: certificate
        else
          render json: { error: 'Certificate not found' }, status: :not_found
        end
      else
        render json: { error: 'Membership not found' }, status: :not_found
      end
    end

    # POST /api/v1/training_programs/:id/generate_certificate
    def generate_certificate
      membership = current_user.memberships.find_by(team: @training_program.team)
      training_membership = if membership
                              TrainingMembership.find_by(membership: membership,
                                                         training_program: @training_program)
                            else
                              nil
                            end

      # Check if training is complete
      if training_membership.nil? || !training_membership_complete?(training_membership)
        render json: { error: 'Training program not completed' }, status: :unprocessable_entity
        return
      end

      # Check if certificate already exists
      existing_certificate = TrainingCertificate.find_by(
        training_program: @training_program,
        membership: membership
      )

      if existing_certificate
        render json: existing_certificate
        return
      end

      # Create new certificate
      certificate = TrainingCertificate.new(
        training_program: @training_program,
        membership: membership,
        issued_at: Time.current,
        expires_at: 1.year.from_now, # Default expiration of 1 year
        score: calculate_score(training_membership)
      )

      if certificate.save
        # Generate PDF asynchronously
        certificate.generate_pdf!
        render json: certificate
      else
        render json: { error: certificate.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end

    # POST /api/v1/teams/:team_id/training_programs
    def create
      if @training_program.save
        render :show, status: :created, location: [:api, :v1, @training_program]
      else
        render json: @training_program.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/training_programs/:id
    def update
      if @training_program.update(training_program_params)
        render :show
      else
        render json: @training_program.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/training_programs/:id
    def destroy
      @training_program.destroy
    end

    private

    # Add update_progress, certificate, and generate_certificate to the list of authorized actions
    def self.permitted_actions
      super + %i[update_progress certificate generate_certificate]
    end

    # Check if a training membership has completed all content
    def training_membership_complete?(training_membership)
      return false unless training_membership

      progress = training_membership.progress || {}
      total_contents = @training_program.training_contents.count

      return false if total_contents == 0

      completed_contents = progress.values.count { |p| p['completed'] }
      completed_contents == total_contents
    end

    # Calculate score based on quiz results in progress data
    def calculate_score(training_membership)
      return nil unless training_membership

      progress = training_membership.progress || {}
      quiz_contents = @training_program.training_contents.where('training_questions_count > 0')

      return nil if quiz_contents.empty?

      total_questions = 0
      correct_answers = 0

      quiz_contents.each do |content|
        content_progress = progress[content.id.to_s]
        next unless content_progress

        if content_progress['quiz_results']
          total_questions += content_progress['quiz_results']['total'] || 0
          correct_answers += content_progress['quiz_results']['correct'] || 0
        end
      end

      return nil if total_questions == 0

      ((correct_answers.to_f / total_questions) * 100).round
    end

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def training_program_params
        strong_params = params.require(:training_program).permit(
          *permitted_fields,
          :name,
          :description,
          :status,
          :slides,
          :published_at,
          :pricing_model_id,
          # 🚅 super scaffolding will insert new fields above this line.
          *permitted_arrays
          # 🚅 super scaffolding will insert new arrays above this line.
        )

        process_params(strong_params)

        strong_params
      end
    end

    include StrongParameters
  end
else
  class Api::V1::TrainingProgramsController
  end
end
