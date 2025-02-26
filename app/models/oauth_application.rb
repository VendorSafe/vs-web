class OauthApplication < ApplicationRecord
  belongs_to :team, optional: true

  has_many :access_tokens, class_name: 'OauthAccessToken', foreign_key: 'application_id', dependent: :destroy

  validates :name, presence: true
  validates :uid, presence: true, uniqueness: true
  validates :secret, presence: true

  before_validation :generate_credentials, on: :create

  private

  def generate_credentials
    self.uid = SecureRandom.hex(8) if uid.blank?
    self.secret = SecureRandom.hex(16) if secret.blank?
  end
end
