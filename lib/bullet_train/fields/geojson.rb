require 'bullet_train/fields/geojson/version'
require 'bullet_train/fields/geojson/engine'

module BulletTrain
  module Fields
    module Geojson
      # Your code goes here...

      # Include the concern in ActiveRecord::Base
      class Railtie < ::Rails::Railtie
        initializer 'bullet_train.fields.geojson' do
          ActiveSupport.on_load(:active_record) do
            include BulletTrain::Fields::Geojson::HasGeojsonField
          end
        end
      end
    end
  end
end
