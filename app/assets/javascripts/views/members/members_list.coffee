class @MembersList extends List

  @setup: (scope) ->
    if (container = scope.find("[data-role=members-list]")).length || ((container = scope).is("[data-role=members-list]"))
      @instance = new MembersList(container)

  constructor: (@container) ->
    super(@container)
    @initUi()
    @bindEvents()

  initUi: ->
    @ui =
      roleSelect: @container.find("[data-action=change-role]")

  bindEvents: ->
    @ui.roleSelect.on "change", @handleRoleChange


  handleRoleChange: (e) =>
    el = $(e.currentTarget)
    $.post el.data("remote"), {value: el.val()}, (response) =>
      @updateList($(response.list))