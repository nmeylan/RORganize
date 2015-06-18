# ----------------------------------------------------------------------------
# markItUp! Universal MarkUp Engine, JQuery plugin
# v 1.1.x
# Dual licensed under the MIT and GPL licenses.
# ----------------------------------------------------------------------------
# Copyright (C) 2007-2012 Jay Salvat
# http://markitup.jaysalvat.com/
# ----------------------------------------------------------------------------
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ----------------------------------------------------------------------------
(($) ->

  $.fn.markItUp = (settings, extraSettings) ->
    method = undefined
    params = undefined
    options = undefined
    ctrlKey = undefined
    shiftKey = undefined
    altKey = undefined
    ctrlKey = shiftKey = altKey = false
    if typeof settings == 'string'
      method = settings
      params = extraSettings
    options =
      id: ''
      nameSpace: ''
      root: ''
      previewHandler: false
      previewInWindow: ''
      previewInElement: ''
      previewAutoRefresh: true
      previewPosition: 'after'
      previewTemplatePath: '~/templates/preview.html'
      previewParser: false
      previewParserPath: ''
      previewParserVar: 'data'
      previewParserAjaxType: 'POST'
      resizeHandle: true
      beforeInsert: ''
      afterInsert: ''
      onEnter: {}
      onShiftEnter: {}
      onCtrlEnter: {}
      onTab: {}
      markupSet: [ {} ]
    $.extend options, settings, extraSettings
    # compute markItUp! path
    if !options.root
      $('script').each (a, tag) ->
        miuScript = $(tag).get(0).src.match(/(.*)jquery\.markitup(\.pack)?\.js$/)
        if miuScript != null
          options.root = miuScript[1]
        return
    # Quick patch to keep compatibility with jQuery 1.9

    uaMatch = (ua) ->
      ua = ua.toLowerCase()
      match = /(chrome)[ \/]([\w.]+)/.exec(ua) or /(webkit)[ \/]([\w.]+)/.exec(ua) or /(opera)(?:.*version|)[ \/]([\w.]+)/.exec(ua) or /(msie) ([\w.]+)/.exec(ua) or ua.indexOf('compatible') < 0 and /(mozilla)(?:.*? rv:([\w.]+)|)/.exec(ua) or []
      {
      browser: match[1] or ''
      version: match[2] or '0'
      }

    matched = uaMatch(navigator.userAgent)
    browser = {}
    if matched.browser
      browser[matched.browser] = true
      browser.version = matched.version
    if browser.chrome
      browser.webkit = true
    else if browser.webkit
      browser.safari = true
    @each ->
      $$ = undefined
      textarea = undefined
      levels = undefined
      scrollPosition = undefined
      caretPosition = undefined
      caretOffset = undefined
      clicked = undefined
      hash = undefined
      header = undefined
      footer = undefined
      previewWindow = undefined
      template = undefined
      iFrame = undefined
      abort = undefined
      # apply the computed path to ~/

      localize = (data, inText) ->
        if inText
          return data.replace(/("|')~\//g, '$1' + options.root)
        data.replace /^~\//, options.root

      # init and build editor

      init = ->
        id = ''
        nameSpace = ''
        if options.id
          id = 'id="' + options.id + '"'
        else if $$.attr('id')
          id = 'id="markItUp' + $$.attr('id').substr(0, 1).toUpperCase() + $$.attr('id').substr(1) + '"'
        if options.nameSpace
          nameSpace = 'class="' + options.nameSpace + '"'
        $$.wrap '<div ' + nameSpace + '></div>'
        $$.wrap '<div ' + id + ' class="markItUp"></div>'
        $$.wrap '<div class="markItUpContainer"></div>'
        # add the header before the textarea
        header = $('<div class="markItUpHeader"></div>').insertBefore($$)
        $(headerMenu()).appendTo header
        $(dropMenus(options.markupSet)).appendTo header
        $$.wrap '<div class="markItUpEditorContainer"></div>'
        $$.addClass 'markItUpEditor'
        # listen key events
        $$.bind('keydown.markItUp', keyPressed).bind 'keyup', keyPressed
        # bind an event to catch external calls
        $$.bind 'insertion.markItUp', (e, settings) ->
          if settings.target != false
            get()
          if textarea == $.markItUp.focused
            markup settings
          return
        # remember the last focus
        $$.bind 'focus.markItUp', ->
          $.markItUp.focused = this
          return
        if options.previewInElement
          refreshPreview()
        return

      headerMenu = ->
        div = $('<div class="markItUpHeaderMenu tabnav"></div>')
        ul = $('<ul class="nav nav-tabs tabnav-tabs"></ul>')
        writeMenu = $('<li class="active"><a href="#" class="tabnav-tab write-tab js-write-tab active">Write</a></li>')
        previewMenu = $('<li><a href="#" class="tabnav-tab preview-tab js-write-tab">Preview</a></li>')
        bindPreviewMenu previewMenu.children('a')
        bindWriteMenu writeMenu.children('a')
        writeMenu.appendTo ul
        previewMenu.appendTo ul
        ul.appendTo div
        div

      bindWriteMenu = (el) ->
        el.click (e) ->
          `var textarea`
          e.preventDefault()
          parents = el.parents()
          container = undefined
          i = 0
          while i < parents.length
            if parents[i].className == 'markItUpContainer'
              container = $(parents[i])
              break
            i++
          if container
            textarea = container.children('.markItUpEditorContainer').children('textarea')
            buttons = container.children('.markItUpHeader').children('.markItUpButtons')
            markdownPreview = container.children('.markItUpEditorContainer').children('.markdown-preview')
            textarea.show()
            buttons.show()
            container.children('.markItUpHeader').children('.markItUpHeaderMenu').children('ul').children('li').removeClass 'active'
            el.parent().addClass 'active'
            if markdownPreview
              markdownPreview.remove()
          return
        return

      bindPreviewMenu = (el) ->
        el.click (e) ->
          `var textarea`
          e.preventDefault()
          if !el.parent().hasClass('active')
            parents = el.parents()
            container = undefined
            i = 0
            while i < parents.length
              if parents[i].className == 'markItUpContainer'
                container = $(parents[i])
                break
              i++
            if container
              textarea = container.children('.markItUpEditorContainer').children('textarea')
              buttons = container.children('.markItUpHeader').children('.markItUpButtons')
              content = textarea.val()
              if content and content.trim() != ''
                $.ajax
                  url: options.previewParserPath
                  dataType: 'JSON'
                  type: 'POST'
                  data: content: content
                  complete: (data, status, xhr) ->
                    if data.status == 200
                      textarea.hide()
                      buttons.hide()
                      container.children('.markItUpEditorContainer').append '<div class="markdown-preview">' + data.responseText + '</div>'
                      container.children('.markItUpHeader').children('.markItUpHeaderMenu').children('ul').children('li').removeClass 'active'
                      el.parent().addClass 'active'
                    return
          return
        return

      # recursively build header with dropMenus from markupset

      dropMenus = (markupSetGroups) ->
        div = $('<div class="markItUpButtons"></div>')
        i = 0
        separator_count = 0
        $.each markupSetGroups, ->
          group = $('<div class="markItUpGroup"></div>')
          $.each this, ->
            button = this
            t = ''
            title = undefined
            link = undefined
            j = undefined
            icon = undefined
            if button.title then (title = if button.key then (button.title or '') + ' [Ctrl+' + button.key + ']' else button.title or '') else (title = if button.key then (button.name or '') + ' [Ctrl+' + button.key + ']' else button.name or '')
            key = if button.key then 'accesskey="' + button.key + '"' else ''
            if button.separator
            else
              icon = if button.iconName != undefined then '<span class="octicon-' + button.iconName + ' octicon"></span>' else if button.content != undefined then button.content else button.name
              link = $('<a href="#" ' + key + ' title="' + title + '" class="markItUpButton">' + icon + '</a>').bind('contextmenu.markItUp', ->
# prevent contextmenu on mac and allow ctrl+click
                false
              ).bind('click.markItUp', (e) ->
                e.preventDefault()
                return
              ).bind('focusin.markItUp', ->
                $$.focus()
                return
              ).bind('mouseup', (e) ->
                if button.call
                  eval(button.call) e
                # Pass the mouseup event to custom delegate
                setTimeout (->
                  markup button
                  return
                ), 1
                false
              ).bind('mouseenter.markItUp', ->
                $('> div', this).show()
                $(document).one 'click', ->
# close dropmenu if click outside
                  $('ul ul', header).hide()
                  return
                return
              ).bind('mouseleave.markItUp', ->
                $('> div', this).hide()
                return
              ).appendTo(group)
              if button.dropMenu
                levels.push i
                $(link).addClass('markItUpDropMenu').append dropMenus(button.dropMenu)
            return
          group.appendTo div
          return
        levels.pop()
        div

      # markItUp! markups

      magicMarkups = (string) ->
        if string
          string = string.toString()
          string = string.replace(/\(\!\(([\s\S]*?)\)\!\)/g, (x, a) ->
            b = a.split('|!|')
            if altKey == true
              if b[1] != undefined then b[1] else b[0]
            else
              if b[1] == undefined then '' else b[0]
          )
          # [![prompt]!], [![prompt:!:value]!]
          string = string.replace(/\[\!\[([\s\S]*?)\]\!\]/g, (x, a) ->
            b = a.split(':!:')
            if abort == true
              return false
            value = prompt(b[0], if b[1] then b[1] else '')
            if value == null
              abort = true
            value
          )
          return string
        ''

      # prepare action

      prepare = (action) ->
        if $.isFunction(action)
          action = action(hash)
        magicMarkups action

      # build block to insert

      build = (string) ->
        openWith = prepare(clicked.openWith)
        placeHolder = prepare(clicked.placeHolder)
        replaceWith = prepare(clicked.replaceWith)
        closeWith = prepare(clicked.closeWith)
        openBlockWith = prepare(clicked.openBlockWith)
        closeBlockWith = prepare(clicked.closeBlockWith)
        multiline = clicked.multiline
        if replaceWith != ''
          block = openWith + replaceWith + closeWith
        else if selection == '' and placeHolder != ''
          block = openWith + placeHolder + closeWith
        else
          string = string or selection
          lines = [ string ]
          blocks = []
          if multiline == true
            lines = string.split(/\r?\n/)
          l = 0
          while l < lines.length
            line = lines[l]
            trailingSpaces = undefined
            if trailingSpaces = line.match(RegExp(' *$'))
              blocks.push openWith + line.replace(RegExp(' *$', 'g'), '') + closeWith + trailingSpaces
            else
              blocks.push openWith + line + closeWith
            l++
          block = blocks.join('\n')
        block = openBlockWith + block + closeBlockWith
        {
        block: block
        openBlockWith: openBlockWith
        openWith: openWith
        replaceWith: replaceWith
        placeHolder: placeHolder
        closeWith: closeWith
        closeBlockWith: closeBlockWith
        }

      # define markup to insert

      markup = (button) ->
        len = undefined
        j = undefined
        n = undefined
        i = undefined
        hash = clicked = button
        get()
        $.extend hash,
          line: ''
          root: options.root
          textarea: textarea
          selection: (@selection or '')
          caretPosition: caretPosition
          ctrlKey: ctrlKey
          shiftKey: shiftKey
          altKey: altKey
        # callbacks before insertion
        prepare options.beforeInsert
        prepare clicked.beforeInsert
        if ctrlKey == true and shiftKey == true or button.multiline == true
          prepare clicked.beforeMultiInsert
        $.extend hash, line: 1
        if ctrlKey == true and shiftKey == true
          lines = selection.split(/\r?\n/)
          j = 0
          n = lines.length
          i = 0
          while i < n
            if $.trim(lines[i]) != ''
              $.extend hash,
                line: ++j
                selection: lines[i]
              lines[i] = build(lines[i]).block
            else
              lines[i] = ''
            i++
          string = block: lines.join('\n')
          start = caretPosition
          len = string.block.length + (if browser.opera then n - 1 else 0)
        else if ctrlKey == true
          string = build(@selection)
          start = caretPosition + string.openWith.length
          len = string.block.length - (string.openWith.length) - (string.closeWith.length)
          len = len - (if string.block.match(RegExp(' $')) then 1 else 0)
          len -= fixIeBug(string.block)
        else if shiftKey == true
          string = build(@selection)
          start = caretPosition
          len = string.block.length
          len -= fixIeBug(string.block)
        else
          string = build(@selection)
          start = caretPosition + string.block.length
          len = 0
          start -= fixIeBug(string.block)
        if @selection == '' and string.replaceWith == ''
          caretOffset += fixOperaBug(string.block)
          start = caretPosition + string.openBlockWith.length + string.openWith.length
          len = string.block.length - (string.openBlockWith.length) - (string.openWith.length) - (string.closeWith.length) - (string.closeBlockWith.length)
          caretOffset = $$.val().substring(caretPosition, $$.val().length).length
          caretOffset -= fixOperaBug($$.val().substring(0, caretPosition))
        $.extend hash,
          caretPosition: caretPosition
          scrollPosition: scrollPosition
        if string.block != @selection and abort == false
          insert string.block
          set start, len
        else
          caretOffset = -1
        get()
        $.extend hash,
          line: ''
          selection: @selection
        # callbacks after insertion
        if ctrlKey == true and shiftKey == true or button.multiline == true
          prepare clicked.afterMultiInsert
        prepare clicked.afterInsert
        prepare options.afterInsert
        # refresh preview if opened
        if previewWindow and options.previewAutoRefresh
          refreshPreview()
        # reinit keyevent
        shiftKey = altKey = ctrlKey = abort = false
        return

      # Substract linefeed in Opera

      fixOperaBug = (string) ->
        if browser.opera
          return string.length - (string.replace(/\n*/g, '').length)
        0

      # Substract linefeed in IE

      fixIeBug = (string) ->
        if browser.msie
          return string.length - (string.replace(/\r*/g, '').length)
        0

      # add markup

      insert = (block) ->
        if document.selection
          newSelection = document.selection.createRange()
          newSelection.text = block
        else
          textarea.value = textarea.value.substring(0, caretPosition) + block + textarea.value.substring(caretPosition + @selection.length, textarea.value.length)
        return

      # set a selection

      set = (start, len) ->
        if textarea.createTextRange
# quick fix to make it work on Opera 9.5
          if browser.opera and browser.version >= 9.5 and len == 0
            return false
          range = textarea.createTextRange()
          range.collapse true
          range.moveStart 'character', start
          range.moveEnd 'character', len
          range.select()
        else if textarea.setSelectionRange
          textarea.setSelectionRange start, start + len
        textarea.scrollTop = scrollPosition
        textarea.focus()
        return

      # get the selection

      get = ->
        textarea.focus()
        scrollPosition = textarea.scrollTop
        if document.selection
          @selection = document.selection.createRange().text
          if browser.msie
# ie
            range = document.selection.createRange()
            rangeCopy = range.duplicate()
            rangeCopy.moveToElementText textarea
            caretPosition = -1
            while rangeCopy.inRange(range)
              rangeCopy.moveStart 'character'
              caretPosition++
          else
# opera
            caretPosition = textarea.selectionStart
        else
# gecko & webkit
          caretPosition = textarea.selectionStart
          @selection = textarea.value.substring(caretPosition, textarea.selectionEnd)
        @selection

      # open preview window

      preview = ->
        if typeof options.previewHandler == 'function'
          previewWindow = true
        else if options.previewInElement
          previewWindow = $(options.previewInElement)
        else if !previewWindow or previewWindow.closed
          if options.previewInWindow
            previewWindow = window.open('', 'preview', options.previewInWindow)
            $(window).unload ->
              previewWindow.close()
              return
          else
            iFrame = $('<iframe class="markItUpPreviewFrame"></iframe>')
            if options.previewPosition == 'after'
              iFrame.insertAfter footer
            else
              iFrame.insertBefore header
            previewWindow = iFrame[iFrame.length - 1].contentWindow or frame[iFrame.length - 1]
        else if altKey == true
          if iFrame
            iFrame.remove()
          else
            previewWindow.close()
          previewWindow = iFrame = false
        if !options.previewAutoRefresh
          refreshPreview()
        if options.previewInWindow
          previewWindow.focus()
        return

      # refresh Preview window

      refreshPreview = ->
        renderPreview()
        return

      renderPreview = ->
        phtml = undefined
        if options.previewHandler and typeof options.previewHandler == 'function'
          options.previewHandler $$.val()
        else if options.previewParser and typeof options.previewParser == 'function'
          data = options.previewParser($$.val())
          writeInPreview localize(data, 1)
        else if options.previewParserPath != ''
          $.ajax
            type: options.previewParserAjaxType
            dataType: 'text'
            global: false
            url: options.previewParserPath
            data: options.previewParserVar + '=' + encodeURIComponent($$.val())
            success: (data) ->
              writeInPreview localize(data, 1)
              return
        else
          if !template
            $.ajax
              url: options.previewTemplatePath
              dataType: 'text'
              global: false
              success: (data) ->
                writeInPreview localize(data, 1).replace(/<!-- content -->/g, $$.val())
                return
        false

      writeInPreview = (data) ->
        if options.previewInElement
          $(options.previewInElement).html data
        else if previewWindow and previewWindow.document
          try
            sp = previewWindow.document.documentElement.scrollTop
          catch e
            sp = 0
          previewWindow.document.open()
          previewWindow.document.write data
          previewWindow.document.close()
          previewWindow.document.documentElement.scrollTop = sp
        return

      # set keys pressed

      keyPressed = (e) ->
        shiftKey = e.shiftKey
        altKey = e.altKey
        ctrlKey = if !(e.altKey and e.ctrlKey) then e.ctrlKey or e.metaKey else false
        if e.type == 'keydown'
          if ctrlKey == true
            li = $('a[accesskey="' + (if e.keyCode == 13 then '\\n' else String.fromCharCode(e.keyCode)) + '"]', header)
            if li.length != 0
              ctrlKey = false
              setTimeout (->
                li.triggerHandler 'mouseup'
                return
              ), 1
              return false
          if e.keyCode == 13 or e.keyCode == 10
# Enter key
            if ctrlKey == true
# Enter + Ctrl
              ctrlKey = false
              markup options.onCtrlEnter
              return options.onCtrlEnter.keepDefault
            else if shiftKey == true
# Enter + Shift
              shiftKey = false
              markup options.onShiftEnter
              return options.onShiftEnter.keepDefault
            else
# only Enter
              markup options.onEnter
              return options.onEnter.keepDefault
          if e.keyCode == 9
# Tab key
            if shiftKey == true or ctrlKey == true or altKey == true
              return false
            if caretOffset != -1
              get()
              caretOffset = $$.val().length - caretOffset
              set caretOffset, 0
              caretOffset = -1
              return false
            else
              markup options.onTab
              return options.onTab.keepDefault
        return

      remove = ->
        $$.unbind('.markItUp').removeClass 'markItUpEditor'
        $$.parent('div').parent('div').parent('div.markItUp').parent('div').replaceWith $$
        relativeRef = $$.parent('div').parent('div').parent('div.markItUp').parent('div')
        if relativeRef.length
          relativeRef.replaceWith $$
        $$.data 'markItUp', null
        return

      $$ = $(this)
      textarea = this
      levels = []
      abort = false
      scrollPosition = caretPosition = 0
      caretOffset = -1
      options.previewParserPath = localize(options.previewParserPath)
      options.previewTemplatePath = localize(options.previewTemplatePath)
      if method
        switch method
          when 'remove'
            remove()
          when 'insert'
            markup params
          else
            $.error 'Method ' + method + ' does not exist on jQuery.markItUp'
        return
      init()
      return

  $.fn.markItUpRemove = ->
    @each ->
      $(this).markItUp 'remove'
      return

  $.markItUp = (settings) ->
    options = target: false
    $.extend options, settings
    if options.target
      return $(options.target).each(->
        $(this).focus()
        $(this).trigger 'insertion', [ options ]
        return
      )
    else
      $('textarea').trigger 'insertion', [ options ]
    return

  return
) jQuery