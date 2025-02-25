# frozen_string_literal: true

class Role
  class Collection
    include Enumerable

    def initialize(parent, roles)
      @parent = parent
      @roles = roles
    end

    def each(&)
      @roles.each(&)
    end

    def include?(role)
      @roles.include?(role)
    end

    def select(&)
      @roles.select(&)
    end

    def map(&)
      @roles.map(&)
    end

    def can_perform_role?(role_or_key)
      @parent.can_perform_role?(role_or_key)
    end
  end
end
