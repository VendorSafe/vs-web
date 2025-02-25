class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :confirmable, :omniauthable
  # TODO: Set up required database columns before enabling token auth
  # include DeviseTokenAuth::Concerns::User
  include Users::Base
  include Roles::User
  # 🚅 add concerns above.

  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add oauth providers above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # 🚅 add methods above.

  def role_in?(roles)
    roles = Array(roles)
    memberships.any? do |membership|
      roles.any? do |role|
        membership.send(:"#{role}?")
      end
    end
  end
end
