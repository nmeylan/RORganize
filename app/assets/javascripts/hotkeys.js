/**
 * User: nmeylan
 * Date: 25.08.14
 * Time: 00:31
 */
function bind_hotkeys() {
    var exclude_focus = ['TEXTAREA', 'INPUT'];
    var key_codes = {
        slash: 191,
        h: 72
    };
    $('body').keydown(function (e) {
        var focus = $(':focus')[0];
        if (focus === undefined || exclude_focus.indexOf(focus.nodeName) === -1) {
            switch (e.keyCode) {
                case key_codes['slash'] :
                    on_keydown_highlight_search(e);
                    break;
                case key_codes['h'] :
                    help_overlay(e);
                    break;
                default :
                    break;
            }
        }
    });
}
function on_keydown_highlight_search(e) {
    var search_box = $('#highlight_search');
    var input = search_box.find('input');
    search_box.keydown(function (e) {
        highlight_result(e, input)
    });

    if (search_box.is(':visible')) {
        close_highlight_search(search_box);
    } else {
        $('html').append('<div id="searchMask" style="position: fixed; top: 0px; left: 0px; width: 100%; height: 100%; display: block; opacity: 0.3; z-index: 10; background-color: rgb(0, 0, 0);"></div>').keydown(function (e) {
            if (e.keyCode === 27) close_highlight_search(search_box);
        });
        search_box.css('display', 'block').css('z-index', ' 9999');
        input.focus();
        highlight_result(undefined, input);
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
    $('.highlight').removeClass('highlight');
    $("#highlight_search_result_count").text('');

    if (filter.trim() !== '') {
        var count = 0;
        var matches = $('* :contains("' + filter + '"):visible').filter(function (index) {
            return $(this).children().length < 1;
        });
        var matches_size = matches.length;
        if (matches_size > 0 && matches_size < 5000) {
            matches.each(function (a) {
                $(this).addClass('highlight');
            });
        }

        matches = $('a:visible:contains("' + filter + '")');
        matches_size = matches.length;
        if (matches_size > 0 && matches_size < 5000) {
            matches.each(function (a) {
                $(this).addClass('highlight');
            });
        }
        count = $('.highlight').length;
        if (count > 0) {
            $("#highlight_search_result_count").text(count);
        }
    }
}

function help_overlay(e) {
    createOverlay("#hotkeys_overlay", 150);
    $("#hotkeys_overlay").overlay().load();
}