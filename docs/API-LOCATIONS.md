# Locations API Documentation

This document provides detailed information about the Locations API endpoints, including request and response formats, parameters, and examples.

## Overview

The Locations API provides access to location data with GeoJSON support. It allows you to:

- Retrieve a list of locations
- Get details about a specific location
- Create new locations
- Update existing locations
- Delete locations
- Find locations near a geographic point
- Access hierarchical location data

## Authentication

All API requests require authentication using a Bearer token:

```
Authorization: Bearer YOUR_API_TOKEN
```

## Endpoints

### List Locations

Retrieves a list of locations for a team.

**Endpoint:** `GET /api/v1/teams/:team_id/locations`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| team_id | integer | The ID of the team |
| geometry_type | string | (Optional) Filter by geometry type (Point, LineString, Polygon, etc.) |

**Response:**

```json
[
  {
    "id": 1,
    "name": "Headquarters",
    "location_type": "office",
    "address": "123 Main St, San Francisco, CA",
    "geometry": {
      "type": "Point",
      "coordinates": [-122.4194, 37.7749]
    },
    "parent_id": null,
    "team_id": 1,
    "created_at": "2025-02-25T15:30:00.000Z",
    "updated_at": "2025-02-25T15:30:00.000Z",
    "full_path": "Headquarters",
    "has_children": true,
    "children_count": 3,
    "parent_name": null,
    "geometry_type": "Point"
  },
  // ...more locations
]
```

### Get Location

Retrieves details about a specific location.

**Endpoint:** `GET /api/v1/locations/:id`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| id | integer | The ID of the location |

**Response:**

```json
{
  "id": 1,
  "name": "Headquarters",
  "location_type": "office",
  "address": "123 Main St, San Francisco, CA",
  "geometry": {
    "type": "Point",
    "coordinates": [-122.4194, 37.7749]
  },
  "parent_id": null,
  "team_id": 1,
  "created_at": "2025-02-25T15:30:00.000Z",
  "updated_at": "2025-02-25T15:30:00.000Z",
  "full_path": "Headquarters",
  "has_children": true,
  "children_count": 3,
  "parent_name": null,
  "geometry_type": "Point"
}
```

### Create Location

Creates a new location.

**Endpoint:** `POST /api/v1/teams/:team_id/locations`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| team_id | integer | The ID of the team |
| location[name] | string | The name of the location |
| location[location_type] | string | The type of location (office, warehouse, etc.) |
| location[address] | string | The address of the location |
| location[parent_id] | integer | (Optional) The ID of the parent location |
| location[geometry] | object | GeoJSON geometry object |

**Example Request:**

```json
{
  "location": {
    "name": "New Office",
    "location_type": "office",
    "address": "456 Market St, San Francisco, CA",
    "parent_id": 1,
    "geometry": {
      "type": "Point",
      "coordinates": [-122.4194, 37.7749]
    }
  }
}
```

**Response:**

```json
{
  "id": 4,
  "name": "New Office",
  "location_type": "office",
  "address": "456 Market St, San Francisco, CA",
  "geometry": {
    "type": "Point",
    "coordinates": [-122.4194, 37.7749]
  },
  "parent_id": 1,
  "team_id": 1,
  "created_at": "2025-02-25T15:35:00.000Z",
  "updated_at": "2025-02-25T15:35:00.000Z",
  "full_path": "Headquarters > New Office",
  "has_children": false,
  "children_count": 0,
  "parent_name": "Headquarters",
  "geometry_type": "Point"
}
```

### Update Location

Updates an existing location.

**Endpoint:** `PATCH /api/v1/locations/:id`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| id | integer | The ID of the location |
| location[name] | string | (Optional) The name of the location |
| location[location_type] | string | (Optional) The type of location |
| location[address] | string | (Optional) The address of the location |
| location[parent_id] | integer | (Optional) The ID of the parent location |
| location[geometry] | object | (Optional) GeoJSON geometry object |

**Example Request:**

```json
{
  "location": {
    "name": "Updated Office",
    "geometry": {
      "type": "Point",
      "coordinates": [-122.4194, 37.7749]
    }
  }
}
```

