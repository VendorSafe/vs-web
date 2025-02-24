class PricingModel < ApplicationRecord
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :team
  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  has_rich_text :description
  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :name, presence: true
  validates :price_type, presence: true, inclusion: { in: %w[fixed variable] }
  validates :base_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :volume_discount, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def calculate_price(quantity = 1)
    return base_price if price_type == 'fixed'

    discount_multiplier = (100 - volume_discount) / 100.0
    total = base_price * quantity
    total * discount_multiplier
  end

  def price_for_display
    return "#{base_price} per unit (#{volume_discount}% volume discount)" if price_type == 'variable'
    base_price.to_s
  end

  # 🚅 add methods above.
end
