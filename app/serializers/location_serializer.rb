class LocationSerializer < ApplicationSerializer
  attributes :id, :name, :location_type, :address, :geometry, :parent_id, :team_id, :created_at, :updated_at

  attribute :full_path do |location|
    location.full_path
  end

  attribute :has_children do |location|
    location.children.exists?
  end

  attribute :children_count do |location|
    location.children.count
  end

  attribute :parent_name do |location|
    location.parent&.name
  end

  # Include GeoJSON type for easier filtering on the client side
  attribute :geometry_type do |location|
    location.geometry&.dig('type')
  end
end
