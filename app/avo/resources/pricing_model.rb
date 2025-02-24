class Avo::Resources::PricingModel < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :team, as: :belongs_to
    field :name, as: :text
    field :price_type, as: :text
    field :base_price, as: :number
    field :volume_discount, as: :number
    field :description, as: :textarea
  end
end
