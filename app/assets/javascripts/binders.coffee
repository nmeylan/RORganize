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

@bindDateField = (scope) ->
  test_input = $('<input type="date" name="bday">')
  input_date = scope.find('[type="date"]')
  if test_input.prop('type') != 'date'
#if browser doesn't support input type="date", load files for $ UI Date Picker
    if input_date.hasClass('hasDatepicker')
      input_date.datepicker 'destroy'
    input_date.datepicker dateFormat: 'dd/mm/yy'

@bindTableListActions = (scope) ->
  table_row = scope.find('table.list tr')
  table_row.hover (->
    table_row.removeClass 'hover'
    $(this).addClass 'hover'
  ), ->
    $(this).removeClass 'hover'

@bindTaskListClick = (scope) ->
  el = scope.find('.task-list-item-checkbox')
  el.unbind 'click'
  el.click (e) ->
    el = $(this)
    context = $(this).parents('div.markdown-renderer')
    split_ary = context.attr('id').split('-')
    element_type = split_ary[0]
    element_id = split_ary[1]
    check_index = context.find('.task-list-item-checkbox').index(el)
    is_check = el.is(':checked')
    $.ajax
      url: '/rorganize/task_list_action_markdown'
      type: 'post'
      dataType: 'script'
      data:
        is_check: is_check
        element_type: element_type
        element_id: element_id
        check_index: check_index

@displayFlash = (scope) ->
  el = undefined
  scope.find('.flash').each ->
    el = $(this)
    if el.text().trim() != ''
      el.css 'display', 'block'
      el.find('.close-flash').click (e) ->
        $(this).parent().fadeOut()
        return
    else
      $(this).css 'display', 'none'

@errorExplanation = (message) ->
  el = jQuery('.flash.alert')
  if message != null
    el.append(message).css 'display', 'block'

@checkAllBox = (selector, context) ->
  $(selector).click (e) ->
    e.preventDefault()
    cases = $(context).find(':checkbox')
    checked = $(this).attr('cb_checked') == 'b'
    cases.prop 'checked', checked
    $(this).attr 'cb_checked', if checked then 'a' else 'b'