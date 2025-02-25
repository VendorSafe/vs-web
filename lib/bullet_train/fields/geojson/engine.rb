module BulletTrain
  module Fields
    module Geojson
      class Engine < ::Rails::Engine
        isolate_namespace BulletTrain::Fields::Geojson

        config.to_prepare do
          # Load any initializers or configurations
        end

        initializer 'bullet_train.fields.geojson.assets' do |app|
          # Register assets with the asset pipeline
          if defined?(Sprockets) && Sprockets::VERSION.chr.to_i >= 4
            app.config.assets.precompile += %w[
              bullet_train/fields/geojson/map_input.js
              bullet_train/fields/geojson/map_display.js
              bullet_train/fields/geojson/mapbox-gl.css
              bullet_train/fields/geojson/mapbox-gl-draw.css
            ]
          end
        end

        initializer 'bullet_train.fields.geojson.helpers' do
          ActiveSupport.on_load(:action_controller_base) do
            if defined?(BulletTrain::Fields::Geojson::ApplicationHelper)
              helper BulletTrain::Fields::Geojson::ApplicationHelper
            end
          end
        end
      end
    end
  end
end
