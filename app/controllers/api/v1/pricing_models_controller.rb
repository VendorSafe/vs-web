# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::PricingModelsController < Api::V1::ApplicationController
    account_load_and_authorize_resource :pricing_model, through: :team, through_association: :pricing_models

    # GET /api/v1/teams/:team_id/pricing_models
    def index
    end

    # GET /api/v1/pricing_models/:id
    def show
    end

    # POST /api/v1/teams/:team_id/pricing_models
    def create
      if @pricing_model.save
        render :show, status: :created, location: [:api, :v1, @pricing_model]
      else
        render json: @pricing_model.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/pricing_models/:id
    def update
      if @pricing_model.update(pricing_model_params)
        render :show
      else
        render json: @pricing_model.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/pricing_models/:id
    def destroy
      @pricing_model.destroy
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def pricing_model_params
        strong_params = params.require(:pricing_model).permit(
          *permitted_fields,
          :name,
          :price_type,
          :base_price,
          :volume_discount,
          :description,
          # 🚅 super scaffolding will insert new fields above this line.
          *permitted_arrays,
          # 🚅 super scaffolding will insert new arrays above this line.
        )

        process_params(strong_params)

        strong_params
      end
    end

    include StrongParameters
  end
else
  class Api::V1::PricingModelsController
  end
end
