class Location < ApplicationRecord
  include Sortable
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :team
  belongs_to :parent, class_name: "Location", optional: true
  # 🚅 add belongs_to associations above.

  has_many :children, class_name: "Location", foreign_key: "parent_id", dependent: :nullify
  # 🚅 add has_many associations above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :name, presence: true
  validates :parent, scope: true
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

  # 🚅 add methods above.
end
