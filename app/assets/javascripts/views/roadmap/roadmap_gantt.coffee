MONTHS = [
  'Jan'
  'Feb'
  'Mar'
  'Avr'
  'May'
  'Jun'
  'Jul'
  'Aug'
  'Sep'
  'Oct'
  'Nov'
  'Dec'
]

class @RoadmapGantt

  @setup: (scope) ->
    if (container = scope.find("[data-role=roadmaps-gantt]")).length || ((container = scope).is("[data-role=roadmaps-gantt]"))
      @instance = new RoadmapGantt(container)

  constructor: (@container) ->
    @initRoadmap()

  initRoadmap: ->
    @bind_gantt_filter()
    @bind_save_button()
    if gon.Gantt_JSON
      scale_config = '3'
      gantt.min_column_width = 50

      gantt.templates.task_cell_class = (task, date) ->
        classes = ''
        if (date.getDay() == 0 or date.getDay() == 6) and scale_config != '4'
          classes = 'week_end '
        classes += task.context.type
        classes

      gantt.templates.task_class = (start, end, task) ->
        classes = ''
        classes += task.context.type
        if !task.context.are_data_provided
          classes += ' phantom_task'
        classes

      edition = $('#gantt_mode').val() == 'edition'
      gantt.config.drag_progress = false
      gantt.config.drag_move = edition
      gantt.config.drag_resize = edition
      gantt.config.drag_links = edition
      gantt.config.autosize = true
      gantt.config.grid_width = 600
      gantt.config.grid_resize = true
      @config_column edition

      gantt.templates.rightside_text = (start, end, task) ->
        assigne = task.context.assigne
        if assigne != undefined then (if '<b>' + assigne != null then assigne else 'unassigned' + '</b>') else ''

      gantt.templates.leftside_text = (start, end, task) ->
        duration = '<span>' + task.context.start_date_str + ' <b>-</b> ' + task.context.due_date_str + '</span>'
        progress = if task.progress != undefined then '<span style=\'text-align:right;\'>' + Math.round(task.progress * 100) + '% </span>' else ''
        duration + progress

      gantt.attachEvent 'onBeforeLightbox', (id) ->
        false
      @setScaleConfig scale_config
      gantt.init 'gantt_chart'
      gantt.parse gon.Gantt_JSON, 'json'

      func = (e) =>
        e = e or window.event
        el = e.target or e.srcElement
        scale_config = el.value
        @setScaleConfig scale_config
        gantt.render()
        return

      els = document.getElementsByName('scale')
      i = 0
      while i < els.length
        els[i].onclick = func
        i++

      limitMoveLeft = (task, limit) ->
        dur = task.end_date - (task.start_date)
        task.end_date = new Date(limit.end_date)
        task.start_date = new Date(+task.end_date - dur)
        return

      limitMoveRight = (task, limit) ->
        dur = task.end_date - (task.start_date)
        task.start_date = new Date(limit.start_date)
        task.end_date = new Date(+task.start_date + dur)
        return

      limitResizeLeft = (task, limit) ->
        task.end_date = new Date(limit.end_date)
        return

      limitResizeRight = (task, limit) ->
        task.start_date = new Date(limit.start_date)
        return

      gantt.attachEvent 'onTaskClick', (id, e) ->
        !$(e.target).hasClass('update_task')

      gantt.attachEvent 'onTaskDrag', (id, mode, task, original, e) ->
        parent = if task.parent then gantt.getTask(task.parent) else null
        children = gantt.getChildren(id)
        modes = gantt.config.drag_mode
        limitLeft = null
        limitRight = null
        if !(mode == modes.move or mode == modes.resize)
          return
        if mode == modes.move
          limitLeft = limitMoveLeft
          limitRight = limitMoveRight
        else if mode == modes.resize
          limitLeft = limitResizeLeft
          limitRight = limitResizeRight
        #check parents constraints
        if parent and +parent.end_date < +task.end_date
          limitLeft(task, parent)
        if parent and +parent.start_date > +task.start_date
          limitRight(task, parent)
        if !(mode == modes.move or mode == modes.resize)
          return
        task.context.due_date = task.end_date
        task.context.start_date = task.start_date
        task.context.due_date_str = task.context.due_date.getDate() + ' ' + MONTHS[task.context.due_date.getMonth()] + '.'
        task.context.start_date_str = task.start_date.getDate() + ' ' + MONTHS[task.start_date.getMonth()] + '.'
        gantt.refreshTask task.id
        return

      gantt._fix_dnd_scale_time = __fix_dnd_scale_time = (t, e) ->
        n = 'day'
        k = 1
        unless gantt.config.round_dnd_dates
          n = 'minute'
          k = gantt.config.time_step

        if e.mode == gantt.config.drag_mode.resize
          if e.left
            t.start_date = gantt._get_closest_date({date: t.start_date, unit: n, step: k})
          else
            t.end_date = gantt._get_closest_date({date: t.end_date, unit: n, step: k})
        else
          e.mode == gantt.config.drag_mode.move and t.start_date = gantt._get_closest_date({date: t.start_date, unit: n,step: k})
        t.end_date = gantt.calculateEndDate(t.start_date, t.duration, gantt.config.duration_unit)

      gantt.attachEvent 'onAfterTaskDrag', (id, mode, e) ->
        drag = gantt._tasks_dnd.drag
        task = gantt.getTask(id)
        children = gantt.getChildren(id)
        __fix_dnd_scale_time task, drag
        task.context.due_date = task.end_date
        task.context.start_date = task.start_date
        task.context.due_date_str = task.context.due_date.getDate() + ' ' + MONTHS[task.context.due_date.getMonth()] + '.'
        task.context.start_date_str = task.start_date.getDate() + ' ' + MONTHS[task.start_date.getMonth()] + '.'
        gantt.refreshTask task.id
        i = 0
        while i < children.length
          child = gantt.getTask(children[i])
          dnd_apply_constraints(mode, drag, task, child)
          __fix_dnd_scale_time(child, drag)
          i++

  setScaleConfig: (value) ->

    weekScaleTemplate = (date) ->
      dateToStr = gantt.date.date_to_str('%d %M, %Y')
      endDate = gantt.date.add(gantt.date.add(date, 1, 'week'), -1, 'day')
      dateToStr(date) + ' - ' + dateToStr(endDate)

    monthScaleTemplate = (date) ->
      dateToStr = gantt.date.date_to_str('%M')
      endDate = gantt.date.add(date, 2, 'month')
      dateToStr(date) + ' - ' + dateToStr(endDate)

    switch value
      when '1'
        gantt.config.scale_unit = 'day'
        gantt.config.step = 1
        gantt.config.date_scale = '%D. %d %M'
        gantt.config.subscales = []
        gantt.config.scale_height = 27
        gantt.templates.date_scale = null
      when '2'
        gantt.config.scale_unit = 'week'
        gantt.config.step = 1
        gantt.templates.date_scale = weekScaleTemplate
        gantt.config.subscales = [ {
          unit: 'day'
          step: 1
          date: '%D. %d'
        } ]
        gantt.config.scale_height = 50
      when '3'
        gantt.config.scale_unit = 'month'
        gantt.config.date_scale = '%F, %Y'
        gantt.config.subscales = [ {
          unit: 'week'
          step: 1
          date: '%W'
        } ]
        gantt.config.scale_height = 50
        gantt.config.scale_width = 50
        gantt.templates.date_scale = null
      when '4'
        gantt.config.scale_unit = 'year'
        gantt.config.step = 1
        gantt.config.date_scale = '%Y'
        gantt.config.min_column_width = 50
        gantt.config.scale_height = 90
        gantt.templates.date_scale = null
        gantt.config.subscales = [
          {
            unit: 'month'
            step: 3
            template: monthScaleTemplate
          }
          {
            unit: 'month'
            step: 1
            date: '%M'
          }
        ]

  dnd_apply_constraints = (mode, drag, task, child) ->
    modes = gantt.config.drag_mode
    if mode == modes.resize
      if +task.end_date < +child.end_date
        diff = drag.obj.duration - (task.duration)
        if +task.start_date != +child.start_date and diff > 0
          diff = drag.obj.duration - (task.duration)
          child.start_date.setDate child.start_date.getDate() - diff
          if +task.start_date > +child.start_date
            child.start_date = task.start_date
        child.end_date = task.end_date
        child.hasChanged = true
      else if +task.start_date > +child.start_date
        diff = drag.obj.duration - (task.duration)
        if +task.end_date != +child.end_date and diff > 0
          diff = drag.obj.duration - (task.duration)
          child.end_date.setDate child.end_date.getDate() + diff
          if +task.end_date < +child.end_date
            child.end_date = task.end_date
        child.start_date = task.start_date
        child.hasChanged = true
    else if mode == modes.move
      if +task.end_date < +child.end_date
        diff = gantt.calculateDuration(task.end_date, child.end_date)
        child.start_date.setDate child.start_date.getDate() - diff
        child.end_date = task.end_date
      else if +task.start_date > +child.start_date
        diff = gantt.calculateDuration(child.start_date, task.start_date)
        child.end_date.setDate child.end_date.getDate() + diff
        child.start_date = task.start_date
    child.context.due_date = child.end_date
    child.context.start_date = child.start_date
    child.context.due_date_str = child.context.due_date.getDate() + ' ' + MONTHS[child.context.due_date.getMonth()] + '.'
    child.context.start_date_str = child.start_date.getDate() + ' ' + MONTHS[child.start_date.getMonth()] + '.'
    child.duration = gantt.calculateDuration(child.start_date, child.end_date)
    gantt.refreshTask child.id
    return

  merge_gantt_data: (json) ->
    `var json`
    old_data = gantt.json.serialize()
    json = JSON.parse(json)
    new_data = json.data
    tmp_old = old_data.data
    while i < new_data.length
      j = 0
      while j < tmp_old.length
        if new_data[i].id == tmp_old[j].id
          new_data[i] = tmp_old[j]
        j++
      i++
    json

  bind_gantt_filter: ->
    select = $('#gantt_version_select')
    select.change (e) ->
      e.preventDefault()
      jQuery.ajax
        url: select.data('link')
        type: 'get'
        dataType: 'script'
        data:
          value: select.val()
          mode: $('#gantt_mode').val()
      return
    return

  bind_save_button: ->
    $('#save_gantt').click (e) ->
      `var i`
      e.preventDefault()
      el = $(this)
      form = el.parents('form')
      updated_tasks = $('input.update_task:checked')
      ids = []
      serialized_gantt = gantt.json.serialize()
      data = []
      i = 0
      while i < updated_tasks.length
        ids.push $(updated_tasks[i]).val()
        i++
      if ids.length == 0
        apprise 'Before saving please select which elements you want to save.'
      else
        len = serialized_gantt.data.length
        i = 0
        while i < len
          if ids.indexOf(serialized_gantt.data[i].id.toString()) != -1
            data.push serialized_gantt.data[i]
          else if ids.indexOf(serialized_gantt.data[i].parent.toString()) != -1
            data.push serialized_gantt.data[i]
          i++
        serialized_gantt.data = data
        $.ajax
          url: form.attr('action')
          type: form.attr('method')
          dataType: 'script'
          data: gantt: serialized_gantt
      return
    return

  config_column: (edition) ->
    edit_tasks = undefined
    edit_tasks =
      if edition
        name: 'update'
        label: '<span class=\'octicon octicon-pencil\'></span>'
        align: 'center'
        width: 10
        template: (item) ->
          '<input type=\'checkbox\' name=\'update_task[]\' class=\'update_task\' value=\'' + item.id + '\'>'
      else
        name: ''
        label: ''
        width: 0
        template: (item) -> ''
    gantt.config.columns = [
      {
        name: 'text'
        label: 'Task name'
        tree: true
        width: 300
        template: (item) ->
          context = item.context
          if context.type == 'issue'
            context.link
          else
            item.text

      }
      {
        name: 'start_date'
        label: 'Start date'
        width: 60
        align: 'center'
        template: (item) ->
          item.context.start_date

      }
      {
        name: 'due_date'
        label: 'Due date'
        width: 60
        align: 'center'
        template: (item) ->
          item.context.due_date

      }
      {
        name: 'duration'
        label: 'Duration'
        align: 'center'
        width: 40
        template: (item) ->
          item.duration

      }
      edit_tasks
    ]