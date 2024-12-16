class Account::TrainingContentsController < Account::ApplicationController
  include SortableActions
  account_load_and_authorize_resource :training_content, through: :training_program, through_association: :training_contents

  # GET /account/training_programs/:training_program_id/training_contents
  # GET /account/training_programs/:training_program_id/training_contents.json
  def index
    delegate_json_to_api
  end

  # GET /account/training_contents/:id
  # GET /account/training_contents/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/training_programs/:training_program_id/training_contents/new
  def new
  end

  # GET /account/training_contents/:id/edit
  def edit
  end

  # POST /account/training_programs/:training_program_id/training_contents
  # POST /account/training_programs/:training_program_id/training_contents.json
  def create
    respond_to do |format|
      if @training_content.save
        format.html { redirect_to [:account, @training_content], notice: I18n.t("training_contents.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @training_content] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @training_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/training_contents/:id
  # PATCH/PUT /account/training_contents/:id.json
  def update
    respond_to do |format|
      if @training_content.update(training_content_params)
        format.html { redirect_to [:account, @training_content], notice: I18n.t("training_contents.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @training_content] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @training_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/training_contents/:id
  # DELETE /account/training_contents/:id.json
  def destroy
    @training_content.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @training_program, :training_contents], notice: I18n.t("training_contents.notifications.destroyed") }
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
