class @List

  constructor: (@container) ->
    @perPage()
    @paginate()
    @sort()

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