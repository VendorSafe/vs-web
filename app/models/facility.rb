class Facility < ApplicationRecord
  include Sortable
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :team
  belongs_to :membership, optional: true
  # 🚅 add belongs_to associations above.

  has_many :facility_location_mappings, dependent: :destroy
  has_many :locations, through: :facility_location_mappings
  # 🚅 add has_many associations above.

  # 🚅 add has_one associations above.

  # Deprecated facilities that have been migrated to locations
  scope :migrated, -> { where.not(migrated_to_location_id: nil) }

  # Facilities that haven't been migrated yet
  scope :not_migrated, -> { where(migrated_to_location_id: nil) }
  # 🚅 add scopes above.

  validates :name, presence: true
  validates :membership, scope: true
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def collection
    team.facilities
  end

  def valid_memberships
    team.memberships
    # please specify what objects should be considered valid for assigning to `membership`.
    # the resulting code should probably look something like `team.memberships`.
  end

  # Get the corresponding location if this facility has been migrated
  def migrated_location
    return nil unless migrated_to_location_id

    Location.find_by(id: migrated_to_location_id)
  end

  # Check if this facility has been migrated to a location
  def migrated?
    migrated_to_location_id.present?
  end

  # Migrate this facility to a location
  # If a location is provided, it will be used
  # Otherwise, a new location will be created
  def migrate_to_location(location = nil)
    return migrated_location if migrated?

    ActiveRecord::Base.transaction do
      # Create a new location if one wasn't provided
      location ||= Location.create!(
        team: team,
        name: name,
        location_type: other_attribute,
        address: url
      )

      # Create the mapping
      FacilityLocationMapping.create!(
        facility: self,
        location: location
      )

      # Update the facility to mark it as migrated
      update!(migrated_to_location_id: location.id)

      location
    end
  end

  # 🚅 add methods above.
end
