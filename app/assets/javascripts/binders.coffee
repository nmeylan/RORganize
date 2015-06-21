@bindAttachementEvents = (scope) ->
  bindRemoveAttachementEvents(scope)
  scope.find('.add-attachment-link').click (e) ->
    e.preventDefault()
    el = $(this)
    content = el.data('content')
    id = el.data('id')
    el.parent().parent().append content
    bindRemoveAttachementEvents(scope)

@bindRemoveAttachementEvents = (scope) ->
  scope.find('.remove-attachment-field-link').click (e) ->
    e.preventDefault()
    el = $(this)
    el.parents('.attachments').fadeOut 'slow', ->
      @remove()

@bindNewCommentLink = (scope) ->
  scope.find("[data-toggle=new-comment]").on "click", (e) =>
    formContainer = scope.find('[data-role=add-comment-form]')
    formContainer.show();
    formContainer.find("[data-toggle=close-comment-form]").on "click", (e) ->
      e.preventDefault()
      formContainer.hide()

@bindSelect = (scope) ->
  scope.find(".chzn-select").chosen
    disable_search_threshold: 5
    scope.find(".chzn-select-deselect").chosen
      allow_single_deselect: true
      disable_search_threshold: 5