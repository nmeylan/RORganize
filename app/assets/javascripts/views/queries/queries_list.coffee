class @QueriesList extends List

  @setup: (scope) ->
    if ((container = scope.find("[data-role=queries-list]")).length || ((container = scope).is("[data-role=queries-list]"))) ||
        ((container = scope.find("[data-role=settings-list]")).length || ((container = scope).is("[data-role=settings-list]")))
      @instance = new QueriesList(container)

  constructor: (@container) ->
    super(@container)