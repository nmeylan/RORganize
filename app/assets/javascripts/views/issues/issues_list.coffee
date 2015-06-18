class @IssuesList extends List

  @setup: (scope) ->
    if (container = scope.find("[data-role=issues-list]")).length || ((container = scope).is("[data-role=issues-list]"))
      @instance = new IssuesList(container)

  constructor: (@container) ->
    super(@container)
    @initUi()
    @bindEvents()
    checkAll("#check-all", ".list")
    listTrClick(".list .issue-tr")
    checkboxToolbox(".list")
    init_toolbox('.issue.list .issue-tr', 'issues-toolbox', {list: '.issue.list'})
    uniq_toogle("#issue.toggle", ".content")

  initUi: =>
    @ui =
      sortLink: @container.find("[data-action=sort-list]")

  bindEvents: =>
    @ui.sortLink.on "ajax:success", @handleUpdateList

  handleUpdateList: (event, response) =>
    @updateList($(response.list))

  updateList: (data) =>
    @container.replaceWith(data)
    window.App.setup(data)