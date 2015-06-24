###*
# User: nmeylan
# Date: 16.11.14
# Time: 15:46
###

@bindColorEditor = (scope) ->
  editor_fields = scope.find('.color-editor-field')
  editor_field = undefined
  editor_fields.each ->
    editor_field = $(this)
    color_bg = $('<span class=\'color-editor-bg\'></span>')
    container = $('<div class=\'color-editor dropdown\'></div>')
    color_editor_wrap_elements editor_field, color_bg, container
    color_editor_key_event editor_field, color_bg
    return
  return

color_editor_wrap_elements = (editor_field, color_bg, container) ->
  editor_field.wrap container
  editor_field.attr 'data-toggle', 'dropdown'
  editor_field.dropdown()
  color_bg.insertBefore editor_field
  dropdown = dropdown_color_editor(color_bg, editor_field)
  dropdown.insertAfter editor_field
  set_editor_colors editor_field, color_bg
  return

color_editor_key_event = (editor_field, color_bg) ->
  editor_field.keypress (e) ->
    val = editor_field.val()
    if val.indexOf('#') != 0
      editor_field.val '#' + val
    set_editor_colors editor_field, color_bg
    return
  return

set_editor_colors = (editor_field, color_bg) ->
  color_bg.css 'background-color', '#' + editor_field.val()
  editor_field.css 'color', '#' + editor_field.val()
  return

dropdown_color_editor = (color_bg, editor_field) ->
  dropdown = $('<div class=\'dropdown-menu-content colors dropdown-menu \'></div>')
  rows = []
  rows.push [
    'b54223'
    'eb6420'
    'ffd83c'
    '549e54'
    '006b75'
    '4183c4'
    '0052cc'
    '5319e7'
  ]
  rows.push [
    'f7c6c7'
    'fad8c7'
    'ffe88a'
    'bfe5bf'
    'bfdadc'
    'c7def8'
    'bfd4f2'
    'd4c5f9'
  ]
  i = 0
  while i < rows.length
    dropdown_color_editor_row rows[i], dropdown, color_bg, editor_field
    i++
  dropdown

dropdown_color_editor_row = (colors, dropdown, color_bg, editor_field) ->
  row = $('<ul class=\'color-chooser\'></ul>')
  dropdown.append row
  color = undefined
  color_element = undefined
  i = 0
  while i < colors.length
    color = colors[i]
    color_element = $('<li data-hex-value=\'' + color + '\' ><span class=\'color-chooser-color\' style=\'background-color:#' + color + '\'></span></li>')
    row.append color_element
    dropdown_color_editor_click_event color_element, editor_field, color_bg
    i++
  return

dropdown_color_editor_click_event = (color_element, editor_field, color_bg) ->
  color_element.click (e) ->
    value = $(this).attr('data-hex-value')
    editor_field.val '#' + value
    set_editor_colors editor_field, color_bg
    return
  return