class TrainingCertificate < ApplicationRecord
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :training_program
  belongs_to :membership
  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add has_one associations above.

  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }
  # 🚅 add scopes above.

  validates :membership, presence: true
  validates :training_program, presence: true
  validates :issued_at, presence: true
  validates :certificate_number, presence: true, uniqueness: true
  validates :score, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100}, allow_nil: true
  # 🚅 add validations above.

  before_validation :generate_certificate_number, on: :create
  before_validation :set_expiration_date, on: :create
  # 🚅 add callbacks above.

  delegate :team, to: :training_program
  delegate :user, to: :membership
  # 🚅 add delegations above.

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def active?
    !expired?
  end

  def days_until_expiration
    return nil if expires_at.nil?
    ((expires_at - Time.current) / 1.day).floor
  end

  def verification_url
    # TODO: Implement with actual domain
    "#{Rails.application.routes.default_url_options[:host]}/certificates/verify/#{certificate_number}"
  end

  def verification_qr_code
    # TODO: Implement QR code generation
    verification_url
  end

  def revoke!
    update!(expires_at: Time.current)
  end

  private

  def generate_certificate_number
    return if certificate_number.present?

    loop do
      # Format: CERT-YYYY-MM-[6 random digits]
      number = "CERT-#{Time.current.strftime("%Y-%m")}-#{SecureRandom.random_number(1_000_000).to_s.rjust(6, "0")}"
      unless self.class.exists?(certificate_number: number)
        self.certificate_number = number
        break
      end
    end
  end

  def set_expiration_date
    return if expires_at.present?

    validity_period = training_program.certificate_validity_period
    self.expires_at = validity_period ? issued_at + validity_period : nil
  end

  # 🚅 add methods above.
end
