class @IssuesStatusesList extends List

  @setup: (scope) ->
    if (container = scope.find("[data-role=issues-statuses-list]")).length || ((container = scope).is("[data-role=issues-statuses-list]"))
      @instance = new IssuesStatusesList(container)

  constructor: (@container) ->
    super(@container)