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

  # Progress tracking methods
  def update_progress(content_id, status, time_spent = 0)
    progress_data = progress || {}
    progress_data[content_id.to_s] = {
      "status" => status,
      "time_spent" => time_spent,
      "updated_at" => Time.current
    }

    update(
      progress: progress_data,
      completion_percentage: calculate_completion_percentage
    )

    mark_as_completed if completed?
  end

  def content_progress(content_id)
    (progress || {})[content_id.to_s] || {"status" => "not_started", "time_spent" => 0}
  end

  def content_completed?(content_id)
    content_progress(content_id)["status"] == "completed"
  end

  def calculate_completion_percentage
    return 0 if training_program.training_contents.empty?

    completed_count = progress.to_h.count { |_, data| data["status"] == "completed" }
    ((completed_count.to_f / training_program.training_contents.count) * 100).round
  end

  def completed?
    completion_percentage >= (training_program.passing_percentage || 100)
  end

  private

  def mark_as_completed
    update_column(:completed_at, Time.current) unless completed_at
  end

  # 🚅 add methods above.
end
