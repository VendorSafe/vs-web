# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::TrainingQuestionsController < Api::V1::ApplicationController
    account_load_and_authorize_resource :training_question, through: :training_content,
                                                            through_association: :training_questions

    # GET /api/v1/training_contents/:training_content_id/training_questions
    def index
      # Ensure the training content is loaded
      unless @training_content
        render json: { error: 'Training content not found' }, status: :not_found
        return
      end

      render json: @training_questions
    end

    # GET /api/v1/training_questions/:id
    def show
      # Ensure the training question is loaded
      unless @training_question
        render json: { error: 'Training question not found' }, status: :not_found
        return
      end

      render json: @training_question
    end

    # POST /api/v1/training_contents/:training_content_id/training_questions
    def create
      # Ensure the training content is loaded
      unless @training_content
        render json: { error: 'Training content not found' }, status: :not_found
        return
      end

      # Create a new training question
      @training_question = @training_content.training_questions.build(training_question_params)

      if @training_question.save
        render json: @training_question, status: :created
      else
        render json: { errors: @training_question.errors }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/training_questions/:id
    def update
      # Ensure the training question is loaded
      unless @training_question
        render json: { error: 'Training question not found' }, status: :not_found
        return
      end

      if @training_question.update(training_question_params)
        render json: @training_question
      else
        render json: { errors: @training_question.errors }, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/training_questions/:id
    def destroy
      # Ensure the training question is loaded
      unless @training_question
        render json: { error: 'Training question not found' }, status: :not_found
        return
      end

      @training_question.destroy
      head :ok
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def training_question_params
        strong_params = params.require(:training_question).permit(
          *permitted_fields,
          :title,
          :good_answers,
          :bad_answers,
          :published_at,
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
  class Api::V1::TrainingQuestionsController
  end
end
