class AddMembershipIdToFacilities < ActiveRecord::Migration[7.2]
  def change
    add_reference :facilities, :membership, null: true, foreign_key: true
  end
end
