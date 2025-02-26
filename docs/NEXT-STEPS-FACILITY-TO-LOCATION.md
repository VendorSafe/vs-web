# Next Steps: Facility to Location Consolidation

**Date:** February 25, 2025  
**Author:** Roo  
**Status:** In Progress  

This document outlines the next steps for completing the Facility to Location consolidation project. The core implementation has been completed, but several tasks remain to fully integrate the new Locations model into the application.

## 1. Update Location Forms with GeoJSON Support

- Add map input component to location forms
- Add map display component to location show pages
- Update location edit forms to support GeoJSON data

## 2. Add Map Visualization

- Implement a map view for locations
- Add clustering for multiple locations
- Add filtering by location type

## 3. Update Navigation and Routes

- Add locations to the main navigation
- Update routes to include new location endpoints

## 4. Deprecate Facilities API

- Add deprecation notices to Facilities API endpoints
- Create a migration guide for API consumers
- Set a timeline for complete removal

## 5. Create System Tests

- Add system tests for location creation and editing
- Add system tests for map visualization

## 6. Update Documentation

- Update API documentation
- Create user guides for working with locations and maps
- Document the GeoJSON fields gem

## 7. Prepare GeoJSON Fields Gem for Contribution

- Clean up code and add comments
- Write comprehensive tests
- Create documentation
- Prepare for submission to the Bullet Train community

## Timeline

| Task | Estimated Completion | Priority |
|------|----------------------|----------|
| Update Location Forms | 1 week | High |
| Add Map Visualization | 2 weeks | Medium |
| Update Navigation | 1 day | High |
| Deprecate Facilities API | 1 week | Medium |
| Create System Tests | 1 week | Medium |
| Update Documentation | 1 week | Medium |
| Prepare Gem for Contribution | 2 weeks | Low |