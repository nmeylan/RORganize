class @List

  constructor: (@container) ->
    @perPage()

  perPage: ->
    self = @
    @container.find("[data-action=per-page]").change (e) ->
      $.get $(@).data("link"), {per_page: @.value}, (response) =>
        self.updateList($(response.list))