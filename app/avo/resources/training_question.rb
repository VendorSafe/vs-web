class Avo::Resources::TrainingQuestion < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :training_content, as: :belongs_to
    field :title, as: :text
    field :body, as: :textarea
    field :good_answers, as: :textarea
    field :bad_answers, as: :textarea
    field :published_at, as: :date_time
  end
end
