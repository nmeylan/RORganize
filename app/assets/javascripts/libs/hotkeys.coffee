###*
# User: nmeylan
# Date: 25.08.14
# Time: 00:31
###

@bindHotkeys = ->
  Mousetrap.bind '/', (e) ->
    on_keydown_highlight_search e
    false
  Mousetrap.bind 'h', (e) ->
    help_overlay()
    return
  Mousetrap.bind 'g t', (e) ->
    go_next_tab()
    return
  Mousetrap.bind 'g T', (e) ->
    go_previous_tab()
    return
  Mousetrap.bind 'j', (e) ->
    line_downward()
    return
  Mousetrap.bind 'k', (e) ->
    line_upward()
    return
  Mousetrap.bind 'enter', (e) ->
    enter_actions e
    return
  return

on_keydown_highlight_search = (e) ->
  search_box = $('#highlight-search')
  input = search_box.find('input')
  search_box.keydown (e) ->
    highlight_result e, input
    return
  if search_box.is(':visible')
    close_highlight_search search_box
  else
    $('html').append('<div id="searchMask" style="position: fixed; top: 0px; left: 0px; width: 100%; height: 100%; display: block; opacity: 0.3; z-index: 10; background-color: rgb(0, 0, 0);"></div>').keydown (e) ->
      if e.keyCode == 27
        close_highlight_search search_box
      return
    search_box.css('display', 'block').css 'z-index', ' 9999'
    input.focus()
  return

close_highlight_search = (search_box) ->
  search_box.css 'display', 'none'
  $('#searchMask').remove()
  return

highlight_result = (event, input) ->
  c = ''
  typed_key = if event != undefined then String.fromCharCode(event.which) else '_'
  if typed_key.match(/^[a-z0-9'^éàèüäö]+$/i)
    c = typed_key
  filter = input[0].value + c
  if event != undefined and event.keyCode == 8
    filter = filter.substring(0, filter.length - 1)
  $('.highlight-search-result').removeClass 'highlight-search-result'
  $('#highlight-search-result-count').text ''
  if filter.trim() != ''
    count = 0
    matches = $('* :contains("' + filter + '"):visible').filter((index) ->
      $(this).children().length < 1
    )
    matches_size = matches.length
    if matches_size > 0 and matches_size < 5000
      matches.each (a) ->
        $(this).addClass 'highlight-search-result'
        return
    matches = $('a:visible:contains("' + filter + '")')
    matches_size = matches.length
    if matches_size > 0 and matches_size < 5000
      matches.each (a) ->
        $(this).addClass 'highlight_search_result'
        return
    count = $('.highlight-search-result').length
    if count > 0
      $('#highlight-search-result-count').text count
  return

#h

help_overlay = ->
  $('#hotkeys-modal').modal('toggle')

#gt

go_next_tab = ->
  current_tab = $('#main-menu').find('li.selected')
  next_tab = current_tab.next()
  if next_tab != undefined
    next_tab.find('a').get(0).click()
  return

#gT

go_previous_tab = ->
  current_tab = $('#main-menu').find('li.selected')
  prev_tab = current_tab.prev()
  if prev_tab != undefined
    prev_tab.find('a').get(0).click()
  return

#j

line_downward = ->
  list = $('table.list')
  if list[0] != undefined
    row = list.find('tr.hover')
    if row[0] != undefined
      next = row.next()
      if next[0] != undefined
        row.removeClass 'hover'
        next.addClass 'hover'
    else
      list.find('tr:not(.header)').first().addClass 'hover'
  return

#k

line_upward = ->
  list = $('table.list')
  if list[0] != undefined
    row = list.find('tr.hover')
    if row[0] != undefined
      prev = row.prev(':not(.header)')
      if prev[0] != undefined
        row.removeClass 'hover'
        prev.addClass 'hover'
    else
      list.find('tr:not(.header)').last().addClass 'hover'
  return

enter_actions = (e) ->
  list = $('table.list')
  if list[0] != undefined
    row = list.find('tr.hover')
    link = row.find('a:not(.delete-link)')
    if link[0] != undefined
      console.log link
      link[0].click()
  return