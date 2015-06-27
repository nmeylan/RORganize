class @ProjectsIndex

  @setup: (scope) ->
    if (container = scope.find("[data-role=projects-index]")).length || ((container = scope).is("[data-role=projects-index]"))
      @instance = new ProjectsIndex(container)

  constructor: (@container) ->
    @initUi()
    @bindEvents()

  initUi: ->
    @ui =
      links: @container.find("[data-action=project-selection-filter]")
      list: => @container.find("[data-role=projects-list]")

  bindEvents: ->
    self = @
    @ui.links.click (e) ->
      self.ui.links.removeClass("selected")
      $(this).addClass("selected")

    @ui.links.on "ajax:success", (event, response) =>
      @ui.list().replaceWith(response = $(response.projects))
      window.App.setup(response)