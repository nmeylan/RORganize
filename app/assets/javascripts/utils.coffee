String::endsWith = (suffix) ->
  @indexOf(suffix, @length - (suffix.length)) != -1

#JSON

$.fn.serializeJSON = ->
  json = {}
  $.map $(this).serializeArray(), (n, i) ->
    if n.name.endsWith('[]')
      if json[n.name] == undefined
        json[n.name] = []
      json[n.name].push n.value
    else
      json[n.name] = n.value
    return
  json

$.fn.serializeObject = ->
  values = {}
  $('form input, form select, form textarea').each ->
    values[@name] = $(this).val()
    return
  values

$.expr[':'].contains = (a, i, m) ->
  $(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0