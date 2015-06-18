window.App =
  setup: (scope = null, namespace = null) ->
    @scope = $(scope)
    @namespace = namespace if namespace
    @_setup_common()
    if window.App["_setup_#{@namespace}"]
      window.App["_setup_#{@namespace}"]()
    else
      throw "App.setup: setup for namespace '#{namespace}' not found!"

  _setup_front: ->
    IssuesList.setup(@scope)
    Filter.setup(@scope)

  _setup_common: ->
# tooltips
    @scope.find("[data-toggle=tooltip]").tooltip({html: true})

    DynamicModal.setup(@scope)