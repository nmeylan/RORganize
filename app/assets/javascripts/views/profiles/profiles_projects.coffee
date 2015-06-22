class @ProfilesProjects

  @setup: (scope) ->
    if (container = scope.find("[data-role=profiles-projects]")).length || ((container = scope).is("[data-role=profiles-projects]"))
      @instance = new ProfilesProjects(container)

  constructor: (@container) ->
    @initUi()
    @bindEvents()

  initUi: ->
    @ui =
      saveButton: @container.find("#save-position")

  bindEvents: ->
    @ui.saveButton.click (e) ->
      e.preventDefault()
      p_ids = []
      url = $(this).data('link')
      $.each $(".project-list.sortable li.project"), (project) ->
        p_ids.push($(this).attr("id"))

      $.ajax
        url: url
        type: "post"
        dataType: "json"
        data:
          ids: p_ids