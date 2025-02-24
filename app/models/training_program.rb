# TODO: Major Enhancements Needed
# 1. State Management
#    - Add workflow_activerecord gem
#    - Implement states: draft, published, archived
#    - Add state transitions and validations
#
# 2. Progress Tracking
#    - Add progress calculation methods
#    - Implement completion tracking
#    - Add progress validation
#
# 3. Certificate Management
#    - Add certificate generation
#    - Implement expiration handling
#    - Add verification mechanism
#
# 4. Vue.js Player Integration
#    - Add content serialization for player
#    - Implement progress sync methods
#    - Add player configuration options
#
# 5. Activity Tracking
#    - Re-enable PublicActivity
#    - Add custom activity tracking
#    - Implement activity filters
#

class TrainingProgram < ApplicationRecord
  # Temporarily disable PublicActivity for seeding
  # include PublicActivity::Model
  # tracked owner: :team, if: :should_track_activity?

  # 🚅 add concerns above.
  include Workflow
  include WorkflowActiverecord

  # Define the workflow states and transitions
  workflow do
    state :draft do
      event :publish, transitions_to: :published
    end

    state :published do
      event :archive, transitions_to: :archived
      event :unpublish, transitions_to: :draft
    end

    state :archived do
      event :restore, transitions_to: :published
    end
  end

  # Workflow callbacks
  after_initialize :set_default_state
  before_validation :ensure_valid_state_transition, on: :update

  # Helper methods for state management
  def set_default_state
    self.state ||= "draft"
  end

  def ensure_valid_state_transition
    return if state_changed? && valid_state_transition?
    errors.add(:state, "invalid state transition")
  end

  def valid_state_transition?
    return true if new_record?
    current_state = workflow_state.to_sym
    workflow_spec.states[current_state].events.key?(state.to_sym)
  end

  # 🚅 add attribute accessors above.

  belongs_to :team
  validates :name, presence: true
  validates :description, presence: true
  validates :team, presence: true
  belongs_to :pricing_model, optional: true
  # 🚅 add belongs_to associations above.

  has_many :training_contents, dependent: :destroy
  has_many :training_memberships, dependent: :destroy
  has_many :memberships, through: :training_memberships
  # 🚅 add has_many associations above.

  has_rich_text :description
  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :pricing_model, scope: true
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # Returns valid pricing models for this training program
  # Ensures pricing models belong to the same team
  def valid_pricing_models
    team.pricing_models
  end

  # Returns valid memberships for this training program
  # All memberships in the same team are valid
  def valid_memberships
    team.memberships
  end

  # 🚅 add methods above.
end
