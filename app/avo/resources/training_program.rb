class Avo::Resources::TrainingProgram < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :team, as: :belongs_to
    field :name, as: :text
    field :description, as: :textarea
    field :status, as: :text
    field :slides, as: :textarea
    field :published_at, as: :date_time
  end
end
