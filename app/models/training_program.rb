# TrainingProgram Model
#
# == Schema Information
#
# Table name: training_programs
#  id                         :bigint           not null, primary key
#  team_id                    :bigint           not null
#  name                      :string
#  description               :text
#  status                    :string
#  slides                    :text
#  published_at              :datetime
#  pricing_model_id          :bigint
#  completion_deadline       :datetime
#  completion_timeframe      :integer
#  passing_percentage        :integer
#  time_limit               :integer
#  is_published             :boolean
#  state                    :string           default("draft"), not null
#  certificate_validity_period :integer        comment: "Number of days the certificate is valid for"
#  certificate_template      :string          comment: "Template identifier for certificate generation"
#  custom_certificate_fields :jsonb           default({}), not null, comment: "Custom fields to display on certificates"
#
# == State Management
# Current implementation uses workflow_activerecord for state management:
# - draft: Initial state for new programs
# - published: Program is live and available to users
# - archived: Program is no longer active
#
# TODO: Implement additional state features:
# - Add validation for required fields before publishing
# - Add state-specific scopes for easier querying
# - Implement state change notifications
#
# == Progress Tracking
# Progress is tracked through training_memberships and training_progress tables:
# - training_memberships: Overall progress for a user
# - training_progress: Detailed progress for each content item
#
# TODO: Implement progress tracking:
# - Add methods to calculate overall progress
# - Implement completion criteria validation
# - Add progress update callbacks
# - Add completion notifications
#
# == Certificate Management
# Certificates are managed through training_certificates table with:
# - Validity period tracking
# - Custom certificate fields
# - Template management
#
# TODO: Implement certificate features:
# - Add certificate generation service
# - Implement expiration notifications
# - Add certificate verification endpoints
# - Add certificate template management
#
# == Content Organization
# Content is managed through training_contents and training_questions tables:
# - training_contents: Main content items (videos, documents, etc.)
# - training_questions: Assessment questions
#
# TODO: Implement content features:
# - Add content type validation
# - Implement content ordering
# - Add content prerequisites
# - Add content visibility rules
#
# == Activity Tracking
# TODO: Re-enable and implement activity tracking:
# - Enable PublicActivity tracking
# - Add custom activity types
# - Implement activity filters
# - Add activity notifications

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
  has_many :training_certificates, dependent: :destroy
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
