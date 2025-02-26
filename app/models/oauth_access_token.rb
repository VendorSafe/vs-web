class OauthAccessToken < ApplicationRecord
  belongs_to :resource_owner, class_name: 'User', optional: true
  belongs_to :application, class_name: 'OauthApplication'

  validates :token, presence: true, uniqueness: true
  validates :application_id, presence: true

  before_validation :generate_token, on: :create

  def user
    resource_owner
  end

  def user=(user)
    self.resource_owner = user
  end

  private

  def generate_token
    self.token = SecureRandom.hex(32) if token.blank?
    self.refresh_token = SecureRandom.hex(32) if refresh_token.blank?
  end
end
