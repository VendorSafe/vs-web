class TrainingCertificatesController < ApplicationController
  include SortableController

  load_and_authorize_resource :team
  load_and_authorize_resource :training_program, through: :team, optional: true
  load_and_authorize_resource :training_certificate, through: :training_program, optional: true

  before_action :set_training_certificate, only: %i[show download_pdf regenerate_pdf revoke]
  before_action :set_training_program, only: %i[index new create]

  # GET /training_certificates
  # GET /teams/:team_id/training_certificates
  # GET /teams/:team_id/training_programs/:training_program_id/training_certificates
  def index
    @training_certificates = @training_certificates.includes(:training_program, :membership)

    # Filter by program if not already scoped
    @training_certificates = @training_certificates.where(training_program: @training_program) if @training_program

    # Filter by status
    if params[:status].present?
      case params[:status]
      when 'active'
        @training_certificates = @training_certificates.active
      when 'expired'
        @training_certificates = @training_certificates.expired
      end
    end

    # Apply sorting
    @pagy, @training_certificates = pagy(sort_records(@training_certificates))
  end

  # GET /training_certificates/:id
  def show
    # Generate PDF if not already generated
    @training_certificate.generate_pdf! unless @training_certificate.pdf_ready? || @training_certificate.pdf_processing?
  end

  # GET /training_certificates/verify/:verification_code
  def verify
    @training_certificate = TrainingCertificate.find_by!(verification_code: params[:verification_code])

    respond_to do |format|
      format.html
      format.json { render json: @training_certificate.certificate_data }
    end
  end

  # GET /teams/:team_id/training_programs/:training_program_id/training_certificates/new
  def new
    @training_certificate = @training_program.training_certificates.new
    @memberships = @team.memberships.includes(:user)
  end

  # POST /teams/:team_id/training_programs/:training_program_id/training_certificates
  def create
    @training_certificate = @training_program.training_certificates.new(training_certificate_params)

    respond_to do |format|
      if @training_certificate.save
        # Trigger PDF generation
        @training_certificate.generate_pdf!

        format.html { redirect_to training_certificate_path(@training_certificate), notice: t('.success') }
        format.json { render :show, status: :created, location: @training_certificate }
      else
        @memberships = @team.memberships.includes(:user)
        format.html { render :new }
        format.json { render json: @training_certificate.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /training_certificates/:id/download_pdf
  def download_pdf
    if @training_certificate.pdf_ready?
      redirect_to rails_blob_path(@training_certificate.pdf, disposition: 'attachment')
    else
      redirect_to training_certificate_path(@training_certificate), alert: t('.not_available')
    end
  end

  # POST /training_certificates/:id/regenerate_pdf
  def regenerate_pdf
    @training_certificate.generate_pdf!
    redirect_to training_certificate_path(@training_certificate), notice: t('.success')
  end

  # POST /training_certificates/:id/revoke
  def revoke
    authorize! :revoke, @training_certificate

    if @training_certificate.revoke!
      redirect_to training_certificate_path(@training_certificate), notice: t('.success')
    else
      redirect_to training_certificate_path(@training_certificate), alert: t('.failure')
    end
  end

  private

  def set_training_certificate
    @training_certificate = TrainingCertificate.find(params[:id])
    authorize! :read, @training_certificate
  end

  def set_training_program
    @training_program = TrainingProgram.find(params[:training_program_id]) if params[:training_program_id]
  end

  def training_certificate_params
    params.require(:training_certificate).permit(
      :membership_id,
      :score,
      :issued_at,
      :expires_at
    )
  end
end
