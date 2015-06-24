class @UsersList extends List

  @setup: (scope) ->
    if (container = scope.find("[data-role=users-list]")).length || ((container = scope).is("[data-role=users-list]"))
      @instance = new UsersList(container)

  constructor: (@container) ->
    super(@container)