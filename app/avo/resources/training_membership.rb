class Avo::Resources::TrainingMembership < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :training_program, as: :belongs_to
    field :membership, as: :belongs_to
  end
end
