class @IssuesPredecessor

  @setup: (scope) ->
    if (container = scope.find("[data-role=predecessor]")).length || ((container = scope).is("[data-role=predecessor]"))
      @instance = new IssuesPredecessor(container)

  constructor: (@container) ->
    @initUi()
    @bindEvents()

  initUi: ->
    @ui =
      predecessorForm: @container.find("[data-role=predecessor-form]")
      deletePredecessorLink: @container.find("[data-action=delete]")

  bindEvents: ->
    @ui.deletePredecessorLink.on "ajax:success", @handlePredecessorFormSubmission
    @ui.predecessorForm.on "ajax:success", @handlePredecessorFormSubmission

  handlePredecessorFormSubmission: (event, response) =>
    @container.html(response.content)
    onReplaceEffect("#history", response.history_block);
    IssuesPredecessor.setup(@container)