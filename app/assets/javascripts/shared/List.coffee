class @List

  constructor: (@container) ->
    @perPage()
    @paginate()
    @sort()
    @deleteButton()
    @changePosition()
    List.instance = @

  perPage: ->
    self = @
    @container.find("[data-action=per-page]").change (e) ->
      $.get $(@).data("link"), {per_page: @.value}, (response) =>
        self.updateList($(response.list))

  paginate: ->
    @container.find("[data-action=paginate]").on "ajax:success", (event, response) =>
      @updateList($(response.list))

  sort: ->
    @container.find("[data-action=sort-list]").on "ajax:success", (event, response) =>
      @updateList($(response.list))

  deleteButton: ->
    @container.find("[data-action=delete]").on "ajax:success", (event, response) =>
      on_deletion_effect("##{response.id}")
      countEntries = $("[data-role=total-entries]")
      countEntries.text(parseInt(countEntries.text()) - 1)

  changePosition: ->
    self = @
    @container.find("[data-action=change-position]").on "click", (e) ->
      e.preventDefault()
      el = $(this)
      vid = el.parents('tr').attr('id')
      ope = el.attr('class').split(' ')
      ope = ope[ope.length - 1]
      if ope == 'inc' or ope == 'dec'
        $.ajax
          url: el.attr('href')
          type: 'post'
          dataType: 'json'
          data:
            id: vid
            operator: ope
          success: (response) ->
            self.updateList($(response.list))

  updateList: (data) =>
    @container.replaceWith(data)
    window.App.setup(data)