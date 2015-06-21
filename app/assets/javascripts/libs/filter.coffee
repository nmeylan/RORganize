###*
# User: nmeylan
# Date: 18.10.14
# Time: 08:11
###

#Param is json object that containing html: {'assigned_to':"<td>some html</td>",....}

@add_filters = (json_content) ->
  $('#filters-list').change (e) ->
    domobject = $($.parseJSON(json_content))
    selected = $(this).val()
    tmp = ''
    selector = ''
    $(this).find('option').each ->
      tmp = $(this).val()
      selector = 'tr.' + tmp.toLowerCase().replace(' ', '_')
      if $(selector).length < 1 and $.inArray($(this).val(), selected) != -1
        $('#filter-content').append domobject[0][tmp]
        #binding radio button action
        binding_radio_button '#filter-content ' + selector + ' input[type=radio]'
        radio_button_behaviour '#filter-content ' + selector + ' input[type=radio]'
        if tmp == 'Status'
          $('#filter-content ' + selector + ' input[type=radio]#status-open').attr 'checked', 'checked'
      else if $(selector).length > 0 and $.inArray($(this).val(), selected) == -1
        $(selector).remove()

    bind_date_field()

@load_filter = (json_content, present_filters) ->
  present_filters = $.parseJSON(present_filters)
  domobject = $($.parseJSON(json_content))
  tmp = ''
  selector = ''
  radio = ''
  if _.any(present_filters)
    $('#filter-content').html ''
    $('#type-filter').attr 'checked', 'checked'
    _.each present_filters, (value, key) ->
      radio = '#' + key + '_' + value.operator
      tmp = key
      selector = 'tr.' + tmp.toLowerCase().replace(' ', '_')
      $('#filters-list').find('option[value=\'' + key + '\']').attr 'selected', 'selected'
      $('#filter-content').append domobject[0][tmp]
      $(radio).attr 'checked', 'checked'
      #binding radio button action
      binding_radio_button '#filter-content ' + selector + ' input[type=radio]'
      radio_button_behaviour '#filter-content ' + selector + ' input[type=radio]'
      if value.operator != 'open'
        $('#td-' + key).show()
      $('#td-' + key).find('input').val value.value
      if _.isArray(value.value)
        _.each value.value, (v) ->
          $('#td-' + key).find('select').find('option[value=\'' + v + '\']').attr 'selected', 'selected'

    $('.content').hide()
  else
    $('#filter-content').hide()
    $('.content').hide()
    $('#filters_list_chosen').hide()

@initialize_filters = (options) ->
  if gon
    add_filters gon.DOM_filter
    load_filter gon.DOM_filter, if options and options.dom_persisted_filter then options.dom_persisted_filter else gon.DOM_persisted_filter
  $('#type-filter').click (e) ->
    $('#filters_list_chosen').show()
    $('#filter-content').show()

  $('#type-all').click (e) ->
    $('#filters_list_chosen').hide()
    $('#filter-content').hide()
