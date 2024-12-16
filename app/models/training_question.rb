class TrainingQuestion < ApplicationRecord
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :training_content
  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  has_one :team, through: :training_content
  has_rich_text :body
  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :title, presence: true
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # 🚅 add methods above.
end
