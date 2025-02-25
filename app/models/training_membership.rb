class TrainingMembership < ApplicationRecord
  belongs_to :membership
  belongs_to :training_program
  has_one :user, through: :membership

  validates :status, presence: true, inclusion: { in: %w[active completed suspended] }
  validates :membership_id, uniqueness: { scope: :training_program_id }
  validates :current_progress, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }

  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :in_progress, -> { where(status: 'active').where('current_progress > ?', 0) }

  def complete!
    update!(
      status: 'completed',
      current_progress: 100,
      completed_at: Time.current
    )
  end

  def active?
    status == 'active'
  end

  def completed?
    status == 'completed'
  end

  def suspended?
    status == 'suspended'
  end
end
