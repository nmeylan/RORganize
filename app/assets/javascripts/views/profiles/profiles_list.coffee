class @ProfilesList extends List

  @setup: (scope) ->
    if (container = scope.find("[data-role=profiles-list]")).length || ((container = scope).is("[data-role=profiles-list]"))
      @instance = new ProfilesList(container)

  constructor: (@container) ->
    super(@container)