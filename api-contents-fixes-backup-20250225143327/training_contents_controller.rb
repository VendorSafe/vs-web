# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::TrainingContentsController < Api::V1::ApplicationController
    account_load_and_authorize_resource :training_content, through: :training_program, through_association: :training_contents

    # GET /api/v1/training_programs/:training_program_id/training_contents
    def index
    end

    # GET /api/v1/training_contents/:id
    def show
    end

    # POST /api/v1/training_programs/:training_program_id/training_contents
    def create
      if @training_content.save
        render :show, status: :created, location: [:api, :v1, @training_content]
      else
        render json: @training_content.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/training_contents/:id
    def update
      if @training_content.update(training_content_params)
        render :show
      else
        render json: @training_content.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/training_contents/:id
    def destroy
      @training_content.destroy
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def training_content_params
        strong_params = params.require(:training_content).permit(
          *permitted_fields,
          :title,
          :body,
          :content_type,
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
  class Api::V1::TrainingContentsController
  end
end
