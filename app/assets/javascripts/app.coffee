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
    DocumentsList.setup(@scope)
    IssuesPredecessor.setup(@scope)
    IssuesList.setup(@scope)
    IssuesSubnav.setup(@scope)
    QueryOverlay.setup(@scope)
    # Shared
    Attachment.setup(@scope)
    Filter.setup(@scope)
    AddCommentForm.setup(@scope)
    CommentBlock.setup(@scope)
    ToggleButton.setup(@scope)

  _setup_common: ->
  # tooltips
    $(document).ready =>
      if (scope = @scope.find("[data-toggle=tooltip]")).length || (scope = @scope).is("[data-toggle=tooltip]")
        scope.tooltip({html: true, container: "body"})

      @scope.find('[data-toggle="popover"]').popover({container: "body"})

      DynamicModal.setup(@scope)
      bindAttachementEvents(@scope)
      bindNewCommentLink(@scope)
      bindSelect(@scope)
      markdownTextarea(@scope)