class Youngagrarians.Views.Map extends Backbone.Marionette.CompositeView
  template: "backbone/templates/map"
  itemView: Youngagrarians.Views.MapMarker
  map: null

  currentStep: 1
  previousStep: 0
  locationToAdd: null
  locationModel: null

  initialize: (options) ->
    @collection.on 'reset', (models) =>
      _.defer () =>
        console.log 'children: ', @children
        @children.each ( child ) =>
          console.log 'child: ', child
          marker = child.createMarker()
          console.log 'marker: ', marker

        center = $("#go-search").data('province') + ", Canada"
        $.goMap.setMap
          address: center
          zoom: 5
        #$.goMap.fitBounds 'visible'


  events:
    'click a#add-to-map' : 'addLocation'
    'click button.next'  : 'showNextStep'
    'click button.prev'  : 'showPrevStep'
    'click button#go-search' : 'doSearch'
    'click a#map-search-clear' : 'clearSearch'
    'click li.province' : 'changeProvince'

  changeProvince: (e) =>
    province = $(e.target).text()
    $("button#go-search").data('province', province).html("Search in "+province)

  clearSearch: (e) =>
    e.preventDefault()
    @collection.clearShow()

  doSearch: (e) =>
    e.preventDefault()
    console.log 'search time!'
    terms = $("#map-search-terms").val()

    province = $(e.target).data('province') + ", Canada"
    $.goMap.setMap
      address: province
      zoom: 5

    console.log 'searching for: ', terms
    $.ajax
      type: "POST"
      url: "/~youngagr/search"
      data:
        terms: terms
      success: (data,status,xhr) =>
        @collection.setShow _(data).pluck('_id')

  showNextStep: (e) =>
    e.preventDefault()

    $("#step" + @currentStep).fadeOut()
    @previousStep = @currentStep
    @currentStep += 1
    @doStep()
    $("#step" + @currentStep).fadeIn()

  showPrevStep: (e) =>
    e.preventDefault()
    $("#step" + @currentStep).fadeOut()
    @previousStep = @currentStep
    @currentStep -= 1
    @doStep()
    $("#step" + @currentStep).fadeIn()

  doStep: () =>
    if @currentStep == 1
      @locationModel = new Youngagrarians.Models.Location

      $("input#location").val("")

      if !_.isNull @locationToAdd
        $.goMap.removeMarker @locationToAdd

    if @currentStep == 2
      _( $.goMap.getVisibleMarkers() ).each (id) ->
        $.goMap.showHideMarker id

      location = $("input#location").val()

      if !_.isEmpty location
        @locationToAdd = location
        $.goMap.setMap
          address: location
          zoom: 16

        $.goMap.createMarker
          address: location
          id: location

    if @currentStep == 3
      @locationModel.set 'address', @locationToAdd

    if @currentStep == 4
      $.goMap.setMap
        address: @locationToAdd

      @locationModel.set 'latitude', $.goMap.getMap().center.lat
      @locationModel.set 'longitude', $.goMap.getMap().center.lng

      category = window.Categories.get $("select#category").val()

      @locationModel.set 'category_id', $("select#category").val()
      @locationModel.set 'category', category
      @locationModel.set 'name', $("input#name").val()
      @locationModel.set 'content', $('textarea#description').val()

      window.Locations.create @locationModel

      func = () ->
        $("#add-to-map").fadeIn()
        $("#step4").fadeOut()
        @currentStep = 1

      _.delay func, 10000


  addLocation: (e) =>
    e.preventDefault()
    $("#add-to-map").fadeOut()
    @currentStep = 1
    @doStep()

    $("#add-to-map-form").slideDown()

    select = $("select#category")
    window.Categories.each (model) =>
      opt = $("<option>")
        .attr( 'value', model.get('_id'))
        .html model.get('name')
      select.append opt

  onShow: () =>
    @show = []
    @map = $("#map").goMap
      latitude: 54.826008
      longitude: -125.200195
      zoom: 5
      maptype: 'ROADMAP'

    $.goMap.createListener(
      {type:'map'}
      'zoom_changed'
      (event) =>
        @collection.trigger 'map:update', {type: 'zoom', data: event}
    )

    $.goMap.createListener(
      {type: 'map'}
      'dragend'
      (event) =>
        @collection.trigger 'map:update', {type: 'dragend', data: event}
    )

    console.log 'collection: ', @collection.length
    if @collection.length
      _(@children).each (child) ->
        child.createMarker()
      $.goMap.fitBounds 'visible'

  filter: (data) =>
    @collection.trigger 'map:update', {type: 'filter', data: data}
