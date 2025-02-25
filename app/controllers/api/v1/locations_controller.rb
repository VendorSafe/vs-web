module Api
  module V1
    class LocationsController < Api::V1::ApplicationController
      account_load_and_authorize_resource :location, through: :team, through_association: :locations

      # GET /api/v1/teams/:team_id/locations
      def index
        # Filter by geometry type if specified
        @locations = @locations.with_geometry_type(params[:geometry_type]) if params[:geometry_type].present?

        render json: @locations
      end

      # GET /api/v1/teams/:team_id/locations/near
      def near
        # Find locations near a point
        @locations = @team.locations.near_geometry(
          params[:lat].to_f,
          params[:lng].to_f,
          params[:radius].to_f
        )

        render json: @locations
      end

      # GET /api/v1/locations/:id
      def show
        render json: @location
      end

      # POST /api/v1/teams/:team_id/locations
      def create
        @location = @team.locations.build(location_params)

        if @location.save
          render json: @location, status: :created
        else
          render json: { errors: @location.errors }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/locations/:id
      def update
        if @location.update(location_params)
          render json: @location
        else
          render json: { errors: @location.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/locations/:id
      def destroy
        @location.destroy
        head :ok
      end

      # GET /api/v1/locations/:id/children
      def children
        @children = @location.children
        render json: @children
      end

      private

      def location_params
        params.require(:location).permit(
          :name,
          :location_type,
          :address,
          :parent_id,
          geometry: {}
        )
      end
    end
  end
end
