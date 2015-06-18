class @Filter

  @setup: (scope) ->
    if (container = scope.find("[data-role=filters]")).length || ((container = scope).is("[data-role=filters]"))
      @instance = new Filter(container)

  constructor: (@container) ->
    @initUi()
    @bindEvents()

  initUi: =>
    @ui =
      createQueryButton: @container.find("[data-action=create-query]")
      filterForm: @container.find("[data-role=filter-form]")

  bindEvents: =>
    console.log(@ui)
    @ui.filterForm.on "ajax:success", @handleApplyForm
    @ui.createQueryButton.on "ajax:success", @handleNewQuery

  handleApplyForm: (event, response) =>
    filter = response.filter
    @container.replaceWith(filter = $(filter))
    window.App.setup(filter)


  handleNewQuery: (response) ->
    console.log(response)