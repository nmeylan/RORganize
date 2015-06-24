class @VersionsList extends List

  @setup: (scope) ->
    if (container = scope.find("[data-role=versions-list]")).length || ((container = scope).is("[data-role=versions-list]"))
      @instance = new VersionsList(container)

  constructor: (@container) ->
    super(@container)