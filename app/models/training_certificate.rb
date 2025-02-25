class TrainingCertificate < ApplicationRecord
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :training_program
  belongs_to :membership
  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add has_one associations above.

  has_one_attached :pdf

  scope :active, -> { where('(expires_at IS NULL OR expires_at > ?) AND revoked_at IS NULL', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :revoked, -> { where.not(revoked_at: nil) }
  scope :pdf_processing, -> { where(pdf_status: 'processing') }
  scope :pdf_completed, -> { where(pdf_status: 'completed') }
  scope :pdf_failed, -> { where(pdf_status: 'failed') }
  # 🚅 add scopes above.

  validates :membership, presence: true
  validates :training_program, presence: true
  validates :issued_at, presence: true
  validates :certificate_number, presence: true, uniqueness: true
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
                    allow_nil: true
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
    !expired? && !revoked?
  end

  def revoked?
    revoked_at.present?
  end

  def revoke!
    update(revoked_at: Time.current)
  end

  def days_until_expiration
    return nil if expires_at.nil?

    ((expires_at - Time.current) / 1.day).floor
  end

  # Returns the verification URL for this certificate
  # @return [String] the verification URL
  def verification_url
    Rails.application.routes.url_helpers.verify_training_certificate_url(
      certificate_number,
      host: Rails.application.config.action_mailer.default_url_options[:host],
      protocol: Rails.application.config.force_ssl ? 'https' : 'http'
    )
  end

  # Generates a QR code for certificate verification
  # @param size [Integer] the size of the QR code in pixels
  # @return [String] Base64 encoded PNG image
  def verification_qr_code(size: 300)
    require 'rqrcode'

    qrcode = RQRCode::QRCode.new(verification_url)
    qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: size / qrcode.modules.size,
      resize_exactly_to: false,
      resize_gte_to: false
    ).to_data_url
  end

  # Returns certificate data in a structured format
  # @return [Hash] certificate data
  def certificate_data
    {
      certificate_number: certificate_number,
      issued_at: issued_at,
      expires_at: expires_at,
      score: score,
      program: {
        name: training_program.name,
        team: training_program.team.name
      },
      holder: {
        name: "#{membership.user_first_name} #{membership.user_last_name}",
        email: membership.user_email
      },
      verification: {
        url: verification_url,
        qr_code: verification_qr_code,
        verification_code: verification_code
      },
      pdf: {
        status: pdf_status,
        error: pdf_error,
        available: pdf.attached?
      },
      custom_fields: training_program.custom_certificate_fields
    }
  end

  # Generates a PDF certificate
  # @return [Boolean] true if PDF generation was triggered successfully
  def generate_pdf!
    # Reset error if retrying
    update(pdf_error: nil) if pdf_status == 'failed'

    # Set initial status and queue job
    update!(pdf_status: 'processing')
    GenerateCertificatePdfJob.perform_later(self)
    true
  rescue StandardError => e
    update!(pdf_status: 'failed', pdf_error: "Failed to queue PDF generation: #{e.message}")
    false
  end

  # Checks if PDF is available for download
  # @return [Boolean] true if PDF is ready
  def pdf_ready?
    pdf_status == 'completed' && pdf.attached?
  end

  # Checks if PDF generation is in progress
  # @return [Boolean] true if PDF is being generated
  def pdf_processing?
    pdf_status == 'processing'
  end

  # Checks if PDF generation has failed
  # @return [Boolean] true if PDF generation failed
  def pdf_failed?
    pdf_status == 'failed'
  end

  private

  def generate_certificate_number
    return if certificate_number.present?

    loop do
      # Format: CERT-YYYY-MM-[6 random digits]
      number = "CERT-#{Time.current.strftime('%Y-%m')}-#{SecureRandom.random_number(1_000_000).to_s.rjust(6, '0')}"
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
