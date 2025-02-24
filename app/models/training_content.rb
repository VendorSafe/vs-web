class TrainingContent < ApplicationRecord
  include Sortable
  include PublicActivity::Model
  tracked owner: :team
  # 🚅 add concerns above.

  # Content types available
  CONTENT_TYPES = %w[text video audio quiz slides].freeze

  # 🚅 add attribute accessors above.

  belongs_to :training_program
  # 🚅 add belongs_to associations above.

  has_many :training_questions, dependent: :destroy
  has_many :dependent_contents, class_name: "TrainingContent",
    foreign_key: "dependencies",
    primary_key: "id"
  # 🚅 add has_many associations above.

  has_one :team, through: :training_program
  has_rich_text :body
  # 🚅 add has_one associations above.

  # 🚅 add scopes above.
  scope :required, -> { where(is_required: true) }
  scope :by_position, -> { order(:position) }
  scope :by_type, ->(type) { where(content_type: type) }

  validates :title, presence: true
  validates :content_type, presence: true, inclusion: {in: CONTENT_TYPES}
  validates :content_data, presence: true
  validates :completion_criteria, presence: true
  validate :validate_content_data_format
  validate :validate_completion_criteria_format
  validate :validate_dependencies
  # 🚅 add validations above.

  before_validation :set_default_completion_criteria
  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def collection
    training_program.training_contents
  end

  def completed_by?(membership)
    return false unless membership
    training_membership = membership.training_memberships.find_by(training_program: training_program)
    return false unless training_membership
    training_membership.content_completed?(id)
  end

  def completion_requirements_met?(progress_data)
    case content_type
    when "video", "audio"
      progress_data["watched_percentage"].to_f >= completion_criteria["required_percentage"].to_f
    when "slides"
      (progress_data["viewed_slides"] || []).sort == completion_criteria["required_slides"].sort
    when "quiz"
      progress_data["score"].to_f >= completion_criteria["passing_score"].to_f
    when "text"
      progress_data["read_percentage"].to_f >= completion_criteria["required_percentage"].to_f
    else
      false
    end
  end

  # Role-based access control methods
  def can_be_edited_by?(membership)
    return false unless membership
    return true if membership.roles.can_perform_role?(:training_admin)
    return true if membership.roles.can_perform_role?(:training_author) && training_program.draft?
    false
  end

  def can_be_viewed_by?(membership)
    return false unless membership
    return true if membership.roles.can_perform_role?(:training_admin)
    return true if membership.roles.can_perform_role?(:training_author)
    return true if training_program.published? &&
      (membership.roles.can_perform_role?(:training_participant) ||
       membership.roles.can_perform_role?(:training_viewer))
    false
  end

  def can_be_completed_by?(membership)
    return false unless membership
    return false unless training_program.published?
    membership.roles.can_perform_role?(:training_participant)
  end

  private

  def validate_content_data_format
    case content_type
    when "slides"
      unless content_data["slides"].is_a?(Array) && content_data["slides"].all? { |s| s["content"].present? }
        errors.add(:content_data, "must contain valid slides array")
      end
    when "quiz"
      unless content_data["questions"].is_a?(Array) && content_data["questions"].all? { |q| q["question"].present? && q["answers"].present? }
        errors.add(:content_data, "must contain valid questions array")
      end
    when "video", "audio"
      unless content_data["url"].present?
        errors.add(:content_data, "must contain media URL")
      end
    end
  end

  def validate_completion_criteria_format
    case content_type
    when "video", "audio", "text"
      unless completion_criteria["required_percentage"].is_a?(Numeric) &&
          completion_criteria["required_percentage"].between?(0, 100)
        errors.add(:completion_criteria, "must specify valid required percentage")
      end
    when "slides"
      unless completion_criteria["required_slides"].is_a?(Array)
        errors.add(:completion_criteria, "must specify required slides")
      end
    when "quiz"
      unless completion_criteria["passing_score"].is_a?(Numeric) &&
          completion_criteria["passing_score"].between?(0, 100)
        errors.add(:completion_criteria, "must specify valid passing score")
      end
    end
  end

  def validate_dependencies
    return unless dependencies.present?

    invalid_deps = dependencies.reject do |dep_id|
      training_program.training_contents
        .where("position < ?", position)
        .where(id: dep_id)
        .exists?
    end

    if invalid_deps.any?
      errors.add(:dependencies, "must only reference content that comes before this content")
    end
  end

  def set_default_completion_criteria
    if completion_criteria.blank?
      self.completion_criteria = case content_type
      when "video", "audio", "text"
        {"required_percentage" => 100}
      when "slides"
        {"required_slides" => content_data["slides"]&.map { |s| s["id"] } || []}
      when "quiz"
        {"passing_score" => 80}
      else
        {}
      end
    end
  end

  # 🚅 add methods above.
end
