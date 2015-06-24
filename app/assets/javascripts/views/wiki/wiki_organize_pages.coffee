class @WikiOrganizePages

  @setup: (scope) ->
    if (container = scope.find("[data-role=wiki-organize-pages]")).length || ((container = scope).is("[data-role=wiki-organize-pages]"))
      @instance = new WikiOrganizePages(container)

  constructor: (@container) ->
    @container.find("#wiki-pages").addClass('organize')
    @bindOrganizationBehaviour(".connectedSortable")
    @container.find(".connectedSortable li.item").prepend("<a href='#' class='add-sub-item icon icon-add'><span class='octicon octicon-plus'></span></a> ")
    @addSubItem(".add-sub-item")
    @bindSetOrganizationButton("#wiki-pages li.item", "#serialize")

  bindOrganizationBehaviour: (selector) ->
    remove = false
    self = @
    @container.find(selector).sortable
      connectWith: '.connectedSortable'
      dropOnEmpty: true
      forcePlaceholderSize: true
      forceHelperSize: true
      placeholder: 'ui-state-highlight'
      items: '> li'
      sort: (event, ui) ->
        remove = ui.item.attr('class').indexOf('parent') != -1 && ui.item.find('li').length == 0
        return
      beforeStop: (event, ui) ->
        if remove
          self.find(ui.helper).remove()
          self.find('.connectedSortable').sortable 'refresh'
          remove = false

  addSubItem: (selector) ->
    self = @
    @container.find(selector).click (e) ->
      e.preventDefault()
      parent_id = $(this).parent('li').attr('id').split('_')[1]
      $(this).parent().after('<li class=\'parent\' style=\'list-style:none\'><ul id=\'parent-' + parent_id + '\' class=\'connectedSortable\'></ul></li>')
      self.bindOrganizationBehaviour('.connectedSortable')

  bindSetOrganizationButton: (main_selector, list_selector) ->
    self = @
    @container.find(list_selector).click (e) ->
      dom_pages = self.container.find(main_selector)
      #{page_id => {parent_id : value, position : value},...}
      serialized_hash = {}
      parent_ids = []
      tmp_parent_id = null
      tmp_item_id = 0
      is_undifined = false
      tmp_position = 0
      #Define for each page parent id
      $.each dom_pages, (index, value) ->
        tmp_position = $(value).index()
        is_undifined = typeof $(value).parent('ul').parent('li').prev().attr('id') == 'undefined'
        #put parent id value if defined, else put nil
        tmp_parent_id = if !is_undifined then $(value).parent('ul').parent('li').prev().attr('id').split('-')[1] else null
        tmp_item_id = $(value).attr('id').split('-')[1]
        parent_ids.push tmp_parent_id
        serialized_hash[tmp_item_id] =
          parent_id: tmp_parent_id
          position: tmp_position

      url = $(this).data('link')
      $.ajax
        url: url
        type: 'PUT'
        dataType: 'script'
        data: 'pages_organization': serialized_hash
