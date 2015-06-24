class @RolesList extends List

  @setup: (scope) ->
    if (container = scope.find("[data-role=roles-list]")).length || ((container = scope).is("[data-role=roles-list]"))
      @instance = new RolesList(container)

  constructor: (@container) ->
    super(@container)