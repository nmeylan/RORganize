class @IssuesSubnav
  @setup: (scope) ->
    if (container = scope.find("[data-role=issue-list-type-nav]")).length
      @instance = new IssuesSubnav(container)

  constructor: (@container) ->
    @initUi()
    @bindEvents()

  initUi: ->
    @ui =
      links: @container.find("a")

  bindEvents: ->
    @ui.links.on "ajax:success", (event, response) ->
      window.IssuesList.instance.updateList($(response.list))