class @Attachment

  @setup: (scope) ->
    if (container = scope.find("[data-role=attachments]")).length || ((container = scope).is("[data-role=attachments]"))
      @instance = new Attachment(container)

  constructor: (@container) ->
    @initUi()
    @bindEvents()

  initUi: ->
    @ui =
      deleteLink: @container.find("[data-action=delete]")

  bindEvents: ->
    @ui.deleteLink.on "ajax:success", @handleDelete

  handleDelete: (event, response) ->
    on_deletion_effect("[data-role=attachment][data-id=#{response.id}]");
