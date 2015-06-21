@markdownTextarea = (scope) ->
  el = scope.find('.fancyEditor')
  cacheResponse = []
  cacheResponse1 = []
  el.markItUpRemove().markItUp markdownSettings
  el.textcomplete [
    {
      match: /(^|\s)@(\w*)$/
      search: (term, callback) ->
        if $.isEmptyObject(cacheResponse)
          $.getJSON('/projects/' + gon.project_id + '/members').done (response) ->
            cacheResponse = response
            callback $.map(cacheResponse, (member) ->
              if member.indexOf(term) == 0 then member else null
            )
        else
          callback $.map(cacheResponse, (member) ->
            if member.indexOf(term) == 0 then member else null
          )
      replace: (value) ->
        '$1@' + value + ' '
      cache: true
    }
    {
      match: /(\s)#((\w*)|\d*)$/
      search: (term, callback) ->
        if $.isEmptyObject(cacheResponse1)
          $.getJSON('/projects/' + gon.project_id + '/issues_completion').done (response) ->
            cacheResponse1 = response
            callback $.map(cacheResponse1, (issue) ->
              tmp = '#' + issue[0]
              isTermMatch = issue[0].toString().indexOf(term) != -1 or issue[1].toLowerCase().indexOf(term) != -1
              if isTermMatch then tmp + ' ' + issue[1] else null
            )
        else
          callback $.map(cacheResponse1, (issue) ->
            tmp = '#' + issue[0]
            isTermMatch = issue[0].toString().indexOf(term) == 0 or issue[1].toLowerCase().indexOf(term) == 0
            if isTermMatch then tmp + ' ' + issue[1] else null
          )
      replace: (value) ->
        '$1' + value.substr(0, value.indexOf(' ')) + ' '
      cache: false
    }
  ]
  return