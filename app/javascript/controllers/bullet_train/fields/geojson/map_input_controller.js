import { Controller } from "@hotwired/stimulus"

/**
 * Map Input Controller
 * 
 * This controller provides a map-based interface for inputting GeoJSON data.
 * It allows users to draw points, lines, and polygons on a map and stores
 * the resulting GeoJSON in a hidden input field.
 * 
 * Dependencies:
 * - Mapbox GL JS (https://docs.mapbox.com/mapbox-gl-js/api/)
 * - Mapbox GL Draw (https://github.com/mapbox/mapbox-gl-draw)
 * 
 * Usage:
 * <div data-controller="bullet-train--fields--geojson--map-input" 
 *      data-bullet-train--fields--geojson--map-input-api-key-value="YOUR_MAPBOX_API_KEY"
 *      data-bullet-train--fields--geojson--map-input-initial-value='{"type":"Point","coordinates":[-122.4194,37.7749]}'>
 *   <div data-bullet-train--fields--geojson--map-input-target="map" style="height: 400px;"></div>
 *   <input type="hidden" name="location[geometry]" data-bullet-train--fields--geojson--map-input-target="input">
 *   <div data-bullet-train--fields--geojson--map-input-target="coordinates" class="text-sm text-gray-500 mt-1"></div>
 * </div>
 */
export default class extends Controller {
  static targets = ["map", "input", "coordinates"]
  
  static values = {
    apiKey: String,
    initial: Object,
    center: { type: Array, default: [-122.4194, 37.7749] }, // Default: San Francisco
    zoom: { type: Number, default: 12 }
  }
  
  connect() {
    // Load Mapbox GL JS and Mapbox GL Draw
    this.loadMapboxScripts().then(() => {
      this.initializeMap()
      this.initializeDrawTools()
      this.loadExistingGeometry()
    })
  }
  
  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
  
  /**
   * Load Mapbox GL JS and Mapbox GL Draw scripts dynamically
   */
  loadMapboxScripts() {
    return new Promise((resolve) => {
      // Check if Mapbox is already loaded
      if (window.mapboxgl && window.MapboxDraw) {
        resolve()
        return
      }
      
      // Load Mapbox GL JS
      const mapboxScript = document.createElement('script')
      mapboxScript.src = 'https://api.mapbox.com/mapbox-gl-js/v2.14.1/mapbox-gl.js'
      document.head.appendChild(mapboxScript)
      
      // Load Mapbox GL CSS
      const mapboxCss = document.createElement('link')
      mapboxCss.rel = 'stylesheet'
      mapboxCss.href = 'https://api.mapbox.com/mapbox-gl-js/v2.14.1/mapbox-gl.css'
      document.head.appendChild(mapboxCss)
      
      // Load Mapbox GL Draw
      const drawScript = document.createElement('script')
      drawScript.src = 'https://api.mapbox.com/mapbox-gl-js/plugins/mapbox-gl-draw/v1.4.0/mapbox-gl-draw.js'
      document.head.appendChild(drawScript)
      
      // Load Mapbox GL Draw CSS
      const drawCss = document.createElement('link')
      drawCss.rel = 'stylesheet'
      drawCss.href = 'https://api.mapbox.com/mapbox-gl-js/plugins/mapbox-gl-draw/v1.4.0/mapbox-gl-draw.css'
      document.head.appendChild(drawCss)
      
      // Wait for scripts to load
      mapboxScript.onload = () => {
        drawScript.onload = () => {
          resolve()
        }
      }
    })
  }
  
  /**
   * Initialize the Mapbox map
   */
  initializeMap() {
    mapboxgl.accessToken = this.apiKeyValue
    
    this.map = new mapboxgl.Map({
      container: this.mapTarget,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: this.centerValue,
      zoom: this.zoomValue
    })
    
    // Add navigation controls
    this.map.addControl(new mapboxgl.NavigationControl(), 'top-right')
    
    // Add fullscreen control
    this.map.addControl(new mapboxgl.FullscreenControl(), 'top-right')
    
    // Add geolocate control
    this.map.addControl(
      new mapboxgl.GeolocateControl({
        positionOptions: {
          enableHighAccuracy: true
        },
        trackUserLocation: true
      }),
      'top-right'
    )
  }
  
  /**
   * Initialize the drawing tools
   */
  initializeDrawTools() {
    this.draw = new MapboxDraw({
      displayControlsDefault: false,
      controls: {
        point: true,
        line_string: true,
        polygon: true,
        trash: true
      }
    })
    
    this.map.addControl(this.draw, 'top-left')
    
    // Listen for drawing events
    this.map.on('draw.create', this.updateGeometry.bind(this))
    this.map.on('draw.update', this.updateGeometry.bind(this))
    this.map.on('draw.delete', this.updateGeometry.bind(this))
  }
  
  /**
   * Update the geometry input when the drawing changes
   */
  updateGeometry() {
    const data = this.draw.getAll()
    
    if (data.features.length > 0) {
      // Get the first feature's geometry
      const geometry = data.features[0].geometry
      this.inputTarget.value = JSON.stringify(geometry)
      this.updateCoordinatesDisplay(geometry)
    } else {
      this.inputTarget.value = ''
      this.coordinatesTarget.textContent = 'No geometry defined'
    }
  }
  
