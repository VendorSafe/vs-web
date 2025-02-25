class Ability
  include CanCan::Ability
  include Roles::Permit

  include Billing::AbilitySupport if billing_enabled?

  def initialize(user)
    return unless user.present?

    # permit is a Bullet Train created "magic" method. It parses all the roles in `config/roles.yml` and automatically
    # inserts the appropriate `can` method calls here
    permit user, through: :memberships, parent: :team

    # Training Program permissions for vendors and employees
    if user.role_in?(%w[employee vendor])
      can :read, TrainingProgram do |program|
        user.memberships.joins(:training_memberships)
            .where(training_memberships: { training_program: program })
            .exists?
      end
    end

    # Customer permissions for certificates
    if user.role_in?(['customer'])
      can :revoke, TrainingCertificate do |certificate|
        certificate.team_id == user.current_team.id
      end
    end

    # INDIVIDUAL USER PERMISSIONS.
    can :manage, User, id: user.id
    can :read, User, id: user.collaborating_user_ids
    can :destroy, Membership, user_id: user.id
    can :manage, Invitation, id: user.teams.map(&:invitations).flatten.map(&:id)

    can :create, Team

    # We only allow users to work with the access tokens they've created, e.g. those not created via OAuth2.
    can :manage, Platform::AccessToken, application: { team_id: user.team_ids }, provisioned: true

    if stripe_enabled?
      can %i[read create destroy], Oauth::StripeAccount, user_id: user.id
      can :manage, Integrations::StripeInstallation, team_id: user.team_ids
      can :destroy, Integrations::StripeInstallation, oauth_stripe_account: { user_id: user.id }
    end

    # 🚅 super scaffolding will insert any new oauth providers above.

    apply_billing_abilities user if billing_enabled?

    nil unless user.developer?
    # the following admin abilities were added by super scaffolding.
  end
end
