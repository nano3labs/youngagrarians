class Youngagrarians.Views.Map extends Backbone.Marionette.CompositeView
  template: "backbone/templates/map"
  itemView: Youngagrarians.Views.MapMarker
  map: null

  collectionEvents:
    'reset' : 'updateMap'

  initialize: (options) =>
    @app = options.app
    @markers = []
    @marker_clusterers = []

  updateMap: =>
    window.infoBubble.close() if window.infoBubble
    @clearMarkers()

    if @collection.currentBioregion
      @_zoomOnBioregion()
    else if @collection.currentSubdivision
      @_zoomOnSubdivision()
    else
      @_zoomOnBestLocationsFit()

    _.defer =>
      @_drawMarkers()

  _drawMarkers: =>
    @children.each (child) =>
      @markers.push(child.createMarker())

    @clusterMarkersByCategories()

  _zoomOnBioregion: =>
    @map.setCenter new google.maps.LatLng(@collection.currentBioregion.center.latitude, @collection.currentBioregion.center.longitude)
    @map.setZoom @collection.currentBioregion.zoom

  _zoomOnSubdivision: =>
    bounds = new google.maps.LatLngBounds()
    bounds.extend new google.maps.LatLng(@collection.currentSubdivision.bounds.south, @collection.currentSubdivision.bounds.east)
    bounds.extend new google.maps.LatLng(@collection.currentSubdivision.bounds.north, @collection.currentSubdivision.bounds.west)
    @map.fitBounds(bounds)

  _zoomOnBestLocationsFit: =>
    bounds = new google.maps.LatLngBounds()

    locations = @collection.where({resource_type: "Location"})
    _(locations).each (location) =>
      if location.lat() and location.lng()
        coords = new google.maps.LatLng(location.lat(), location.lng())
        bounds.extend coords

    if locations.length > 0
      @map.fitBounds(bounds)
      @map.setZoom 10 if @map.getZoom() > 10
    else
      @map.fitBounds(Youngagrarians.Constants.DEFAULT_BOUNDS())

  clearMarkers: =>
    cluster.clearMarkers() for cluster in @marker_clusterers
    @marker_clusterers = []
    $.goMap.clearMarkers()
    @markers = []

  clusterMarkersByCategories: =>
    markers_per_category = {}
    _.each Youngagrarians.Collections.categories.pluck('name'), (category_name) =>
      category_markers = []

      _.each @children.toArray(), (child) =>
        category_markers.push(child.marker) if child.model.get('category').get('name') == category_name

      if category_markers.length > 0
        category = Youngagrarians.Collections.categories.findWhere(name: category_name)
        @marker_clusterers.push @clusterMarkersByCategory(category_markers, category)

  clusterMarkersByCategory: (markers, category) =>
    options =
      averageCenter: true
      gridSize: 120
      styles: [{
        height: 40,
        url: category.getMapIcon(),
        width: 40
        textColor: 'black'
        textSize: 18
        }
      ]
    return marker_cluster = new MarkerClusterer(@map, markers, options)

  onShow: =>
    @show = []
    @$("#map").goMap
      latitude: 55.8997541
      longitude: -97.1374937
      zoom: 4
      maptype: 'ROADMAP'
      scrollwheel: false

    @map = $.goMap.getMap()

  openBubble: (location) => @children.findByModel(location).openBubble()

