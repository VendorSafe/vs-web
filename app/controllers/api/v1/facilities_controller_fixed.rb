# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::FacilitiesController < Api::V1::ApplicationController
    account_load_and_authorize_resource :facility, through: :team, through_association: :facilities

    # GET /api/v1/teams/:team_id/facilities
    def index
      # Ensure the team is loaded
      unless @team
        render json: { error: 'Team not found' }, status: :not_found
        return
      end

      render json: @facilities
    end

    # GET /api/v1/facilities/:id
    def show
      # Ensure the facility is loaded
      unless @facility
        render json: { error: 'Facility not found' }, status: :not_found
        return
      end

      render json: @facility
    end

    # POST /api/v1/teams/:team_id/facilities
    def create
      # Ensure the team is loaded
      unless @team
        render json: { error: 'Team not found' }, status: :not_found
        return
      end

      # Create a new facility
      @facility = @team.facilities.build(facility_params)

      if @facility.save
        render json: @facility, status: :created
      else
        render json: { errors: @facility.errors }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/facilities/:id
    def update
      # Ensure the facility is loaded
      unless @facility
        render json: { error: 'Facility not found' }, status: :not_found
        return
      end

      if @facility.update(facility_params)
        render json: @facility
      else
        render json: { errors: @facility.errors }, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/facilities/:id
    def destroy
      # Ensure the facility is loaded
      unless @facility
        render json: { error: 'Facility not found' }, status: :not_found
        return
      end

      @facility.destroy
      head :ok
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def facility_params
        strong_params = params.require(:facility).permit(
          *permitted_fields,
          :name,
          :other_attribute,
          :url,
          :membership_id,
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
  class Api::V1::FacilitiesController
  end
end
