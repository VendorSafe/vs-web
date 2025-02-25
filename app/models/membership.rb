# frozen_string_literal: true

# Manages roles and associations with training programs, ensuring proper
# access control and participation in various training initiatives.
class Membership < ApplicationRecord
  include Memberships::Base
  include Roles::Support
  # TODO: Re-enable after fixing activities table
  # include PublicActivity::Model
  # tracked owner: :team

  # Restrict available roles if needed
  # roles_only :admin, :vendor, :employee

  ROLES = {
    admin: 0,
    editor: 1,
    coordinator: 2,
    employee: 3,
    vendor: 4,
    customer: 5
  }.freeze

  ROLES.each_key do |role|
    define_method :"#{role}?" do
      role_ids.to_a.include?(ROLES[role])
    end
  end
  # 🚅 add concerns above.

  # 🚅 add belongs_to associations above.

  has_many :training_memberships, dependent: :destroy
  has_many :training_programs, through: :training_memberships
  # 🚅 add has_many associations above.

  # 🚅 add oauth providers above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # 🚅 add methods above.
end
