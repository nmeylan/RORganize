class @CommentBlock

  @setup: (scope) ->
    if (container = scope.find("[data-role=comment-block]")).length || ((container = scope).is("[data-role=comment-block]"))
      @instance = new CommentBlock(container)

  constructor: (@container) ->
    @initUi()
    @bindEvents()

  initUi: ->
    @ui =
      editButton: @container.find("[data-action=edit]")
      deleteButton: @container.find("[data-action=delete]")

  bindEvents: ->
    @ui.editButton.on "ajax:success", @handleEdit
    @ui.deleteButton.on "ajax:success", @handleDelete

  handleEdit: (event, response) =>
    container =  @container.find("[data-role=comment-content][data-id=#{response.id}]")
    container.find(".markdown-renderer").hide()
    container.append(response = $(response.html))
    form = container.find("[data-role=comment-form]")
    form.on "ajax:success", @handleFormSubmission
    window.App.setup(response)

    response.find("[data-action=close]").on "click", (e) =>
      e.preventDefault()
      container.find(".markdown-renderer").show()
      form.remove()

  handleFormSubmission: (event, response) =>
    container =  @container.find("[data-role=comment-content][data-id=#{response.id}]")
    text = container.find(".markdown-renderer")
    text.replaceWith(response.html)
    text.show()
    form = container.find("[data-role=comment-form]")
    form.hide()

  handleDelete: (event, response) =>
    on_deletion_effect("#comment-#{response.id}");