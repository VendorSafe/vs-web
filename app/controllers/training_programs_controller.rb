class TrainingProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_training_program, only: [:show, :update_progress]
  before_action :set_training_membership, only: [:show, :update_progress]

  def show
    authorize! @training_program

    render json: {
      id: @training_program.id,
      title: @training_program.name,
      description: @training_program.description,
      modules: training_modules_json,
      progress: {
        completedModules: @training_membership.progress["completed_modules"] || [],
        currentPosition: @training_membership.progress["current_position"] || 0,
        totalTime: @training_membership.progress["total_time"] || 0,
        completionPercentage: @training_membership.completion_percentage
      }
    }
  end

  def update_progress
    authorize! @training_program

    if @training_membership.update(progress_params)
      # Check if all modules are complete
      if progress_params[:completion_percentage] == 100
        @training_membership.complete!

        # Generate certificate if eligible
        if @training_program.can_generate_certificate?(@training_membership.membership)
          certificate = @training_program.generate_certificate(@training_membership.membership)

          render json: {
            status: "complete",
            message: "Training completed successfully!",
            certificate_url: certificate.verification_url
          }
          return
        end
      end

      render json: {status: "success", progress: @training_membership.progress}
    else
      render json: {
        status: "error",
        errors: @training_membership.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_training_program
    @training_program = TrainingProgram.find(params[:id])
  end

  def set_training_membership
    @training_membership = current_user.training_memberships.find_or_create_by(
      training_program: @training_program
    )
  end

  def progress_params
    params.require(:progress).permit(
      :completion_percentage,
      progress: [
        :current_position,
        :total_time,
        {completed_modules: []}
      ]
    )
  end

  def training_modules_json
    @training_program.training_contents.order(:sort_order).map do |content|
      {
        id: content.id,
        title: content.title,
        type: content.content_type,
        body: content.body,
        sort_order: content.sort_order,
        questions: questions_json(content),
        media_url: (content.content_type == "video") ? url_for(content.video) : nil,
        completed: @training_membership.progress["completed_modules"]&.include?(content.id)
      }
    end
  end

  def questions_json(content)
    return [] unless content.content_type == "quiz"

    content.training_questions.map do |question|
      {
        id: question.id,
        title: question.title,
        body: question.body,
        type: question.question_type,
        options: question.options,
        correctOption: question.correct_option,
        correctAnswer: question.correct_answer,
        passingScore: question.passing_score
      }
    end
  end
end
