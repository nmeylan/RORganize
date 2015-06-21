class @IssuesList extends List

  @setup: (scope) ->
    if (container = scope.find("[data-role=issues-list]")).length || ((container = scope).is("[data-role=issues-list]"))
      @instance = new IssuesList(container)

  constructor: (@container) ->
    super(@container)
    @initUi()
    @bindEvents()
    @toolbox = new Toolbox(@ui.issuesListTable, @toolboxSubmitCallback)

  initUi: =>
    @ui =
      issuesListTable: @container.find("[data-role=list-table]")

  bindEvents: =>


  toolboxSubmitCallback: (event, response) =>
    $("[data-role=total-entries]").replaceWith($(response.countEntries))
    @updateList($(response.list))