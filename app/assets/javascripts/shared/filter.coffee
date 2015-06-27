class @Filter

  @setup: (scope) ->
    if (container = scope.find("[data-role=filters]")).length || ((container = scope).is("[data-role=filters]"))
      @instance = new Filter(container)

  constructor: (@container) ->
    @initUi()
    @bindEvents()

    initialize_filters()

  initUi: =>
    @ui =
      createQueryButton: @container.find("[data-role=save-query-button]")
      filterForm: @container.find("[data-role=filter-form]")

  bindEvents: =>
    @ui.filterForm.on "ajax:success", @handleApplyForm

  handleApplyForm: (event, response) =>
    filter = response.filter
    @updateSaveButton(filter)

    $("[data-role=total-entries]").replaceWith($(response.countEntries))
    window.List.instance.updateList($(response.list))

  updateSaveButton: (filter) ->
    if createButton = $(filter).find("[data-action=save-query]")
      self = @
      createButton.click (e) ->
        e.preventDefault()
        el = $(this)
        json = self.ui.filterForm.serializeJSON()
        response = confirm(el.data('confirm-message'))
        if response
          $.ajax
            url: el[0].href
            type: 'put'
            dataType: 'script'
            data: json
    @ui.createQueryButton.html(if createButton.length then createButton else $(filter).find("[data-action=create-query]"))
    window.App.setup(@ui.createQueryButton)