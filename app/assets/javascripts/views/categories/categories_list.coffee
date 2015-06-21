class @CategoriesList extends List

  @setup: (scope) ->
    if (container = scope.find("[data-role=categories-list]")).length || ((container = scope).is("[data-role=categories-list]"))
      @instance = new CategoriesList(container)

  constructor: (@container) ->
    super(@container)