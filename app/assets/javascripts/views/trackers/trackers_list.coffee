class @TrackersList extends List

  @setup: (scope) ->
    if (container = scope.find("[data-role=trackers-list]")).length || ((container = scope).is("[data-role=trackers-list]"))
      @instance = new TrackersList(container)

  constructor: (@container) ->
    super(@container)