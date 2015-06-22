class @Activities

  @setup: (scope) ->
    if (container = scope.find("[data-role=activities]")).length || ((container = scope).is("[data-role=activities]"))
      @instance = new Activities(container, scope)

  constructor: (@container, scope) ->
    @initUi()
    @bindEvents()
    bindActivitiesFilter(@, scope)

  initUi: ->
    @ui =
      circles: @container.find('.date-circle')

  bindEvents: ->
    @ui.circles.click (e) ->
      e.preventDefault()
      el = $(this)
      next = el.next('.journals')
      if next.is(':visible')
        el.addClass 'collasped_circle'
        next.fadeOut()
      else
        el.removeClass 'collasped_circle'
        next.fadeIn()

    @ui.circles.hover ((e) ->
      el = $(this)
      el.next('.journals').addClass 'hover'

    ), (e) ->
      el = $(this)
      el.next('.journals').removeClass 'hover'

  update: (data) ->
    @container.replaceWith(data)
    window.App.setup(data)

@bindActivitiesFilter = (activities, scope) ->
  filters = scope.find("[data-role=activities-filter]")

  filters.unbind()
  filters.change (e) ->
    form = $('form#activities-filter')
    form.submit()

  filters.on "ajax:success", (event, response) ->
    Activities.instance.update($(response.activities))