  /**
   * Load existing geometry from the input
   */
  loadExistingGeometry() {
    // Check if we have initial geometry from the data attribute
    let geometry = this.initialValue
    
    // If not, check the input field
    if (!geometry && this.inputTarget.value) {
      try {
        geometry = JSON.parse(this.inputTarget.value)
      } catch (e) {
        console.error('Invalid GeoJSON in input field', e)
      }
    }
    
    if (geometry) {
      // Add the geometry to the map
      const feature = {
        type: 'Feature',
        geometry: geometry,
        properties: {}
      }
      
      this.map.on('load', () => {
        // Add the feature to the draw tool
        this.draw.add(feature)
        
        // Fit the map to the geometry
        this.fitMapToGeometry(geometry)
        
        // Update the coordinates display
        this.updateCoordinatesDisplay(geometry)
      })
    }
  }
  
  /**
   * Fit the map to the geometry
   */
  fitMapToGeometry(geometry) {
    if (!geometry || !geometry.coordinates) return
    
    // Create a bounding box for the geometry
    let bounds
    
    switch (geometry.type) {
      case 'Point':
        // For a point, center the map on the point
        this.map.flyTo({
          center: geometry.coordinates,
          zoom: 15
        })
        return
        
      case 'LineString':
        bounds = new mapboxgl.LngLatBounds()
        geometry.coordinates.forEach(coord => {
          bounds.extend(coord)
        })
        break
        
      case 'Polygon':
        bounds = new mapboxgl.LngLatBounds()
        geometry.coordinates[0].forEach(coord => {
          bounds.extend(coord)
        })
        break
        
      case 'MultiPoint':
      case 'MultiLineString':
        bounds = new mapboxgl.LngLatBounds()
        geometry.coordinates.forEach(coords => {
          coords.forEach(coord => {
            bounds.extend(coord)
          })
        })
        break
        
      case 'MultiPolygon':
        bounds = new mapboxgl.LngLatBounds()
        geometry.coordinates.forEach(polygon => {
          polygon[0].forEach(coord => {
            bounds.extend(coord)
          })
        })
        break
    }
    
    if (bounds) {
      this.map.fitBounds(bounds, {
        padding: 50
      })
    }
  }
  
  /**
   * Update the coordinates display
   */
  updateCoordinatesDisplay(geometry) {
    if (!geometry) {
      this.coordinatesTarget.textContent = 'No geometry defined'
      return
    }
    
    let text = `Type: ${geometry.type}`
    
    switch (geometry.type) {
      case 'Point':
        text += `<br>Longitude: ${geometry.coordinates[0].toFixed(6)}`
        text += `<br>Latitude: ${geometry.coordinates[1].toFixed(6)}`
        break
        
      case 'LineString':
        text += `<br>Points: ${geometry.coordinates.length}`
        text += `<br>Length: ${this.calculateLength(geometry).toFixed(2)} km`
        break
        
      case 'Polygon':
        text += `<br>Points: ${geometry.coordinates[0].length}`
        text += `<br>Area: ${this.calculateArea(geometry).toFixed(2)} km²`
        break
        
      default:
        text += `<br>Complex geometry type`
    }
    
    this.coordinatesTarget.innerHTML = text
  }
  
  /**
   * Calculate the length of a LineString in kilometers
   */
  calculateLength(geometry) {
    if (geometry.type !== 'LineString') return 0
    
    let length = 0
    for (let i = 0; i < geometry.coordinates.length - 1; i++) {
      const start = geometry.coordinates[i]
      const end = geometry.coordinates[i + 1]
      length += this.haversineDistance(start[1], start[0], end[1], end[0])
    }
    
    return length
  }
  
  /**
   * Calculate the area of a Polygon in square kilometers
   */
  calculateArea(geometry) {
    if (geometry.type !== 'Polygon') return 0
    
    // This is a simple approximation and not accurate for large areas
    // For production use, consider using a proper geospatial library
    const coordinates = geometry.coordinates[0]
    let area = 0
    
    for (let i = 0; i < coordinates.length - 1; i++) {
      const p1 = coordinates[i]
      const p2 = coordinates[i + 1]
      area += p1[0] * p2[1] - p2[0] * p1[1]
    }
    
    area = Math.abs(area) / 2
    
    // Convert to square kilometers (very rough approximation)
    // This assumes coordinates are in degrees and Earth is a sphere
    const earthRadius = 6371 // km
    return area * (Math.PI / 180) * (Math.PI / 180) * earthRadius * earthRadius
  }
  
  /**
   * Calculate the distance between two points using the Haversine formula
   */
  haversineDistance(lat1, lon1, lat2, lon2) {
    const R = 6371 // Radius of the Earth in km
    const dLat = this.deg2rad(lat2 - lat1)
    const dLon = this.deg2rad(lon2 - lon1)
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    return R * c
  }
  
  /**
   * Convert degrees to radians
   */
  deg2rad(deg) {
    return deg * (Math.PI / 180)
  }
}