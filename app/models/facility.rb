class Facility < ApplicationRecord
  include Sortable
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :team
  belongs_to :membership, optional: true
  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add has_one associations above.

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

  # 🚅 add methods above.
end
