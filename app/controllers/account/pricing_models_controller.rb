class Account::PricingModelsController < Account::ApplicationController
  account_load_and_authorize_resource :pricing_model, through: :team, through_association: :pricing_models

  # GET /account/teams/:team_id/pricing_models
  # GET /account/teams/:team_id/pricing_models.json
  def index
    delegate_json_to_api
  end

  # GET /account/pricing_models/:id
  # GET /account/pricing_models/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/pricing_models/new
  def new
  end

  # GET /account/pricing_models/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/pricing_models
  # POST /account/teams/:team_id/pricing_models.json
  def create
    respond_to do |format|
      if @pricing_model.save
        format.html { redirect_to [:account, @pricing_model], notice: I18n.t("pricing_models.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @pricing_model] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pricing_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/pricing_models/:id
  # PATCH/PUT /account/pricing_models/:id.json
  def update
    respond_to do |format|
      if @pricing_model.update(pricing_model_params)
        format.html { redirect_to [:account, @pricing_model], notice: I18n.t("pricing_models.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @pricing_model] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pricing_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/pricing_models/:id
  # DELETE /account/pricing_models/:id.json
  def destroy
    @pricing_model.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :pricing_models], notice: I18n.t("pricing_models.notifications.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
