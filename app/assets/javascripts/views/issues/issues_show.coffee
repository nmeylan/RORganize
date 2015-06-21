class @IssuesShow

  @setup: (scope) ->
    if (container = scope.find("[data-role=issues-show]")).length
      @instance = new IssuesShow(container)

  constructor: (@container) ->
    @initUi()
    @bindEvents()

  initUi: ->

  bindEvents: ->