**Response:**

```json
{
  "id": 4,
  "name": "Updated Office",
  "location_type": "office",
  "address": "456 Market St, San Francisco, CA",
  "geometry": {
    "type": "Point",
    "coordinates": [-122.4194, 37.7749]
  },
  "parent_id": 1,
  "team_id": 1,
  "created_at": "2025-02-25T15:35:00.000Z",
  "updated_at": "2025-02-25T15:40:00.000Z",
  "full_path": "Headquarters > Updated Office",
  "has_children": false,
  "children_count": 0,
  "parent_name": "Headquarters",
  "geometry_type": "Point"
}
```

### Delete Location

Deletes a location.

**Endpoint:** `DELETE /api/v1/locations/:id`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| id | integer | The ID of the location |

**Response:**

```
HTTP/1.1 200 OK
```

### Find Locations Near a Point

Finds locations within a radius of a geographic point.

**Endpoint:** `GET /api/v1/teams/:team_id/locations/near`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| team_id | integer | The ID of the team |
| lat | float | Latitude of the center point |
| lng | float | Longitude of the center point |
| radius | float | Radius in kilometers |

**Example Request:**

```
GET /api/v1/teams/1/locations/near?lat=37.7749&lng=-122.4194&radius=10
```

**Response:**

```json
[
  {
    "id": 1,
    "name": "Headquarters",
    "location_type": "office",
    "address": "123 Main St, San Francisco, CA",
    "geometry": {
      "type": "Point",
      "coordinates": [-122.4194, 37.7749]
    },
    "parent_id": null,
    "team_id": 1,
    "created_at": "2025-02-25T15:30:00.000Z",
    "updated_at": "2025-02-25T15:30:00.000Z",
    "full_path": "Headquarters",
    "has_children": true,
    "children_count": 3,
    "parent_name": null,
    "geometry_type": "Point"
  },
  // ...more locations within the radius
]
```

### Get Children of a Location

Retrieves the children of a location.

**Endpoint:** `GET /api/v1/locations/:id/children`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| id | integer | The ID of the location |

**Response:**

```json
[
  {
    "id": 2,
    "name": "Floor 1",
    "location_type": "floor",
    "address": "123 Main St, San Francisco, CA",
    "geometry": {
      "type": "Polygon",
      "coordinates": [[
        [-122.42, 37.78],
        [-122.41, 37.78],
        [-122.41, 37.77],
        [-122.42, 37.77],
        [-122.42, 37.78]
      ]]
    },
    "parent_id": 1,
    "team_id": 1,
    "created_at": "2025-02-25T15:30:00.000Z",
    "updated_at": "2025-02-25T15:30:00.000Z",
    "full_path": "Headquarters > Floor 1",
    "has_children": true,
    "children_count": 2,
    "parent_name": "Headquarters",
    "geometry_type": "Polygon"
  },
  // ...more child locations
]
```

## Error Responses

### Unauthorized

```json
{
  "error": "You need to sign in or sign up before continuing."
}
```

### Forbidden

```json
{
  "error": "You are not authorized to access this resource."
}
```

### Not Found

```json
{
  "error": "Resource not found."
}
```

### Validation Error

```json
{
  "errors": {
    "name": ["can't be blank"],
    "geometry": ["must be valid GeoJSON with type and coordinates"]
  }
}
```

## GeoJSON Support

The Locations API supports the following GeoJSON geometry types:

- Point
- LineString
- Polygon
- MultiPoint
- MultiLineString
- MultiPolygon

For more information about GeoJSON, see the [GeoJSON specification](https://geojson.org/).

## Hierarchical Location Structure

Locations can have a parent-child relationship, allowing for a hierarchical structure. For example:

- Headquarters (parent)
  - Floor 1 (child of Headquarters)
    - Room 101 (child of Floor 1)
    - Room 102 (child of Floor 1)
  - Floor 2 (child of Headquarters)
    - Room 201 (child of Floor 2)
    - Room 202 (child of Floor 2)

This hierarchical structure is represented in the API through the `parent_id` field and the `children` endpoint.