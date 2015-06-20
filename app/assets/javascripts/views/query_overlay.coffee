class @QueryOverlay

  @setup: (scope) ->
    if (container = scope.find("[data-role=query-creation-form]")).length || ((container = scope).is("[data-role=query-creation-form]"))
      @instance = new QueryOverlay(container)

  constructor: (@container) ->
    @bindEvents()

  bindEvents: ->
    @container.on "submit", @handleFormSubmission

  handleFormSubmission: (e) ->
    e.preventDefault()
    el = $(this)
    json = window.Filter.instance.ui.filterForm.serializeJSON()
    json2 = el.serializeJSON()
    forms = jQuery.extend(json, json2)
    jQuery.ajax
      url: el[0].action
      type: 'post'
      dataType: 'script'
      data: forms