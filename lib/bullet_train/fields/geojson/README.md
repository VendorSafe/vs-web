# BulletTrain::Fields::Geojson

A Bullet Train field type for GeoJSON data, providing map-based input and display capabilities.

## Features

- Store and validate GeoJSON data in your models
- Map-based input for drawing points, lines, and polygons
- Map-based display of GeoJSON data
- Helpers for working with geospatial data
- Follows Bullet Train conventions and styling

## Installation

Add this gem to your application's Gemfile:

```ruby
gem 'bullet_train-fields-geojson', path: 'lib/bullet_train/fields/geojson'
```

And then execute:

```bash
$ bundle install
```

## Usage

### Model Configuration

Add a JSONB column to your model to store the GeoJSON data:

```ruby
class AddGeometryToLocations < ActiveRecord::Migration[7.2]
  def change
    add_column :locations, :geometry, :jsonb, default: {}, null: true
    add_index :locations, :geometry, using: :gin
  end
end
```

Then, in your model, use the `has_geojson_field` method:

```ruby
class Location < ApplicationRecord
  has_geojson_field :geometry, validate_format: true
end
```

This will add validation and helper methods to your model:

- `geometry_point?` - Returns true if the geometry is a Point
- `geometry_polygon?` - Returns true if the geometry is a Polygon
- `geometry_to_geojson` - Returns a GeoJSON Feature representation of the geometry
- `near_geometry(lat, lng, radius_km)` - Scope for finding records within a radius of a point
- `with_geometry_type(type)` - Scope for finding records by geometry type

### View Helpers

In your views, use the provided field partial:

```erb
<%= render 'fields/geojson/field', form: form, method: :geometry %>
```

Or use the helper methods directly:

```erb
<%= geojson_map_input(form, :geometry, height: "500px") %>
<%= geojson_map_display(location, :geometry, zoom: 14) %>
```

### JavaScript Controllers

The gem provides two Stimulus controllers:

1. `bullet-train--fields--geojson--map-input` - For map-based input
2. `bullet-train--fields--geojson--map-display` - For map-based display

These are automatically registered and available in your application.

## Configuration

### Mapbox API Key

The gem uses Mapbox for maps. Set your API key in your environment:

```ruby
# config/application.yml
MAPBOX_API_KEY: "your-mapbox-api-key"
```

Or pass it directly to the helpers:

```erb
<%= geojson_map_input(form, :geometry, api_key: "your-mapbox-api-key") %>
```

### PostGIS Integration

For advanced geospatial queries, you can integrate with PostGIS:

1. Install the PostGIS extension in your database
2. Enable the extension in your migration:

```ruby
class EnablePostgis < ActiveRecord::Migration[7.2]
  def up
    enable_extension "postgis" unless extension_enabled?("postgis")
  end
  
  def down
    disable_extension "postgis" if extension_enabled?("postgis")
  end
end
```

3. Implement the `near_geometry` scope in your model:

```ruby
class Location < ApplicationRecord
  has_geojson_field :geometry
  
  # Override the default near_geometry scope with PostGIS implementation
  scope :near_geometry, ->(lat, lng, radius_km) {
    where("ST_DWithin(
      ST_SetSRID(ST_GeomFromGeoJSON(geometry::text), 4326)::geography,
      ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography,
      ?
    )", lng, lat, radius_km * 1000)
  }
end
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).