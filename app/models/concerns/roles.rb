module Roles
  extend ActiveSupport::Concern

  included do
    # ===========================================
    # Role Definitions and Access Control System
    # ===========================================

    # Administrator Role
    # -----------------
    # Full system access and management capabilities
    # - Can manage all teams and memberships
    # - Has access to all locations regardless of team
    # - Can create and modify pricing models
    # - Can manage all training programs
    # - Has access to system-wide reporting
    def admin?
      role_ids.include?("admin")
    end

    # Vendor Role
    # ----------
    # Primary vendor (administrative) users can:
    # - Create and manage their own training programs
    # - View locations they are assigned to
    # - Issue certificates for their programs
    # - Has access to reports for their programs
    # - Track progress of participants
    # - Invite and manage additional vendor users on their team
    #
    # Invited vendor users can:
    # - Access assigned training programs
    # - View assigned locations
    # - Issue certificates for their assigned programs
    def vendor?
      role_ids.include?("vendor")
    end

    # Customer Role
    # ------------
    # Organization managers purchasing training
    # - Can manage their organization's location
    # - Can purchase training programs
    # - Can assign training to employees
    # - Can view certificates for their team
    # - Has access to team-specific reports
    # - Can track team's training progress
    def customer?
      role_ids.include?("customer")
    end

    # Employee Role
    # ------------
    # Training participants
    # - Can access assigned training programs
    # - Can view and complete training modules
    # - Can access their own certificates
    # - Can track their own progress
    def employee?
      role_ids.include?("employee")
    end

    # ===========================================
    # Capability Checks
    # ===========================================

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

    def can_purchase_training?
      admin? || customer?
    end

    def can_assign_training?
      admin? || customer?
    end

    def can_take_training?
      employee? || customer?
    end

    def can_invite_vendors?
      admin? || (vendor? && primary_vendor?)
    end

    # TODO: Needs to be irone
    def can_access_reports?
      case
      when admin?
        true # All reports
      when vendor?
        true # Own program reports
      when customer?
        true # Team reports
      when employee?
        true # Own progress reports
      else
        false
      end
    end

    private

    def primary_vendor?
      return false unless vendor?
      # First vendor user in the team is considered primary
      team.memberships.where(role_ids: ["vendor"]).order(created_at: :asc).first.id == id
    end

    def own_location?
      return true if admin?
      return false unless location_id
      location.team_id == team_id
    end

    def own_training_program?
      return true if admin?
      return false unless training_program_id
      training_program.team_id == team_id
    end

    def own_certificate?
      return true if admin?
      return false unless certificate_id
      certificate.user_id == user_id
    end
  end
end