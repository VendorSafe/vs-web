class FacilityLocationMapping < ApplicationRecord
  belongs_to :facility
  belongs_to :location

  validates :facility_id, uniqueness: { scope: :location_id }

  # Ensure the facility and location belong to the same team
  validate :validate_same_team

  private

  def validate_same_team
    return unless facility&.team_id != location&.team_id

    errors.add(:base, 'Facility and Location must belong to the same team')
  end
end
