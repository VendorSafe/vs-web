class TrainingInvitationsController < ApplicationController
  before_action :authenticate_user!

  def show
    @invitation = TrainingInvitation.find_by(token: params[:token])
    if @invitation&.valid?
      # Start the training program
      start_training_program(@invitation)
    else
      # Handle invalid invitation
      render 'invalid_invitation'
    end
  end

  private

  def start_training_program(invitation)
    # Create a new training membership
    membership = TrainingMembership.create!(
      user: current_user,
      training_program: invitation.training_program
    )

    # Redirect to the training program viewer
    redirect_to training_program_path(membership.training_program)
  end
end
