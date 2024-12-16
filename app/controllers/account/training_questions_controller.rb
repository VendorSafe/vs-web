class Account::TrainingQuestionsController < Account::ApplicationController
  account_load_and_authorize_resource :training_question, through: :training_content, through_association: :training_questions

  # GET /account/training_contents/:training_content_id/training_questions
  # GET /account/training_contents/:training_content_id/training_questions.json
  def index
    delegate_json_to_api
  end

  # GET /account/training_questions/:id
  # GET /account/training_questions/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/training_contents/:training_content_id/training_questions/new
  def new
  end

  # GET /account/training_questions/:id/edit
  def edit
  end

  # POST /account/training_contents/:training_content_id/training_questions
  # POST /account/training_contents/:training_content_id/training_questions.json
  def create
    respond_to do |format|
      if @training_question.save
        format.html { redirect_to [:account, @training_question], notice: I18n.t("training_questions.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @training_question] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @training_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/training_questions/:id
  # PATCH/PUT /account/training_questions/:id.json
  def update
    respond_to do |format|
      if @training_question.update(training_question_params)
        format.html { redirect_to [:account, @training_question], notice: I18n.t("training_questions.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @training_question] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @training_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/training_questions/:id
  # DELETE /account/training_questions/:id.json
  def destroy
    @training_question.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @training_content, :training_questions], notice: I18n.t("training_questions.notifications.destroyed") }
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
