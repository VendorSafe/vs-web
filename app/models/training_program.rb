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
  # 🚅 add concerns above.
  # TODO: Re-enable after fixing activities table
  # include PublicActivity::Model
  # tracked owner: :team
  include Workflow
  workflow_column :state

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

  after_initialize do
    self.state ||= "draft"
  end

  # 🚅 add attribute accessors above.

  belongs_to :team
  validates :name, presence: true
  validates :description, presence: true, unless: -> { rich_text_description&.body&.present? }
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

  # Certificate Management Methods

  # Generates a new certificate for a membership if eligible
  # @param membership [Membership] the membership to generate a certificate for
  # @return [TrainingCertificate, nil] the generated certificate or nil if not eligible
  def generate_certificate(membership)
    return nil unless can_generate_certificate?(membership)

    training_certificates.create!(
      membership: membership,
      issued_at: Time.current,
      certificate_number: generate_certificate_number,
      score: calculate_final_score(membership)
    )
  end

  # Checks if a certificate can be generated for a membership
  # @param membership [Membership] the membership to check
  # @return [Boolean] whether a certificate can be generated
  def can_generate_certificate?(membership)
    return false unless membership
    training_membership = training_memberships.find_by(membership: membership)
    return false unless training_membership&.completed?
    return false if has_valid_certificate?(membership)
    true
  end

  # Checks if a membership has a valid certificate
  # @param membership [Membership] the membership to check
  # @return [Boolean] whether the membership has a valid certificate
  def has_valid_certificate?(membership)
    return false unless certificate_validity_period
    cutoff_date = certificate_validity_period.days.ago
    training_certificates.where(membership: membership)
      .where("issued_at > ?", cutoff_date)
      .exists?
  end

  # Gets all valid certificates for this program
  # @return [ActiveRecord::Relation] valid certificates
  def valid_certificates
    return training_certificates unless certificate_validity_period
    cutoff_date = certificate_validity_period.days.ago
    training_certificates.where("issued_at > ?", cutoff_date)
  end

  private

  # Generates a unique certificate number
  # @return [String] unique certificate number
  def generate_certificate_number
    loop do
      number = "#{Time.current.year}-#{SecureRandom.hex(4).upcase}"
      break number unless TrainingCertificate.exists?(certificate_number: number)
    end
  end

  # Calculates the final score for a membership
  # @param membership [Membership] the membership to calculate score for
  # @return [Integer, nil] the calculated score or nil if not applicable
  def calculate_final_score(membership)
    training_membership = training_memberships.find_by(membership: membership)
    return nil unless training_membership&.completed?

    # TODO: Implement actual score calculation based on:
    # - Question responses
    # - Time taken
    # - Completion percentage
    training_membership.completion_percentage
  end

  # Role-based validation methods
  def can_be_published_by?(membership)
    return false unless membership
    membership.can?(:manage_training, self)
  end

  def can_be_archived_by?(membership)
    return false unless membership
    membership.can?(:manage_training, self)
  end

  def can_be_edited_by?(membership)
    return false unless membership
    membership.can?(:manage_training, self)
  end

  def can_be_viewed_by?(membership)
    return false unless membership
    return true if membership.can?(:manage_training, self)
    return true if membership.can?(:manage_team_access, self)
    return true if has_team_access?(membership) && published?
    false
  end

  # Team access methods
  def has_team_access?(membership)
    return false unless membership && published?
    training_memberships.exists?(membership: membership) ||
      membership.can?(:manage_team_access, self)
  end

  def can_invite_team_members?(membership)
    return false unless membership
    membership.can?(:manage_team_access, self)
  end

  def can_manage_team_progress?(membership)
    return false unless membership
    membership.can?(:manage_team_progress, self)
  end

  # Sequential progression methods
  def next_content_for(membership)
    return nil unless has_team_access?(membership)
    training_membership = training_memberships.find_by(membership: membership)
    return first_content unless training_membership&.current_content
    training_membership.next_available_content
  end

  def can_access_content?(membership, content)
    return false unless has_team_access?(membership)
    training_membership = training_memberships.find_by(membership: membership)
    return false unless training_membership
    training_membership.can_access_content?(content)
  end

  # Workflow event guards
  def can_publish?
    can_be_published_by?(Current.membership)
  end

  def can_archive?
    can_be_archived_by?(Current.membership)
  end

  def can_restore?
    can_be_archived_by?(Current.membership)
  end

  def can_unpublish?
    can_be_published_by?(Current.membership)
  end

  # 🚅 add methods above.
end
