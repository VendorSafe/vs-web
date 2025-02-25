# frozen_string_literal: true

module Roles
  module Support
    extend ActiveSupport::Concern

    included do
      # Define role-related validations and associations here
      validates :role_ids, presence: true
    end

    def roles
      role_ids.map { |id| Role.new(id, Role::ROLES.key(id)) }
    end

    def has_role?(role_name)
      role_ids.include?(Role::ROLES[role_name.to_sym])
    end

    def add_role(role_name)
      role_id = Role::ROLES[role_name.to_sym]
      return false unless role_id

      self.role_ids = (role_ids + [role_id]).uniq
    end

    def remove_role(role_name)
      role_id = Role::ROLES[role_name.to_sym]
      return false unless role_id

      self.role_ids = role_ids - [role_id]
    end

    Role::ROLES.each do |role_name, _|
      define_method("#{role_name}?") do
        has_role?(role_name)
      end
    end
  end
end
