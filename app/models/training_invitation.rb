class TrainingInvitation < ApplicationRecord
  # 🚅 add concerns above.
  include Workflow

  # Available statuses for invitations
  STATUSES = %w[pending accepted completed expired].freeze

  # 🚅 add attribute accessors above.

  belongs_to :training_program
  belongs_to :invitee, class_name: "User"
  belongs_to :inviter, class_name: "User"
  # 🚅 add belongs_to associations above.

  has_one :training_membership, dependent: :nullify
  # 🚅 add has_many associations above.

  has_one :team, through: :training_program
  # 🚅 add has_one associations above.

  # 🚅 add scopes above.
  scope :active, -> { where(status: %w[pending accepted]) }
  scope :pending, -> { where(status: "pending") }
  scope :expired, -> { where("expires_at < ?", Time.current) }

  validates :status, presence: true, inclusion: {in: STATUSES}
  validates :expires_at, presence: true
  validates :invitee_id, uniqueness: {scope: :training_program_id,
                                      message: "already has an invitation for this training program"}
  validate :validate_program_state
  validate :validate_expiration_date
  # 🚅 add validations above.

  before_validation :set_default_expiration, on: :create
  # 🚅 add callbacks above.

  workflow_column :status
  workflow do
    state :pending do
      event :accept, transitions_to: :accepted
      event :expire, transitions_to: :expired
    end

    state :accepted do
      event :complete, transitions_to: :completed
      event :expire, transitions_to: :expired
    end

    state :completed
    state :expired
  end

  # 🚅 add delegations above.

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def active?
    %w[pending accepted].include?(status)
  end

  def accept!(user = nil)
    return false unless can_accept?

    transaction do
      if accept
        create_training_membership!(
          training_program: training_program,
          membership: invitee.memberships.find_by(team: team),
          metadata: metadata
        )
        true
      else
        false
      end
    end
  end

  def can_accept?
    pending? && !expired? && training_program.published?
  end

  def time_until_expiry
    return nil if expires_at.nil?
    return 0 if expired?
    ((expires_at - Time.current) / 1.day).round
  end

  private

  def validate_program_state
    return unless training_program
    unless training_program.published?
      errors.add(:training_program, "must be published to send invitations")
    end
  end

  def validate_expiration_date
    return unless expires_at_changed? && expires_at.present?
    if expires_at < Time.current
      errors.add(:expires_at, "cannot be in the past")
    end
  end

  def set_default_expiration
    return if expires_at.present?

    # Set expiration based on program settings or default to 30 days
    days = if training_program&.completion_timeframe
      training_program.completion_timeframe
    else
      30
    end

    self.expires_at = days.days.from_now
  end

  # 🚅 add methods above.
end
