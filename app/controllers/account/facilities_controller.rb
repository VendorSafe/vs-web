class Account::FacilitiesController < Account::ApplicationController
  include SortableActions
  account_load_and_authorize_resource :facility, through: :team, through_association: :facilities

  # GET /account/teams/:team_id/facilities
  # GET /account/teams/:team_id/facilities.json
  def index
    delegate_json_to_api
  end

  # GET /account/facilities/:id
  # GET /account/facilities/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/facilities/new
  def new
  end

  # GET /account/facilities/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/facilities
  # POST /account/teams/:team_id/facilities.json
  def create
    respond_to do |format|
      if @facility.save
        format.html { redirect_to [:account, @facility], notice: I18n.t("facilities.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @facility] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @facility.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/facilities/:id
  # PATCH/PUT /account/facilities/:id.json
  def update
    respond_to do |format|
      if @facility.update(facility_params)
        format.html { redirect_to [:account, @facility], notice: I18n.t("facilities.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @facility] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @facility.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/facilities/:id
  # DELETE /account/facilities/:id.json
  def destroy
    @facility.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :facilities], notice: I18n.t("facilities.notifications.destroyed") }
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
