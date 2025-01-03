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
          # 🚅 super scaffolding will insert new fields above this line.
          *permitted_arrays,
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
