class @Toolbox

  constructor: (@container, @submitCallback) ->
    @toolbox = $("[data-role=toolbox]")
    @init()
    @initUi()
    @bindEvents()

  init: ->
    @container.jeegoocontext @toolbox.attr("id")
    self = @
    @container.find("tr").mousedown (e) ->
      if e.which == 3
        el = $(this)
        checkbox = el.find(':checkbox')
        if !checkbox[0].disabled
          checkbox.attr 'checked', true
          el.addClass 'toolbox-selection'
        self.handleMenuUpdate()

    @toolbox.on "ajax:success", (event, response) => @submitCallback(event, response)
    @checkAll()
    @checkboxToolbox()
    @listTrClick()

  initUi: ->
    @ui =
      submenu: => @toolbox.find(".submenu a")
      actionLink: => @toolbox.find("a.action-link")

  bindEvents: ->
    self = @

    @ui.submenu().click (e) ->
      e.preventDefault()
      # find the context of the selected options: e.g: "category" for update categories of the selected documents
      context = _.without($(this).parents('.submenu').attr('class').split(' '), 'submenu', 'hover')
      #put new value into hidden field which name is matching with context
      self.toolbox.find('input#value_' + context).val($(this).data('id'))
      self.toolbox.find('form').submit()

    @ui.actionLink().click (e) ->
      e.preventDefault()
      context = _.without($(this).parents('li').attr('class').split(' '), 'hover')
      #put new value into hidden field which name is matching with context
      self.toolbox.find('input#value_' + context).val($(this).data('id'))
      self.toolbox.find('form').submit()



  handleMenuUpdate: ->
    array = []
    $(@container.find('input:checked')).each ->
      array.push($(this).val())

    $.ajax
      url: @container.data('link')
      type: 'GET'
      dateType: 'script'
      data:
        ids: array
      success: (response) =>
        @toolbox.html(response = $(response))
        @bindEvents()
        self = @
        DynamicModal response,
          success: (response) ->
            self.submitCallback(event, response)
            @modal("hide")

  checkAll:  ->
    self = @
    @container.find("[data-toggle=check-all]").click (e) ->
      e.preventDefault()
      cases = self.container.find(':checkbox:not(:disabled)')
      checked = $(this).attr('cb_checked') == 'b'
      cases.prop 'checked', checked
      $(this).attr 'cb_checked', if checked then 'a' else 'b'
      if checked
        self.container.find('.issue-tr:not(.disabled-toolbox)').addClass 'toolbox-selection'
      else
        self.container.find('.issue-tr:not(.disabled-toolbox)').removeClass 'toolbox-selection'

  checkboxToolbox: ->
    @container.find('input[type=checkbox]').change ->
      row = $(this).parent('td').parent('tr')
      if $(this).is(':checked')
        $('.toolbox-selection').removeClass 'toolbox-last'
        row.addClass('toolbox-selection').addClass 'toolbox-last'
      else
        row.removeClass('toolbox-selection').removeClass 'toolbox-last'

  listTrClick: (rows_selector) ->
    rows = @container.find("tr")
    rows.click (e) ->
      if $(e.target)[0].tagName != 'A'
        if $(this).hasClass('disabled-toolbox')
          return false
        el = $(this)
        target = e.target or e.srcElement
        if !e.shiftKey and !$(target).is('input') and !e.ctrlKey and !e.metaKey
          rows.find('input[type=checkbox]').prop 'checked', false
          rows.removeClass('toolbox-selection').removeClass 'toolbox-last'
          el.find('input[type=checkbox]').prop 'checked', true
          el.addClass('toolbox-selection').addClass 'toolbox-last'
        else if e.shiftKey
          e.preventDefault()
          last_selected_row = $('.toolbox-last')
          if last_selected_row.length > 0 and last_selected_row[0] != el[0]
            between_rows = if last_selected_row[0].rowIndex > el[0].rowIndex then last_selected_row.prevUntil(el[0]) else last_selected_row.nextUntil(el[0])
            rows.removeClass 'toolbox-last'
            between_rows.find('input[type=checkbox]:not(:disabled)').prop 'checked', true
            between_rows.addClass 'toolbox-selection'
            el.find('input[type=checkbox]:not(:disabled)').prop 'checked', true
            el.addClass 'toolbox-selection'
            el.addClass 'toolbox-last'
          el.find('input[type=checkbox]').prop 'checked', true
          el.addClass('toolbox-selection').addClass 'toolbox-last'
        else if e.ctrlKey or e.metaKey
          rows.removeClass 'toolbox-last'
          el.find('input[type=checkbox]').prop 'checked', true
          el.addClass('toolbox-selection').addClass 'toolbox-last'
