class @PermissionsIndex

  @setup: (scope) ->
    if (container = scope.find("[data-role=permissions-list]")).length || ((container = scope).is("[data-role=permissions-list]"))
      @instance = new PermissionsIndex(container)

  constructor: (@container) ->
    @initUi()
    @bindEvents()

  initUi: ->
    @ui =
      permissionList: @container.find("table.permissions-list")
      checkAll: @container.find(".check-all")
      rows: @container.find("tr.body")

  bindEvents: ->
    @ui.rows.each ->
      id = $(this).attr("class").split(' ')[1]
      checkAllBox("#check-all-" + id, $(this))

    @ui.checkAll.each ->
      id = $(this).attr('id')
      classes = id.split('-')
      checkAllBox("#" + id, $("td.body." + classes.join('.')))

    @ui.permissionList.each ->
      el = $(this)
      if el.find('.permissions-list.body.misc').children().length == 0
        el.find('td.misc').hide()