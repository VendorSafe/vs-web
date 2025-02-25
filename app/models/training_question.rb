class TrainingQuestion < ApplicationRecord
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.
  attribute :options, :json, default: -> { {} }

  belongs_to :training_content
  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  has_one :team, through: :training_content
  has_rich_text :body
  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :title, presence: true
  validates :question_type, presence: true, inclusion: { in: %w[multiple_choice true_false short_answer] }
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # 🚅 add methods above.
end
