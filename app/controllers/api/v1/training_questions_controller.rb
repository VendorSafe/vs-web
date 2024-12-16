# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::TrainingQuestionsController < Api::V1::ApplicationController
    account_load_and_authorize_resource :training_question, through: :training_content, through_association: :training_questions

    # GET /api/v1/training_contents/:training_content_id/training_questions
    def index
    end

    # GET /api/v1/training_questions/:id
    def show
    end

    # POST /api/v1/training_contents/:training_content_id/training_questions
    def create
      if @training_question.save
        render :show, status: :created, location: [:api, :v1, @training_question]
      else
        render json: @training_question.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/training_questions/:id
    def update
      if @training_question.update(training_question_params)
        render :show
      else
        render json: @training_question.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/training_questions/:id
    def destroy
      @training_question.destroy
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def training_question_params
        strong_params = params.require(:training_question).permit(
          *permitted_fields,
          :title,
          :body,
          :good_answers,
          :bad_answers,
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
  class Api::V1::TrainingQuestionsController
  end
end
