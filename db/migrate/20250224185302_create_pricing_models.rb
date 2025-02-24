class CreatePricingModels < ActiveRecord::Migration[7.2]
  def change
    create_table :pricing_models do |t|
      t.references :team, null: false, foreign_key: true
      t.string :name
      t.string :price_type
      t.integer :base_price
      t.integer :volume_discount
      t.text :description

      t.timestamps
    end
  end
end
