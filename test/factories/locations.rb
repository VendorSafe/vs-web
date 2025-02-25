FactoryBot.define do
  factory :location do
    team
    sequence(:name) { |n| "Location #{n}" }
    sequence(:location_type) { |n| %w[office warehouse store facility][n % 4] }
    sequence(:address) { |n| "#{n} Main St, San Francisco, CA 94105" }

    # Default to a Point geometry
    geometry do
      {
        type: 'Point',
        coordinates: [-122.4194 + rand(-0.1..0.1), 37.7749 + rand(-0.1..0.1)]
      }
    end

    # No parent by default (top-level location)
    parent { nil }

    # Trait for a location with a polygon geometry
    trait :with_polygon do
      geometry do
        # Create a small random polygon around San Francisco
        center_lng = -122.4194 + rand(-0.1..0.1)
        center_lat = 37.7749 + rand(-0.1..0.1)
        size = rand(0.01..0.05)

        {
          type: 'Polygon',
          coordinates: [[
            [center_lng - size, center_lat - size],
            [center_lng + size, center_lat - size],
            [center_lng + size, center_lat + size],
            [center_lng - size, center_lat + size],
            [center_lng - size, center_lat - size]
          ]]
        }
      end
    end

    # Trait for a location with a linestring geometry
    trait :with_linestring do
      geometry do
        # Create a small random linestring around San Francisco
        center_lng = -122.4194 + rand(-0.1..0.1)
        center_lat = 37.7749 + rand(-0.1..0.1)
        size = rand(0.01..0.05)

        {
          type: 'LineString',
          coordinates: [
            [center_lng - size, center_lat - size],
            [center_lng, center_lat],
            [center_lng + size, center_lat + size]
          ]
        }
      end
    end

    # Trait for a child location
    trait :child do
      parent { association :location, team: team }
    end

    # Trait for a location with children
    trait :with_children do
      after(:create) do |location|
        create_list(:location, 3, parent: location, team: location.team)
      end
    end
  end
end
