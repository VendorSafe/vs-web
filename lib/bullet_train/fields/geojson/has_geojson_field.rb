module BulletTrain
  module Fields
    module Geojson
      module HasGeojsonField
        extend ActiveSupport::Concern

        class_methods do
          # Define a GeoJSON field on a model
          # @param field_name [Symbol] The name of the field
          # @param options [Hash] Options for the field
          # @option options [Boolean] :required Whether the field is required
          # @option options [Boolean] :validate_format Whether to validate the GeoJSON format
          def has_geojson_field(field_name, options = {})
            # Ensure the field exists in the database
            unless column_names.include?(field_name.to_s)
              raise ArgumentError, "Column '#{field_name}' does not exist on #{table_name}"
            end

            # Ensure the field is a JSONB type
            column = columns_hash[field_name.to_s]
            unless column.type == :jsonb
              raise ArgumentError, "Column '#{field_name}' must be of type JSONB, but is #{column.type}"
            end

            # Add validation if required
            validates field_name, presence: true if options[:required]

            # Add format validation if requested
            if options[:validate_format]
              validate do |record|
                value = record.send(field_name)
                next if value.blank?

                unless value.is_a?(Hash) &&
                       value['type'].present? &&
                       value['coordinates'].present? &&
                       %w[Point LineString Polygon MultiPoint MultiLineString
                          MultiPolygon].include?(value['type'])
                  record.errors.add(field_name, 'must be valid GeoJSON with type and coordinates')
                end
              end
            end

            # Define helper methods
            define_method("#{field_name}_point?") do
              self[field_name].present? && self[field_name]['type'] == 'Point'
            end

            define_method("#{field_name}_polygon?") do
              self[field_name].present? && self[field_name]['type'] == 'Polygon'
            end

            define_method("#{field_name}_to_geojson") do
              return nil if self[field_name].blank?

              {
                type: 'Feature',
                geometry: self[field_name],
                properties: {
                  id: id,
                  model_name: self.class.name,
                  field_name: field_name
                }
              }
            end

            # Define scope for finding records within a radius of a point
            scope :"near_#{field_name}", lambda { |lat, lng, radius_km|
              # This is a placeholder for PostGIS implementation
              # Will be implemented when PostGIS is fully configured
              where('1=1') # Returns all records for now
            }

            # Define scope for finding records by geometry type
            scope :"with_#{field_name}_type", lambda { |type|
              where("#{field_name}->>'type' = ?", type)
            }
          end
        end
      end
    end
  end
end
