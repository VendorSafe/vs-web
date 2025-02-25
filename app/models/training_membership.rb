class TrainingMembership < ApplicationRecord
  belongs_to :membership
  belongs_to :training_program
  has_one :user, through: :membership

  belongs_to :current_content, class_name: 'TrainingContent', optional: true
  belongs_to :last_completed_content, class_name: 'TrainingContent', optional: true

  validates :membership_id, uniqueness: { scope: :training_program_id }
  validates :completion_percentage, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }

  scope :completed, -> { where.not(completed_at: nil) }
  scope :in_progress, -> { where(completed_at: nil).where('completion_percentage > ?', 0) }
  scope :not_started, -> { where(completed_at: nil, completion_percentage: 0) }

  def complete!
    update!(
      completion_percentage: 100,
      completed_at: Time.current
    )
  end

  def active?
    completed_at.nil?
  end

  def completed?
    !completed_at.nil?
  end

  def progress_for(content_id)
    progress&.dig(content_id.to_s) || 0
  end

  def mark_content_accessed(content_id)
    history = content_access_history || {}
    history[content_id.to_s] = Time.current.iso8601
    update(content_access_history: history)
  end

  def mark_content_completed(content_id)
    prog = progress || {}
    prog[content_id.to_s] = 100
    update(
      progress: prog,
      last_completed_content_id: content_id
    )
    recalculate_completion_percentage
  end

  def recalculate_completion_percentage
    return 0 if training_program.training_contents.empty?

    completed_count = (progress || {}).count { |_, value| value.to_i >= 100 }
    required_count = training_program.training_contents.where(is_required: true).count

    percentage = required_count > 0 ? (completed_count.to_f / required_count * 100).to_i : 0
    update(completion_percentage: percentage)

    complete! if percentage >= 100

    percentage
  end
end
