import { Controller } from "@hotwired/stimulus"

/**
 * Map Display Controller
 * 
 * This controller provides a map-based display for GeoJSON data.
 * It allows viewing locations on a map with their boundaries and properties.
 * 
 * Dependencies:
 * - Mapbox GL JS (https://docs.mapbox.com/mapbox-gl-js/api/)
 * 
 * Usage:
 * <div data-controller="bullet-train--fields--geojson--map-display" 
 *      data-bullet-train--fields--geojson--map-display-api-key-value="YOUR_MAPBOX_API_KEY"
 *      data-bullet-train--fields--geojson--map-display-geojson-value='{"type":"FeatureCollection","features":[...]}'>
 *   <div data-bullet-train--fields--geojson--map-display-target="map" style="height: 400px;"></div>
 *   <div data-bullet-train--fields--geojson--map-display-target="info" class="text-sm mt-2"></div>
 * </div>
 */
export default class extends Controller {
  static targets = ["map", "info"]
  
  static values = {
    apiKey: String,
    geojson: Object,
    center: { type: Array, default: [-122.4194, 37.7749] }, // Default: San Francisco
    zoom: { type: Number, default: 12 }
  }
  
  connect() {
    // Load Mapbox GL JS
    this.loadMapboxScript().then(() => {
      this.initializeMap()
      this.addGeoJSONLayer()
    })
  }
  
  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
  
  /**
   * Load Mapbox GL JS script dynamically
   */
  loadMapboxScript() {
    return new Promise((resolve) => {
      // Check if Mapbox is already loaded
      if (window.mapboxgl) {
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
      
      // Wait for scripts to load
      mapboxScript.onload = () => {
        resolve()
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
  }
  
  /**
   * Add GeoJSON data to the map
   */
  addGeoJSONLayer() {
    const geojson = this.geojsonValue
    
    // Wait for the map to load
    this.map.on('load', () => {
      // Convert single feature to feature collection if needed
      let featureCollection
      if (geojson.type === 'Feature') {
        featureCollection = {
          type: 'FeatureCollection',
          features: [geojson]
        }
      } else if (geojson.type === 'FeatureCollection') {
        featureCollection = geojson
      } else {
        // If it's just a geometry, wrap it in a feature and feature collection
        featureCollection = {
          type: 'FeatureCollection',
          features: [{
            type: 'Feature',
            geometry: geojson,
            properties: {}
          }]
        }
      }
      
      // Add the GeoJSON source
      this.map.addSource('geojson-data', {
        type: 'geojson',
        data: featureCollection
      })
      
      // Add layers based on geometry types
      this.addPointLayer()
      this.addLineLayer()
      this.addPolygonLayer()
      
      // Fit the map to the GeoJSON data
      this.fitMapToData(featureCollection)
      
      // Add click handler for features
      this.map.on('click', 'geojson-points', this.handleFeatureClick.bind(this))
      this.map.on('click', 'geojson-lines', this.handleFeatureClick.bind(this))
      this.map.on('click', 'geojson-polygons', this.handleFeatureClick.bind(this))
      
      // Change cursor on hover
      this.map.on('mouseenter', 'geojson-points', () => {
        this.map.getCanvas().style.cursor = 'pointer'
      })
      this.map.on('mouseleave', 'geojson-points', () => {
        this.map.getCanvas().style.cursor = ''
      })
      
      this.map.on('mouseenter', 'geojson-lines', () => {
        this.map.getCanvas().style.cursor = 'pointer'
      })
      this.map.on('mouseleave', 'geojson-lines', () => {
        this.map.getCanvas().style.cursor = ''
      })
      
      this.map.on('mouseenter', 'geojson-polygons', () => {
        this.map.getCanvas().style.cursor = 'pointer'
      })
      this.map.on('mouseleave', 'geojson-polygons', () => {
        this.map.getCanvas().style.cursor = ''
      })
    })
  }
  
  /**
   * Add a layer for point geometries
   */
  addPointLayer() {
    this.map.addLayer({
      id: 'geojson-points',
      type: 'circle',
      source: 'geojson-data',
      filter: ['==', '$type', 'Point'],
      paint: {
        'circle-radius': 8,
        'circle-color': '#3887be',
        'circle-stroke-width': 2,
        'circle-stroke-color': '#ffffff'
      }
    })
  }
  
  /**
   * Add a layer for line geometries
   */
  addLineLayer() {
    this.map.addLayer({
      id: 'geojson-lines',
      type: 'line',
      source: 'geojson-data',
      filter: ['==', '$type', 'LineString'],
      layout: {
        'line-join': 'round',
        'line-cap': 'round'
      },
      paint: {
        'line-color': '#3887be',
        'line-width': 3
      }
    })
  }
  
  /**
   * Add a layer for polygon geometries
   */
  addPolygonLayer() {
    // Add fill layer
    this.map.addLayer({
      id: 'geojson-polygons',
      type: 'fill',
      source: 'geojson-data',
      filter: ['==', '$type', 'Polygon'],
      paint: {
        'fill-color': '#3887be',
        'fill-opacity': 0.2
      }
    })
    
    // Add outline layer
    this.map.addLayer({
      id: 'geojson-polygon-outlines',
      type: 'line',
      source: 'geojson-data',
      filter: ['==', '$type', 'Polygon'],
      layout: {
        'line-join': 'round',
        'line-cap': 'round'
      },
      paint: {
        'line-color': '#3887be',
        'line-width': 2
      }
    })
  }
  
  /**
   * Fit the map to the GeoJSON data
   */
  fitMapToData(featureCollection) {
    if (!featureCollection.features || featureCollection.features.length === 0) {
      return
    }
    
    // Create a bounding box for all features
    const bounds = new mapboxgl.LngLatBounds()
    
    featureCollection.features.forEach(feature => {
      if (!feature.geometry || !feature.geometry.coordinates) return
      
      const geometry = feature.geometry
      
      switch (geometry.type) {
        case 'Point':
          bounds.extend(geometry.coordinates)
          break
          
        case 'LineString':
          geometry.coordinates.forEach(coord => {
            bounds.extend(coord)
          })
          break
          
        case 'Polygon':
          geometry.coordinates[0].forEach(coord => {
            bounds.extend(coord)
          })
          break
          
        case 'MultiPoint':
          geometry.coordinates.forEach(coord => {
            bounds.extend(coord)
          })
          break
          
        case 'MultiLineString':
          geometry.coordinates.forEach(line => {
            line.forEach(coord => {
              bounds.extend(coord)
            })
          })
          break
          
        case 'MultiPolygon':
          geometry.coordinates.forEach(polygon => {
            polygon[0].forEach(coord => {
              bounds.extend(coord)
            })
          })
          break
      }
    })
    
    // Only fit bounds if we have coordinates
    if (!bounds.isEmpty()) {
      this.map.fitBounds(bounds, {
        padding: 50
      })
    }
  }
  
  /**
   * Handle click on a feature
   */
  handleFeatureClick(e) {
    if (!e.features || e.features.length === 0) return
    
    const feature = e.features[0]
    const properties = feature.properties || {}
    
    // Format properties for display
    let html = '<div class="font-medium">Feature Properties</div>'
    html += '<div class="mt-1">'
    
    // Add geometry type
    html += `<div><strong>Type:</strong> ${feature.geometry.type}</div>`
    
    // Add properties
    Object.keys(properties).forEach(key => {
      html += `<div><strong>${key}:</strong> ${properties[key]}</div>`
    })
    
    html += '</div>'
    
    // Update info element
    this.infoTarget.innerHTML = html
  }
}