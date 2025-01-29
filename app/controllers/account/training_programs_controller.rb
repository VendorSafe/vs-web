class Account::TrainingProgramsController < Account::ApplicationController
  # Add authentication and authorization checks
  before_action :authenticate_user!
  before_action :set_training_program
  before_action :check_training_program_access

  # GET /account/training_programs/:id
  def show
    # The @training_program is already set by the before_action
  end

  # POST /account/training_programs/:id/start
  def start
    @training_program.start!
    redirect_to account_training_program_path(@training_program), notice: "Training program has been started."
  end

  # POST /account/training_programs/:id/stop
  def stop
    @training_program.stop!
    redirect_to account_training_program_path(@training_program), notice: "Training program has been stopped."
  end

  private

  def set_training_program
    @training_program = TrainingProgram.find(params[:id])
  end

  def check_training_program_access
    unless current_user.role_in?(['employee', 'vendor']) &&
           current_user.memberships.joins(:training_memberships)
                      .where(training_memberships: { training_program: @training_program })
                      .exists?
      redirect_to root_path, alert: "You don't have access to this training program."
    end
  end
end
