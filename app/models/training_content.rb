class TrainingContent < ApplicationRecord
  include Sortable
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :training_program
  # 🚅 add belongs_to associations above.

  has_many :training_questions, dependent: :destroy
  # 🚅 add has_many associations above.

  has_one :team, through: :training_program
  has_rich_text :body
  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :title, presence: true
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def collection
    training_program.training_contents
  end

  # 🚅 add methods above.
end
