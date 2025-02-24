class TrainingMembership < ApplicationRecord
  # 🚅 add concerns above.
  include Roles::Support
  include PublicActivity::Model
  tracked owner: :team

  roles_only :employee, :vendor, :customer

  # 🚅 add attribute accessors above.
  attr_accessor :role_ids

  belongs_to :training_program
  belongs_to :membership
  has_one :team, through: :membership
  # 🚅 add belongs_to associations above.

  # Scopes for team-based access
  scope :for_team, ->(team) { joins(:membership).where(memberships: {team_id: team.id}) }
  scope :active, -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }

  # 🚅 add has_many associations above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :membership, scope: true
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  after_create :set_initial_content
  before_save :update_dependencies_met

  # 🚅 add delegations above.

  delegate :training_contents, to: :training_program

  def valid_memberships
    training_program.valid_memberships
  end

  # Team-based access control
  def can_manage_team?
    membership.can?(:manage_team_access, training_program)
  end

  def can_view_team_progress?
    membership.can?(:manage_team_progress, training_program)
  end

  def team_members
    return [] unless can_manage_team?
    self.class.for_team(team).where.not(id: id)
  end

  def can_access_training?
    return true if membership.can?(:manage_training, training_program)
    return true if membership.can?(:manage_team_access, training_program)
    return true if membership.can?(:do_training, training_program) && training_program.published?
    false
  end

  # Sequential progression methods
  def next_available_content
    return first_content unless current_content
    return nil if completed?

    ordered_contents = training_contents.order(:position)
    current_index = ordered_contents.index(current_content)
    return nil unless current_index

    next_content = ordered_contents[current_index + 1]
    return nil unless next_content
    return next_content if can_access_content?(next_content)
    nil
  end

  def can_access_content?(content)
    return false unless content && can_access_training?

    # Admins and team managers can access any content
    return true if membership.can?(:manage_training, training_program)
    return true if membership.can?(:manage_team_access, training_program)

    # For regular participants, enforce sequential progression
    return true if content == first_content

    # Check if previous content is completed
    prev_content = previous_content(content)
    return false unless prev_content && content_completed?(prev_content.id)

    # Check dependencies
    dependencies = content.dependencies || []
    dependencies.all? { |dep_id| content_completed?(dep_id) }
  end

  def previous_content(content)
    ordered_contents = training_contents.order(:position)
    current_index = ordered_contents.index(content)
    return nil unless current_index && current_index > 0
    ordered_contents[current_index - 1]
  end

  def first_content
    @first_content ||= training_contents.order(:position).first
  end

  def current_content
    return nil unless current_content_id
    @current_content ||= training_contents.find_by(id: current_content_id)
  end

  def advance_to_next_content
    next_content = next_available_content
    return false unless next_content

    update(
      current_content_id: next_content.id,
      content_access_history: content_access_history.merge(
        next_content.id.to_s => {"first_accessed_at" => Time.current}
      )
    )
  end

  # Progress tracking methods
  def update_progress(content_id, status, time_spent = 0)
    return false unless can_access_training?
    content = training_contents.find_by(id: content_id)
    return false unless content && can_access_content?(content)

    progress_data = progress || {}
    progress_data[content_id.to_s] = {
      "status" => status,
      "time_spent" => time_spent,
      "updated_at" => Time.current
    }

    success = update(
      progress: progress_data,
      completion_percentage: calculate_completion_percentage,
      last_completed_content_id: ((status == "completed") ? content_id : last_completed_content_id)
    )

    if success && status == "completed"
      update_dependencies_met
      advance_to_next_content
      mark_as_completed if completed?
      track_completion_activity if completed?
    end

    success
  end

  def track_completion_activity
    create_activity(
      key: "training_membership.completed",
      owner: team,
      recipient: membership.user,
      parameters: {
        program_name: training_program.name,
        completion_percentage: completion_percentage,
        completed_at: completed_at,
        role: membership.roles.first
      }
    )
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

  def set_initial_content
    return if current_content_id
    first = first_content
    return unless first

    update(
      current_content_id: first.id,
      content_access_history: {
        first.id.to_s => {"first_accessed_at" => Time.current}
      }
    )
  end

  def update_dependencies_met
    deps = {}
    training_contents.order(:position).each do |content|
      deps[content.id.to_s] = can_access_content?(content)
    end
    self.content_dependencies_met = deps
  end

  def mark_as_completed
    update_column(:completed_at, Time.current) unless completed_at
  end

  # 🚅 add methods above.
end
