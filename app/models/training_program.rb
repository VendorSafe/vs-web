class TrainingProgram < ApplicationRecord
  include PublicActivity::Model
  tracked owner: :team

  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :team
  belongs_to :pricing_model, optional: true
  # 🚅 add belongs_to associations above.

  has_many :training_contents, dependent: :destroy
  has_many :training_memberships, dependent: :destroy
  has_many :memberships, through: :training_memberships
  # 🚅 add has_many associations above.

  has_rich_text :description
  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :name, presence: true
  validates :pricing_model, scope: true
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # Returns valid pricing models for this training program
  # Ensures pricing models belong to the same team
  def valid_pricing_models
    team.pricing_models
  end

  # 🚅 add methods above.
end
