class Location < ApplicationRecord
  include Sortable
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :team
  belongs_to :parent, class_name: 'Location', optional: true
  # 🚅 add belongs_to associations above.

  has_many :children, class_name: 'Location', foreign_key: 'parent_id', dependent: :nullify
  has_many :facility_location_mappings, dependent: :destroy
  has_many :facilities, through: :facility_location_mappings
  # 🚅 add has_many associations above.

  # 🚅 add has_one associations above.

  # Find locations within a radius of a point
  scope :near, lambda { |lat, lng, radius_km|
    # This is a placeholder for PostGIS implementation
    # Will be implemented when PostGIS is fully configured
    where('1=1') # Returns all locations for now
  }

  # Find locations by type
  scope :of_type, ->(type) { where(location_type: type) }

  # Find top-level locations (no parent)
  scope :top_level, -> { where(parent_id: nil) }
  # 🚅 add scopes above.

  validates :name, presence: true
  validates :parent, scope: true
  validate :validate_geometry_format, if: -> { geometry.present? }
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def collection
    team.locations
  end

  # Returns valid parent locations for this location
  # Prevents circular references and ensures same team ownership
  def valid_parents
    # Get all locations from same team except self and descendants
    base_scope = team.locations.where.not(id: id)

    if persisted?
      # When editing existing location, also exclude its descendants
      descendant_ids = Location.where(parent_id: id).pluck(:id)
      base_scope = base_scope.where.not(id: descendant_ids)
    end

    base_scope
  end

  # Convert to GeoJSON Feature
  def to_geojson
    return nil if geometry.blank?

    {
      type: 'Feature',
      geometry: geometry,
      properties: {
        id: id,
        name: name,
        location_type: location_type,
        address: address
      }
    }
  end

  # Get all ancestors in order from root to parent
  def ancestors
    result = []
    current = parent

    while current
      result.unshift(current)
      current = current.parent
    end

    result
  end

  # Get all descendants (children, grandchildren, etc.)
  def descendants
    result = []
    queue = children.to_a

    until queue.empty?
      current = queue.shift
      result << current
      queue.concat(current.children.to_a)
    end

    result
  end

  # Check if this location contains the given point
  def contains_point?(lat, lng)
    return false if geometry.blank?

    # This is a placeholder for actual geometric calculation
    # Will be implemented with PostGIS or a Ruby geometry library
    false
  end

  # Get full hierarchical path (e.g., "Headquarters > Floor 1 > Room 101")
  def full_path
    (ancestors.map(&:name) + [name]).join(' > ')
  end

  private

  # GeoJSON schema for validation
  def self.GEOJSON_SCHEMA
    {
      type: 'object',
      required: %w[type coordinates],
      properties: {
        type: {
          type: 'string',
          enum: %w[Point LineString Polygon MultiPoint MultiLineString MultiPolygon]
        },
        coordinates: { type: 'array' }
      }
    }
  end

  # Validate GeoJSON format
  def validate_geometry_format
    return if geometry.blank?

    unless geometry.is_a?(Hash) &&
           geometry['type'].present? &&
           geometry['coordinates'].present? &&
           %w[Point LineString Polygon MultiPoint MultiLineString
              MultiPolygon].include?(geometry['type'])
      errors.add(:geometry, 'must be valid GeoJSON with type and coordinates')
    end
  end
  # 🚅 add methods above.
end
