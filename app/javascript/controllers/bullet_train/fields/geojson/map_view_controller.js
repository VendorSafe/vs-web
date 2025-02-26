import { Controller } from "@hotwired/stimulus"
import mapboxgl from "mapbox-gl"

export default class extends Controller {
  static targets = ["container", "filter"]
  static values = {
    apiKey: String,
    locationsUrl: String
  }
  
  connect() {
    mapboxgl.accessToken = this.apiKeyValue
    
    this.map = new mapboxgl.Map({
      container: this.containerTarget,
      style: 'mapbox://styles/mapbox/streets-v11',
      center: [-96, 37.8], // Center of US
      zoom: 3
    })
    
    this.map.on('load', () => {
      this.loadLocations()
    })
  }
  
  loadLocations() {
    const filterValue = this.hasFilterTarget ? this.filterTarget.value : ''
    
    let url = this.locationsUrlValue
    if (filterValue) {
      url += `?location_type=${filterValue}`
    }
    
    fetch(url, {
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(locations => {
      // Create GeoJSON feature collection
      const features = locations
        .filter(location => location.geometry && location.geometry.type)
        .map(location => ({
          type: 'Feature',
          geometry: location.geometry,
          properties: {
            id: location.id,
            name: location.name,
            location_type: location.location_type,
            address: location.address,
            url: `/account/locations/${location.id}`
          }
        }))
      
      const geojson = {
        type: 'FeatureCollection',
        features: features
      }
      
      // Add source and layers
      if (this.map.getSource('locations')) {
        this.map.getSource('locations').setData(geojson)
      } else {
        this.map.addSource('locations', {
          type: 'geojson',
          data: geojson,
          cluster: true,
          clusterMaxZoom: 14,
          clusterRadius: 50
        })
        
        // Add cluster layer
        this.map.addLayer({
          id: 'clusters',
          type: 'circle',
          source: 'locations',
          filter: ['has', 'point_count'],
          paint: {
            'circle-color': [
              'step',
              ['get', 'point_count'],
              '#51bbd6',
              10,
              '#f1f075',
              30,
              '#f28cb1'
            ],
            'circle-radius': [
              'step',
              ['get', 'point_count'],
              20,
              10,
              30,
              30,
              40
            ]
          }
        })
        
        // Add cluster count layer
        this.map.addLayer({
          id: 'cluster-count',
          type: 'symbol',
          source: 'locations',
          filter: ['has', 'point_count'],
          layout: {
            'text-field': '{point_count_abbreviated}',
            'text-font': ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
            'text-size': 12
          }
        })
        
        // Add unclustered point layer
        this.map.addLayer({
          id: 'unclustered-point',
          type: 'circle',
          source: 'locations',
          filter: ['!', ['has', 'point_count']],
          paint: {
            'circle-color': '#11b4da',
            'circle-radius': 8,
            'circle-stroke-width': 1,
            'circle-stroke-color': '#fff'
          }
        })
        
        // Add polygon layer
        this.map.addLayer({
          id: 'location-polygons',
          type: 'fill',
          source: 'locations',
          filter: ['==', ['geometry-type'], 'Polygon'],
          paint: {
            'fill-color': '#088',
            'fill-opacity': 0.4,
            'fill-outline-color': '#088'
          }
        })
        
        // Add click event for popups
        this.map.on('click', 'unclustered-point', (e) => {
          const properties = e.features[0].properties
          
          new mapboxgl.Popup()
            .setLngLat(e.lngLat)
            .setHTML(`
              <h3 class="font-bold">${properties.name}</h3>
              <p>Type: ${properties.location_type}</p>
              <p>Address: ${properties.address}</p>
              <a href="${properties.url}" class="text-blue-500 hover:underline">View Details</a>
            `)
            .addTo(this.map)
        })
        
        // Change cursor on hover
        this.map.on('mouseenter', 'unclustered-point', () => {
          this.map.getCanvas().style.cursor = 'pointer'
        })
        
        this.map.on('mouseleave', 'unclustered-point', () => {
          this.map.getCanvas().style.cursor = ''
        })
      }
      
      // Fit bounds to show all locations
      if (features.length > 0) {
        const bounds = new mapboxgl.LngLatBounds()
        
        features.forEach(feature => {
          if (feature.geometry.type === 'Point') {
            bounds.extend(feature.geometry.coordinates)
          } else if (feature.geometry.type === 'Polygon') {
            feature.geometry.coordinates[0].forEach(coord => {
              bounds.extend(coord)
            })
          }
        })
        
        this.map.fitBounds(bounds, { padding: 50 })
      }
    })
    .catch(error => {
      console.error('Error loading locations:', error)
    })
  }
  
  filterByType() {
    this.loadLocations()
  }
}