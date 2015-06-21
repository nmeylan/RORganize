class @DocumentsList extends List

  @setup: (scope) ->
    if (container = scope.find("[data-role=documents-list]")).length || ((container = scope).is("[data-role=documents-list]"))
      @instance = new DocumentsList(container)

  constructor: (@container) ->
    super(@container)
    @initUi()
    @bindEvents()
    @toolbox = new Toolbox(@ui.documentsListTable, @toolboxSubmitCallback)

  initUi: =>
    @ui =
      documentsListTable: @container.find("[data-role=list-table]")

  bindEvents: =>


  toolboxSubmitCallback: (event, response) =>
    $("[data-role=total-entries]").replaceWith($(response.countEntries))
    @updateList($(response.list))