class Account::TrainingProgramsController < Account::ApplicationController
  # Add authentication and authorization checks
  before_action :authenticate_user!
  before_action :set_training_program
  before_action :check_training_program_access

  account_load_and_authorize_resource :training_program, through: :team, through_association: :training_programs

  # GET /account/teams/:team_id/training_programs
  # GET /account/teams/:team_id/training_programs.json
  def index
    delegate_json_to_api
  end

  # GET /account/training_programs/:id
  # GET /account/training_programs/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/training_programs/new
  def new
  end

  # GET /account/training_programs/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/training_programs
  # POST /account/teams/:team_id/training_programs.json
  def create
    respond_to do |format|
      if @training_program.save
        format.html { redirect_to [:account, @training_program], notice: I18n.t("training_programs.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @training_program] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @training_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/training_programs/:id
  # PATCH/PUT /account/training_programs/:id.json
  def update
    respond_to do |format|
      if @training_program.update(training_program_params)
        format.html { redirect_to [:account, @training_program], notice: I18n.t("training_programs.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @training_program] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @training_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/training_programs/:id
  # DELETE /account/training_programs/:id.json
  def destroy
    @training_program.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :training_programs], notice: I18n.t("training_programs.notifications.destroyed") }
      format.json { head :no_content }
    end
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
