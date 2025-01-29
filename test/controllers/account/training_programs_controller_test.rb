require "test_helper"

class Account::TrainingProgramsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @team = create(:team)
    @training_program = create(:training_program, team: @team)

    # Create vendor user with membership
    @vendor = create(:user)
    @vendor_membership = create(:membership, user: @vendor, team: @team)
    @vendor_membership.update(role_ids: [Role.vendor.id])
    create(:training_membership, membership: @vendor_membership, training_program: @training_program)

    # Create employee user with membership
    @employee = create(:user)
    @employee_membership = create(:membership, user: @employee, team: @team)
    @employee_membership.update(role_ids: [Role.employee.id])
    create(:training_membership, membership: @employee_membership, training_program: @training_program)

    # Create non-member user
    @non_member = create(:user)
    @non_member_membership = create(:membership, user: @non_member, team: @team)
  end

  test "vendor can view training program" do
    sign_in @vendor
    get account_training_program_path(@training_program)
    assert_response :success
  end

  test "employee can view training program" do
    sign_in @employee
    get account_training_program_path(@training_program)
    assert_response :success
  end

  test "non-member cannot view training program" do
    sign_in @non_member
    get account_training_program_path(@training_program)
    assert_redirected_to root_path
  end

  test "redirects when not authenticated" do
    get account_training_program_path(@training_program)
    assert_redirected_to new_user_session_path
  end
end
