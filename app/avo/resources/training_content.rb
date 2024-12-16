class Avo::Resources::TrainingContent < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :training_program, as: :belongs_to
    field :title, as: :text
    field :body, as: :textarea
    field :content_type, as: :text
    field :published_at, as: :date_time
  end
end
