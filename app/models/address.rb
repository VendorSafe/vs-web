class Address < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  include Addresses::Base
  # 🚅 add concerns above.

  belongs_to_active_hash :country, class_name: "Addresses::Country"
  belongs_to_active_hash :region, class_name: "Addresses::Region"
  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add oauth providers above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # 🚅 add methods above.
end
