/**
 * User: nmeylan
 * Date: 25.08.14
 * Time: 00:31
 */

function bind_hotkeys() {
    Mousetrap.bind('/', function (e) {
        on_keydown_highlight_search(e);
        return false;
    });
    Mousetrap.bind('h', function (e) {
        help_overlay();
    });
    Mousetrap.bind('g t', function (e) {
        go_next_tab();
    });
    Mousetrap.bind('g T', function (e) {
        go_previous_tab();
    });
    Mousetrap.bind('j', function (e) {
        line_downward();
    });
    Mousetrap.bind('k', function (e) {
        line_upward();
    });
    Mousetrap.bind('enter', function (e) {
        enter_actions(e);
    });
}
function on_keydown_highlight_search(e) {
    var search_box = $('#highlight-search');
    var input = search_box.find('input');
    search_box.keydown(function (e) {
        highlight_result(e, input);
    });

    if (search_box.is(':visible')) {
        close_highlight_search(search_box);
    } else {
        $('html').append('<div id="searchMask" style="position: fixed; top: 0px; left: 0px; width: 100%; height: 100%; display: block; opacity: 0.3; z-index: 10; background-color: rgb(0, 0, 0);"></div>').keydown(function (e) {
            if (e.keyCode === 27) {
                close_highlight_search(search_box);
            }
        });
        search_box.css('display', 'block').css('z-index', ' 9999');
        input.focus();
    }
}

function close_highlight_search(search_box) {
    search_box.css('display', 'none');
    $('#searchMask').remove();
}

function highlight_result(event, input) {
    var c = '';
    var typed_key = event !== undefined ? String.fromCharCode(event.which) : '_';
    if (typed_key.match(/^[a-z0-9'^éàèüäö]+$/i)) {
        c = typed_key;
    }
    var filter = input[0].value + c;
    if (event !== undefined && event.keyCode === 8) {
        filter = filter.substring(0, filter.length - 1);
    }
    $('.highlight-search-result').removeClass('highlight-search-result');
    $("#highlight-search-result-count").text('');

    if (filter.trim() !== '') {
        var count = 0;
        var matches = $('* :contains("' + filter + '"):visible').filter(function (index) {
            return $(this).children().length < 1;
        });
        var matches_size = matches.length;
        if (matches_size > 0 && matches_size < 5000) {
            matches.each(function (a) {
                $(this).addClass('highlight-search-result');
            });
        }

        matches = $('a:visible:contains("' + filter + '")');
        matches_size = matches.length;
        if (matches_size > 0 && matches_size < 5000) {
            matches.each(function (a) {
                $(this).addClass('highlight_search_result');
            });
        }
        count = $('.highlight-search-result').length;
        if (count > 0) {
            $("#highlight-search-result-count").text(count);
        }
    }
}
//h
function help_overlay() {
    $("#hotkeys-overlay").overlay().load();
}
//gt
function go_next_tab() {
    var current_tab = $("#main-menu").find('li.selected');
    var next_tab = current_tab.next();
    if (next_tab !== undefined) {
        next_tab.find('a').get(0).click();
    }

}
//gT
function go_previous_tab() {
    var current_tab = $("#main-menu").find('li.selected');
    var prev_tab = current_tab.prev();
    if (prev_tab !== undefined) {
        prev_tab.find('a').get(0).click();
    }
}
//j
function line_downward() {
    var list = $('table.list');
    if (list[0] !== undefined) {
        var row = list.find('tr.hover');
        if (row[0] !== undefined) {
            var next = row.next();
            if (next[0] !== undefined) {
                row.removeClass('hover');
                next.addClass('hover');
            }
        } else {
            list.find('tr:not(.header)').first().addClass('hover');
        }
    }
}

//k
function line_upward() {
    var list = $('table.list');
    if (list[0] !== undefined) {
        var row = list.find('tr.hover');
        if (row[0] !== undefined) {
            var prev = row.prev(':not(.header)');
            if (prev[0] !== undefined) {
                row.removeClass('hover');
                prev.addClass('hover');
            }
        } else {
            list.find('tr:not(.header)').last().addClass('hover');
        }
    }
}

function enter_actions(e) {
    var list = $('table.list');
    if (list[0] !== undefined) {
        var row = list.find('tr.hover');
        var link = row.find('a:not(.delete-link)');
        if (link[0] !== undefined) {
            console.log(link);
            link[0].click();
        }
    }
}