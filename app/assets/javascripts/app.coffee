# Override default bootstrap tooltip position
$.fn.tooltip.Constructor.DEFAULTS.placement = "bottom"

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
    IssuesSubnav.setup(@scope)
    Filter.setup(@scope)
    QueryOverlay.setup(@scope)

  _setup_common: ->
  # tooltips
    $(document).ready =>
      @scope.find("[data-toggle=tooltip]").tooltip({html: true, container: "body"})
      @scope.find('[data-toggle="popover"]').popover({container: "body"})

      DynamicModal.setup(@scope)

      $(".chzn-select").chosen disable_search_threshold: 5
      $(".chzn-select-deselect").chosen
        allow_single_deselect: true
        disable_search_threshold: 5
