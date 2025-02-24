class AddPricingModelIdToTrainingPrograms < ActiveRecord::Migration[7.2]
  def change
    add_reference :training_programs, :pricing_model, null: true, foreign_key: true
  end
end
