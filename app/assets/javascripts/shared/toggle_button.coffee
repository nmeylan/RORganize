class @ToggleButton

  @setup: (scope) ->
    if (container = scope.find("[data-action=toggle-self]")).length || ((container = scope).is("[data-action=toggle-self]"))
      @instance = new ToggleButton(container)

  constructor: (@container) ->
    @bindEvents()

  bindEvents: ->
    @container.on "ajax:success", (event, response) =>
      button = $(event.currentTarget)
      button.tooltip('hide')
      button.replaceWith(response = $(response.button))
      window.App.setup(response)