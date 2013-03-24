class Youngagrarians.Views.Sidebar extends Backbone.Marionette.View
  tagName: 'ul'
  className: 'nav nav-stacked nav-pills'

  events:
    'click li.category' : 'showHide'

  initialize: () ->
    @options.locations.on 'reset', @reset, @

  reset: (col,data) =>
    title = @make('li', {'class': 'nav-header'}, 'Categories')
    @$el.empty()
    @$el.append title
    @addAll()

  addAll: (col,data) =>
    @types = @options.locations.pluck 'type'
    _(@types).each @addOne

  addOne: (type) =>
    a = @make 'a', {href: '#'}, type
    li =  @make 'li', {class: 'category', 'data-type': type}, a
    @$el.append li

  make: (tagName, attributes, content) ->
    $el = Backbone.$ "<" + tagName + "/>"
    if attributes
      $el.attr attributes
    if content != null
      $el.html content
    $el[0]

  render: =>
    @reset()


  showHide: (ev) =>
    target = $ ev.target.parentNode
    type = target.data 'type'
    target.toggleClass 'active'

    filter = @types

    $(ev.target.parentNode.parentNode).find("li.category").each (index,li) =>
      if $(li).hasClass 'active'
        filter = _(filter).without $(li).data 'type'

    if filter is @types
      filter = []

    @trigger 'filter', filter

    #@options.locations.setModelShow @filter
