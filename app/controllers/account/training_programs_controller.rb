class Account::TrainingProgramsController < Account::ApplicationController
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

  private

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    assign_date_and_time(strong_params, :published_at)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
