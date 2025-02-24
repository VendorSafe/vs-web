module Roles
  extend ActiveSupport::Concern

  included do
    # Define role-specific methods
    def admin?
      role_ids.include?("admin")
    end

    def vendor?
      role_ids.include?("vendor")
    end

    def customer?
      role_ids.include?("customer")
    end

    def employee?
      role_ids.include?("employee")
    end

    # Permission checks based on capabilities
    def can_manage_team?
      admin?
    end

    def can_manage_locations?
      admin? || (customer? && own_location?)
    end

    def can_manage_training_programs?
      admin? || (vendor? && own_training_program?)
    end

    def can_view_certificates?
      admin? || vendor? || customer? || (employee? && own_certificate?)
    end

    def can_issue_certificates?
      admin? || vendor?
    end

    private

    def own_location?
      # Implement location ownership check
      true
    end

    def own_training_program?
      # Implement training program ownership check
      true
    end

    def own_certificate?
      # Implement certificate ownership check
      true
    end
  end
end
