@onDeletionEffect = (element_id) ->
  $(element_id).fadeOut 400, ->
    $(this).remove()
    return
  return

@onAppendEffect = (element_id, content) ->
  $(element_id).append(content).fadeIn 500
  return

@onReplaceEffect = (element_id, content) ->
  $(element_id).replaceWith(content).fadeIn 500
  return