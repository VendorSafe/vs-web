module BulletTrain
  module Fields
    module Geojson
      module ApplicationHelper
        # Renders a map input field for a GeoJSON attribute
        # @param form [ActionView::Helpers::FormBuilder] The form builder
        # @param method [Symbol] The attribute name
        # @param options [Hash] Options for the field
        # @option options [String] :api_key Mapbox API key
        # @option options [Array] :center Initial map center [lng, lat]
        # @option options [Integer] :zoom Initial map zoom level
        # @option options [Hash] :input_html HTML options for the input field
        # @option options [Hash] :map_html HTML options for the map container
        def geojson_map_input(form, method, options = {})
          api_key = options.delete(:api_key) || ENV.fetch('MAPBOX_API_KEY', nil)
          center = options.delete(:center) || [-122.4194, 37.7749] # Default: San Francisco
          zoom = options.delete(:zoom) || 12
          input_html = options.delete(:input_html) || {}
          map_html = options.delete(:map_html) || { style: 'height: 400px;' }

          # Get the current value
          value = form.object.send(method)
          value_json = value.present? ? value.to_json : '{}'

          content_tag(:div, data: {
                        controller: 'map-input',
                        'map-input-api-key-value': api_key,
                        'map-input-center-value': center.to_json,
                        'map-input-zoom-value': zoom,
                        'map-input-initial-value': value_json
                      }) do
            concat content_tag(:div, '', data: { 'map-input-target': 'map' }, **map_html)
            concat form.hidden_field(method, data: { 'map-input-target': 'input' }, **input_html)
            concat content_tag(:div, '', data: { 'map-input-target': 'coordinates' },
                                         class: 'text-sm text-gray-500 mt-1')
          end
        end

        # Renders a map display for a GeoJSON attribute
        # @param record [ActiveRecord::Base] The record containing the GeoJSON attribute
        # @param method [Symbol] The attribute name
        # @param options [Hash] Options for the display
        # @option options [String] :api_key Mapbox API key
        # @option options [Array] :center Initial map center [lng, lat]
        # @option options [Integer] :zoom Initial map zoom level
        # @option options [Hash] :map_html HTML options for the map container
        def geojson_map_display(record, method, options = {})
          api_key = options.delete(:api_key) || ENV.fetch('MAPBOX_API_KEY', nil)
          center = options.delete(:center) || [-122.4194, 37.7749] # Default: San Francisco
          zoom = options.delete(:zoom) || 12
          map_html = options.delete(:map_html) || { style: 'height: 400px;' }

          # Get the GeoJSON representation
          value = record.send(method)
          geojson = if value.present?
                      if record.respond_to?("#{method}_to_geojson")
                        record.send("#{method}_to_geojson")
                      else
                        {
                          type: 'Feature',
                          geometry: value,
                          properties: {
                            id: record.id,
                            model_name: record.class.name,
                            field_name: method
                          }
                        }
                      end
                    else
                      { type: 'FeatureCollection', features: [] }
                    end

          content_tag(:div, data: {
                        controller: 'map-display',
                        'map-display-api-key-value': api_key,
                        'map-display-center-value': center.to_json,
                        'map-display-zoom-value': zoom,
                        'map-display-geojson-value': geojson.to_json
                      }) do
            concat content_tag(:div, '', data: { 'map-display-target': 'map' }, **map_html)
            concat content_tag(:div, '', data: { 'map-display-target': 'info' }, class: 'text-sm mt-2')
          end
        end
      end
    end
  end
end
