// ----------------------------------------------------------------------------
// markItUp! Universal MarkUp Engine, JQuery plugin
// v 1.1.x
// Dual licensed under the MIT and GPL licenses.
// ----------------------------------------------------------------------------
// Copyright (C) 2007-2012 Jay Salvat
// http://markitup.jaysalvat.com/
// ----------------------------------------------------------------------------
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
// ----------------------------------------------------------------------------
(function ($) {
    $.fn.markItUp = function (settings, extraSettings) {
        var method, params, options, ctrlKey, shiftKey, altKey;
        ctrlKey = shiftKey = altKey = false;

        if (typeof settings == 'string') {
            method = settings;
            params = extraSettings;
        }

        options = {    id: '',
            nameSpace: '',
            root: '',
            previewHandler: false,
            previewInWindow: '', // 'width=800, height=600, resizable=yes, scrollbars=yes'
            previewInElement: '',
            previewAutoRefresh: true,
            previewPosition: 'after',
            previewTemplatePath: '~/templates/preview.html',
            previewParser: false,
            previewParserPath: '',
            previewParserVar: 'data',
            previewParserAjaxType: 'POST',
            resizeHandle: true,
            beforeInsert: '',
            afterInsert: '',
            onEnter: {},
            onShiftEnter: {},
            onCtrlEnter: {},
            onTab: {},
            markupSet: [
                { /* set */ }
            ]
        };
        $.extend(options, settings, extraSettings);

        // compute markItUp! path
        if (!options.root) {
            $('script').each(function (a, tag) {
                miuScript = $(tag).get(0).src.match(/(.*)jquery\.markitup(\.pack)?\.js$/);
                if (miuScript !== null) {
                    options.root = miuScript[1];
                }
            });
        }

        // Quick patch to keep compatibility with jQuery 1.9
        var uaMatch = function (ua) {
            ua = ua.toLowerCase();

            var match = /(chrome)[ \/]([\w.]+)/.exec(ua) ||
                /(webkit)[ \/]([\w.]+)/.exec(ua) ||
                /(opera)(?:.*version|)[ \/]([\w.]+)/.exec(ua) ||
                /(msie) ([\w.]+)/.exec(ua) ||
                ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec(ua) ||
                [];

            return {
                browser: match[ 1 ] || "",
                version: match[ 2 ] || "0"
            };
        };
        var matched = uaMatch(navigator.userAgent);
        var browser = {};

        if (matched.browser) {
            browser[matched.browser] = true;
            browser.version = matched.version;
        }
        if (browser.chrome) {
            browser.webkit = true;
        } else if (browser.webkit) {
            browser.safari = true;
        }

        return this.each(function () {
            var $$, textarea, levels, scrollPosition, caretPosition, caretOffset,
                clicked, hash, header, footer, previewWindow, template, iFrame, abort;
            $$ = $(this);
            textarea = this;
            levels = [];
            abort = false;
            scrollPosition = caretPosition = 0;
            caretOffset = -1;

            options.previewParserPath = localize(options.previewParserPath);
            options.previewTemplatePath = localize(options.previewTemplatePath);

            if (method) {
                switch (method) {
                    case 'remove':
                        remove();
                        break;
                    case 'insert':
                        markup(params);
                        break;
                    default:
                        $.error('Method ' + method + ' does not exist on jQuery.markItUp');
                }
                return;
            }

            // apply the computed path to ~/
            function localize(data, inText) {
                if (inText) {
                    return    data.replace(/("|')~\//g, "$1" + options.root);
                }
                return    data.replace(/^~\//, options.root);
            }

            // init and build editor
            function init() {
                id = '';
                nameSpace = '';
                if (options.id) {
                    id = 'id="' + options.id + '"';
                } else if ($$.attr("id")) {
                    id = 'id="markItUp' + ($$.attr("id").substr(0, 1).toUpperCase()) + ($$.attr("id").substr(1)) + '"';

                }
                if (options.nameSpace) {
                    nameSpace = 'class="' + options.nameSpace + '"';
                }
                $$.wrap('<div ' + nameSpace + '></div>');
                $$.wrap('<div ' + id + ' class="markItUp"></div>');
                $$.wrap('<div class="markItUpContainer"></div>');
                // add the header before the textarea
                header = $('<div class="markItUpHeader"></div>').insertBefore($$);
                $(headerMenu()).appendTo(header);
                $(dropMenus(options.markupSet)).appendTo(header);
                $$.wrap('<div class="markItUpEditorContainer"></div>');
                $$.addClass("markItUpEditor");
                // listen key events
                $$.bind('keydown.markItUp', keyPressed).bind('keyup', keyPressed);

                // bind an event to catch external calls
                $$.bind("insertion.markItUp", function (e, settings) {
                    if (settings.target !== false) {
                        get();
                    }
                    if (textarea === $.markItUp.focused) {
                        markup(settings);
                    }
                });

                // remember the last focus
                $$.bind('focus.markItUp', function () {
                    $.markItUp.focused = this;
                });

                if (options.previewInElement) {
                    refreshPreview();
                }
            }

            function headerMenu() {
                var div = $('<div class="markItUpHeaderMenu tabnav"></div>');
                var ul = $('<ul class="tabnav-tabs"></ul>');
                var writeMenu = $('<li><a href="#" class="tabnav-tab write-tab js-write-tab selected">Write</a></li>');
                var previewMenu = $('<li><a href="#" class="tabnav-tab preview-tab js-write-tab">Preview</a></li>');
                bindPreviewMenu(previewMenu.children('a'));
                bindWriteMenu(writeMenu.children('a'));
                writeMenu.appendTo(ul);
                previewMenu.appendTo(ul);
                ul.appendTo(div);
                return div;
            }

            function bindWriteMenu(el) {
                el.click(function (e) {
                    e.preventDefault();
                    var parents = el.parents();
                    var container;
                    for (var i = 0; i < parents.length; i++) {
                        if (parents[i].className === 'markItUpContainer') {
                            container = $(parents[i]);
                            break;
                        }
                    }
                    if (container) {
                        var textarea = container.children('.markItUpEditorContainer').children('textarea');
                        var buttons = container.children('.markItUpHeader').children('.markItUpButtons');
                        var markdownPreview = container.children('.markItUpEditorContainer').children('.markdown-preview');
                        textarea.show();
                        buttons.show();
                        container.children('.markItUpHeader').children('.markItUpHeaderMenu').children('ul').children('li').children('a').removeClass('selected');
                        el.addClass('selected');
                        if (markdownPreview)
                            markdownPreview.remove();
                    }
                });
            }

            function bindPreviewMenu(el) {
                el.click(function (e) {
                    e.preventDefault();
                    if (!el.hasClass('selected')) {
                        var parents = el.parents();
                        var container;
                        for (var i = 0; i < parents.length; i++) {
                            if (parents[i].className === 'markItUpContainer') {
                                container = $(parents[i]);
                                break;
                            }
                        }
                        if (container) {
                            var textarea = container.children('.markItUpEditorContainer').children('textarea');
                            var buttons = container.children('.markItUpHeader').children('.markItUpButtons');
                            var content = textarea.val();
                            if (content && content.trim() !== "") {
                                $.ajax({url: options.previewParserPath, dataType: 'JSON', type: 'POST', data: {content: content}, complete: function (data, status, xhr) {
                                    if (data.status === 200) {
                                        textarea.hide();
                                        buttons.hide();
                                        container.children('.markItUpEditorContainer').append('<div class="markdown-preview">' + data.responseText + '</div>');
                                        container.children('.markItUpHeader').children('.markItUpHeaderMenu').children('ul').children('li').children('a').removeClass('selected');
                                        el.addClass('selected');
                                    }
                                }});
                            }
                        }
                    }
                });

            }

            // recursively build header with dropMenus from markupset
            function dropMenus(markupSetGroups) {
                var div = $('<div class="markItUpButtons"></div>'), i = 0;

                var separator_count = 0;
                $.each(markupSetGroups, function () {
                    var group = $('<div class="markItUpGroup"></div>');
                    $.each(this, function () {
                        var button = this, t = '', title, link, j, icon;
                        button.title ? title = (button.key) ? (button.title || '') + ' [Ctrl+' + button.key + ']' : (button.title || '') : title = (button.key) ? (button.name || '') + ' [Ctrl+' + button.key + ']' : (button.name || '');
                        key = (button.key) ? 'accesskey="' + button.key + '"' : '';
                        if (button.separator) {

                        } else {
                            icon = button.iconName !== undefined ? '<span class="octicon-' + button.iconName + ' octicon"></span>' : (button.content !== undefined ? button.content : button.name)
                            link = $('<a href="#" ' + key + ' title="' + title + '" class="markItUpButton">' + icon + '</a>')
                                .bind("contextmenu.markItUp", function () { // prevent contextmenu on mac and allow ctrl+click
                                    return false;
                                }).bind('click.markItUp', function (e) {
                                    e.preventDefault();
                                }).bind("focusin.markItUp", function () {
                                    $$.focus();
                                }).bind('mouseup', function (e) {
                                    if (button.call) {
                                        eval(button.call)(e); // Pass the mouseup event to custom delegate
                                    }
                                    setTimeout(function () {
                                        markup(button)
                                    }, 1);
                                    return false;
                                }).bind('mouseenter.markItUp', function () {
                                    $('> div', this).show();
                                    $(document).one('click', function () { // close dropmenu if click outside
                                            $('ul ul', header).hide();
                                        }
                                    );
                                }).bind('mouseleave.markItUp', function () {
                                    $('> div', this).hide();
                                }).appendTo(group);
                            if (button.dropMenu) {
                                levels.push(i);
                                $(link).addClass('markItUpDropMenu').append(dropMenus(button.dropMenu));
                            }
                        }
                    });
                    group.appendTo(div);
                });
                levels.pop();
                return div;
            }

            // markItUp! markups
            function magicMarkups(string) {
                if (string) {
                    string = string.toString();
                    string = string.replace(/\(\!\(([\s\S]*?)\)\!\)/g,
                        function (x, a) {
                            var b = a.split('|!|');
                            if (altKey === true) {
                                return (b[1] !== undefined) ? b[1] : b[0];
                            } else {
                                return (b[1] === undefined) ? "" : b[0];
                            }
                        }
                    );
                    // [![prompt]!], [![prompt:!:value]!]
                    string = string.replace(/\[\!\[([\s\S]*?)\]\!\]/g,
                        function (x, a) {
                            var b = a.split(':!:');
                            if (abort === true) {
                                return false;
                            }
                            value = prompt(b[0], (b[1]) ? b[1] : '');
                            if (value === null) {
                                abort = true;
                            }
                            return value;
                        }
                    );
                    return string;
                }
                return "";
            }

            // prepare action
            function prepare(action) {
                if ($.isFunction(action)) {
                    action = action(hash);
                }
                return magicMarkups(action);
            }

            // build block to insert
            function build(string) {
                var openWith = prepare(clicked.openWith);
                var placeHolder = prepare(clicked.placeHolder);
                var replaceWith = prepare(clicked.replaceWith);
                var closeWith = prepare(clicked.closeWith);
                var openBlockWith = prepare(clicked.openBlockWith);
                var closeBlockWith = prepare(clicked.closeBlockWith);
                var multiline = clicked.multiline;

                if (replaceWith !== "") {
                    block = openWith + replaceWith + closeWith;
                } else if (selection === '' && placeHolder !== '') {
                    block = openWith + placeHolder + closeWith;
                } else {
                    string = string || selection;

                    var lines = [string], blocks = [];

                    if (multiline === true) {
                        lines = string.split(/\r?\n/);
                    }

                    for (var l = 0; l < lines.length; l++) {
                        line = lines[l];
                        var trailingSpaces;
                        if (trailingSpaces = line.match(/ *$/)) {
                            blocks.push(openWith + line.replace(/ *$/g, '') + closeWith + trailingSpaces);
                        } else {
                            blocks.push(openWith + line + closeWith);
                        }
                    }

                    block = blocks.join("\n");
                }

                block = openBlockWith + block + closeBlockWith;

                return {    block: block,
                    openBlockWith: openBlockWith,
                    openWith: openWith,
                    replaceWith: replaceWith,
                    placeHolder: placeHolder,
                    closeWith: closeWith,
                    closeBlockWith: closeBlockWith
                };
            }

            // define markup to insert
            function markup(button) {
                var len, j, n, i;
                hash = clicked = button;
                get();
                $.extend(hash, {    line: "",
                        root: options.root,
                        textarea: textarea,
                        selection: (selection || ''),
                        caretPosition: caretPosition,
                        ctrlKey: ctrlKey,
                        shiftKey: shiftKey,
                        altKey: altKey
                    }
                );
                // callbacks before insertion
                prepare(options.beforeInsert);
                prepare(clicked.beforeInsert);
                if ((ctrlKey === true && shiftKey === true) || button.multiline === true) {
                    prepare(clicked.beforeMultiInsert);
                }
                $.extend(hash, { line: 1 });

                if ((ctrlKey === true && shiftKey === true)) {
                    lines = selection.split(/\r?\n/);
                    for (j = 0, n = lines.length, i = 0; i < n; i++) {
                        if ($.trim(lines[i]) !== '') {
                            $.extend(hash, { line: ++j, selection: lines[i] });
                            lines[i] = build(lines[i]).block;
                        } else {
                            lines[i] = "";
                        }
                    }

                    string = { block: lines.join('\n')};
                    start = caretPosition;
                    len = string.block.length + ((browser.opera) ? n - 1 : 0);
                } else if (ctrlKey === true) {
                    string = build(selection);
                    start = caretPosition + string.openWith.length;
                    len = string.block.length - string.openWith.length - string.closeWith.length;
                    len = len - (string.block.match(/ $/) ? 1 : 0);
                    len -= fixIeBug(string.block);
                } else if (shiftKey === true) {
                    string = build(selection);
                    start = caretPosition;
                    len = string.block.length;
                    len -= fixIeBug(string.block);
                } else {
                    string = build(selection);
                    start = caretPosition + string.block.length;
                    len = 0;
                    start -= fixIeBug(string.block);
                }
                if ((selection === '' && string.replaceWith === '')) {
                    caretOffset += fixOperaBug(string.block);

                    start = caretPosition + string.openBlockWith.length + string.openWith.length;
                    len = string.block.length - string.openBlockWith.length - string.openWith.length - string.closeWith.length - string.closeBlockWith.length;

                    caretOffset = $$.val().substring(caretPosition, $$.val().length).length;
                    caretOffset -= fixOperaBug($$.val().substring(0, caretPosition));
                }
                $.extend(hash, { caretPosition: caretPosition, scrollPosition: scrollPosition });

                if (string.block !== selection && abort === false) {
                    insert(string.block);
                    set(start, len);
                } else {
                    caretOffset = -1;
                }
                get();

                $.extend(hash, { line: '', selection: selection });

                // callbacks after insertion
                if ((ctrlKey === true && shiftKey === true) || button.multiline === true) {
                    prepare(clicked.afterMultiInsert);
                }
                prepare(clicked.afterInsert);
                prepare(options.afterInsert);

                // refresh preview if opened
                if (previewWindow && options.previewAutoRefresh) {
                    refreshPreview();
                }

                // reinit keyevent
                shiftKey = altKey = ctrlKey = abort = false;
            }

            // Substract linefeed in Opera
            function fixOperaBug(string) {
                if (browser.opera) {
                    return string.length - string.replace(/\n*/g, '').length;
                }
                return 0;
            }

            // Substract linefeed in IE
            function fixIeBug(string) {
                if (browser.msie) {
                    return string.length - string.replace(/\r*/g, '').length;
                }
                return 0;
            }

            // add markup
            function insert(block) {
                if (document.selection) {
                    var newSelection = document.selection.createRange();
                    newSelection.text = block;
                } else {
                    textarea.value = textarea.value.substring(0, caretPosition) + block + textarea.value.substring(caretPosition + selection.length, textarea.value.length);
                }
            }

            // set a selection
            function set(start, len) {
                if (textarea.createTextRange) {
                    // quick fix to make it work on Opera 9.5
                    if (browser.opera && browser.version >= 9.5 && len == 0) {
                        return false;
                    }
                    range = textarea.createTextRange();
                    range.collapse(true);
                    range.moveStart('character', start);
                    range.moveEnd('character', len);
                    range.select();
                } else if (textarea.setSelectionRange) {
                    textarea.setSelectionRange(start, start + len);
                }
                textarea.scrollTop = scrollPosition;
                textarea.focus();
            }

            // get the selection
            function get() {
                textarea.focus();

                scrollPosition = textarea.scrollTop;
                if (document.selection) {
                    selection = document.selection.createRange().text;
                    if (browser.msie) { // ie
                        var range = document.selection.createRange(), rangeCopy = range.duplicate();
                        rangeCopy.moveToElementText(textarea);
                        caretPosition = -1;
                        while (rangeCopy.inRange(range)) {
                            rangeCopy.moveStart('character');
                            caretPosition++;
                        }
                    } else { // opera
                        caretPosition = textarea.selectionStart;
                    }
                } else { // gecko & webkit
                    caretPosition = textarea.selectionStart;

                    selection = textarea.value.substring(caretPosition, textarea.selectionEnd);
                }
                return selection;
            }

            // open preview window
            function preview() {
                if (typeof options.previewHandler === 'function') {
                    previewWindow = true;
                } else if (options.previewInElement) {
                    previewWindow = $(options.previewInElement);
                } else if (!previewWindow || previewWindow.closed) {
                    if (options.previewInWindow) {
                        previewWindow = window.open('', 'preview', options.previewInWindow);
                        $(window).unload(function () {
                            previewWindow.close();
                        });
                    } else {
                        iFrame = $('<iframe class="markItUpPreviewFrame"></iframe>');
                        if (options.previewPosition == 'after') {
                            iFrame.insertAfter(footer);
                        } else {
                            iFrame.insertBefore(header);
                        }
                        previewWindow = iFrame[iFrame.length - 1].contentWindow || frame[iFrame.length - 1];
                    }
                } else if (altKey === true) {
                    if (iFrame) {
                        iFrame.remove();
                    } else {
                        previewWindow.close();
                    }
                    previewWindow = iFrame = false;
                }
                if (!options.previewAutoRefresh) {
                    refreshPreview();
                }
                if (options.previewInWindow) {
                    previewWindow.focus();
                }
            }

            // refresh Preview window
            function refreshPreview() {
                renderPreview();
            }

            function renderPreview() {
                var phtml;
                if (options.previewHandler && typeof options.previewHandler === 'function') {
                    options.previewHandler($$.val());
                } else if (options.previewParser && typeof options.previewParser === 'function') {
                    var data = options.previewParser($$.val());
                    writeInPreview(localize(data, 1));
                } else if (options.previewParserPath !== '') {
                    $.ajax({
                        type: options.previewParserAjaxType,
                        dataType: 'text',
                        global: false,
                        url: options.previewParserPath,
                        data: options.previewParserVar + '=' + encodeURIComponent($$.val()),
                        success: function (data) {
                            writeInPreview(localize(data, 1));
                        }
                    });
                } else {
                    if (!template) {
                        $.ajax({
                            url: options.previewTemplatePath,
                            dataType: 'text',
                            global: false,
                            success: function (data) {
                                writeInPreview(localize(data, 1).replace(/<!-- content -->/g, $$.val()));
                            }
                        });
                    }
                }
                return false;
            }

            function writeInPreview(data) {
                if (options.previewInElement) {
                    $(options.previewInElement).html(data);
                } else if (previewWindow && previewWindow.document) {
                    try {
                        sp = previewWindow.document.documentElement.scrollTop
                    } catch (e) {
                        sp = 0;
                    }
                    previewWindow.document.open();
                    previewWindow.document.write(data);
                    previewWindow.document.close();
                    previewWindow.document.documentElement.scrollTop = sp;
                }
            }

            // set keys pressed
            function keyPressed(e) {
                shiftKey = e.shiftKey;
                altKey = e.altKey;
                ctrlKey = (!(e.altKey && e.ctrlKey)) ? (e.ctrlKey || e.metaKey) : false;

                if (e.type === 'keydown') {
                    if (ctrlKey === true) {
                        li = $('a[accesskey="' + ((e.keyCode == 13) ? '\\n' : String.fromCharCode(e.keyCode)) + '"]', header);
                        if (li.length !== 0) {
                            ctrlKey = false;
                            setTimeout(function () {
                                li.triggerHandler('mouseup');
                            }, 1);
                            return false;
                        }
                    }
                    if (e.keyCode === 13 || e.keyCode === 10) { // Enter key
                        if (ctrlKey === true) {  // Enter + Ctrl
                            ctrlKey = false;
                            markup(options.onCtrlEnter);
                            return options.onCtrlEnter.keepDefault;
                        } else if (shiftKey === true) { // Enter + Shift
                            shiftKey = false;
                            markup(options.onShiftEnter);
                            return options.onShiftEnter.keepDefault;
                        } else { // only Enter
                            markup(options.onEnter);
                            return options.onEnter.keepDefault;
                        }
                    }
                    if (e.keyCode === 9) { // Tab key
                        if (shiftKey == true || ctrlKey == true || altKey == true) {
                            return false;
                        }
                        if (caretOffset !== -1) {
                            get();
                            caretOffset = $$.val().length - caretOffset;
                            set(caretOffset, 0);
                            caretOffset = -1;
                            return false;
                        } else {
                            markup(options.onTab);
                            return options.onTab.keepDefault;
                        }
                    }
                }
            }

            function remove() {
                $$.unbind(".markItUp").removeClass('markItUpEditor');
                $$.parent('div').parent('div').parent('div.markItUp').parent('div').replaceWith($$);
                var relativeRef = $$.parent('div').parent('div').parent('div.markItUp').parent('div');
                if (relativeRef.length) {
                    relativeRef.replaceWith($$);
                }

                $$.data('markItUp', null);
            }

            init();
        });
    };

    $.fn.markItUpRemove = function () {
        return this.each(function () {
                $(this).markItUp('remove');
            }
        );
    };

    $.markItUp = function (settings) {
        var options = { target: false };
        $.extend(options, settings);
        if (options.target) {
            return $(options.target).each(function () {
                $(this).focus();
                $(this).trigger('insertion', [options]);
            });
        } else {
            $('textarea').trigger('insertion', [options]);
        }
    };
})(jQuery);