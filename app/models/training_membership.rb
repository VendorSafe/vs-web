class TrainingMembership < ApplicationRecord
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :training_program
  belongs_to :membership
  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :membership, scope: true
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def valid_memberships
    training_program.valid_memberships
  end

  # 🚅 add methods above.
end
