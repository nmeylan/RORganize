class @AddCommentForm

  @setup: (scope) ->
    if (container = scope.find("[data-role=add-comment-form]")).length || ((container = scope).is("[data-role=add-comment-form]"))
      @instance = new AddCommentForm(container)

  constructor: (@container) ->
    @bindEvents()

  bindEvents: ->
    @container.on "ajax:success", @handleFormSubmission

  handleFormSubmission: (event, response) =>
    if response.status
      unless $('#history-blocks').length
        $('#history').append('<div id="history-blocks"></div>')

      onAppendEffect('#history-blocks', response = $(response.comment_block))
      window.App.setup(response)
      @container.fadeOut()