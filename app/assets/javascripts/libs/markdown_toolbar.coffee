@markdownSettings =
  nameSpace: 'markdown'
  previewParserPath: '/rorganize/preview_markdown'
  onShiftEnter:
    keepDefault: false
    openWith: '\n\n'
  markupSet: [
    [
      {
        name: 'h1'
        key: '1'
        placeHolder: 'Your title here...'
        openWith: '# '
      }
      {
        name: 'h2'
        key: '2'
        placeHolder: 'Your title here...'
        openWith: '## '
      }
      {
        name: 'h3'
        key: '3'
        openWith: '### '
        placeHolder: 'Your title here...'
      }
      {
        name: 'h4'
        key: '4'
        openWith: '#### '
        placeHolder: 'Your title here...'
      }
    ]
    [
      {
        name: 'Bold'
        key: 'B'
        openWith: '**'
        closeWith: '**'
        content: '<b>B</b>'
      }
      {
        name: 'Italic'
        key: 'I'
        openWith: '_'
        closeWith: '_'
        content: '<i>i</i>'
      }
      {
        name: 'Stroke'
        openWith: '~~'
        closeWith: '~~'
        content: '<s>S</s>'
      }
    ]
    [
      {
        name: 'Bulleted List'
        openWith: '- '
        iconName: 'list-unordered'
      }
      {
        name: 'Numeric List'
        iconName: 'list-ordered'
        openWith: (markItUp) ->
          markItUp.line + '. '

      }
      {
        name: 'Task List'
        openWith: '- [ ] '
        closeWith: ' '
        iconName: 'checklist'
      }
    ]
    [
      {
        name: 'Picture'
        key: 'P'
        replaceWith: '![[![Alternative text]!]]([![Url:!:http://]!] "[![Title]!]")'
        iconName: 'file-media'
      }
      {
        name: 'Link'
        key: 'L'
        openWith: '['
        closeWith: ']([![Url:!:http://]!] "[![Title]!]")'
        placeHolder: 'Your text to link here...'
        iconName: 'link'
      }
      { separator: '---------------' }
    ]
    [
      {
        name: 'Quotes'
        openWith: '> '
        iconName: 'quote'
      }
      {
        name: 'Code Block / Code'
        openWith: '(!(\t|!|`)!)'
        closeWith: '(!(`)!)'
        iconName: 'code'
      }
      {
        name: 'Horizontal rule'
        openWith: '\n***\n'
        iconName: 'horizontal-rule'
      }
    ]
  ]