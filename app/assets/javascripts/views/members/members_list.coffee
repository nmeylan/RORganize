class @MembersList extends List

  @setup: (scope) ->
    if (container = scope.find("[data-role=members-list]")).length || ((container = scope).is("[data-role=members-list]"))
      @instance = new MembersList(container)

  constructor: (@container) ->
    super(@container)
