//
(function ($) {

    $(document).ready(function () {
        // hide flash messages
        display_flash();
        bind_hotkeys();

        //BIND ACTIONS : depending on which controller is called
        switch (gon.controller) {
            case 'documents' :
                on_load_documents_scripts();
                break;
            case 'issues' :
                on_load_issues_scripts();
                break;
            case 'members' :
                on_load_members_scripts();
                break;
            case 'profiles' :
                on_load_profiles_scripts();
                break;
            case 'issues_statuses' :
                on_load_issues_statuses_scripts();
                break;
            case 'permissions' :
                on_load_permissions_scripts();
                break;
            case 'projects' :
                on_load_projects_scripts();
                break;
            case 'rorganize' :
                on_load_rorganize_scripts();
                break;
            case 'roadmaps' :
                on_load_roadmap_scripts();
                break;
            case 'users' :
                on_load_users_scripts();
                break;
            case 'versions' :
                on_load_versions_scripts();
                break;
            case 'trackers' :
                on_load_trackers_scripts();
                break;
            case 'wiki' :
                on_load_wiki_scripts();
                break;
        }

        //MarkItUp
        markdown_textarea();
        focus_first_input_text();
        //BIND_CHZN-SELECT
        initialize_chosen();

        //bind info tag
        bind_info_tag();
        bind_commentable();
        bind_task_list_click();
        bind_color_editor();
        bind_dropdown();

        bind_table_list_actions();
        bind_date_field();
    });
    $(document).ajaxSend(function (e, xhr, options) {
        $("#loading").show();
    });

    $(document).ajaxComplete(function (e, xhr, options) {
        //BIND_CHZN-SELECT
        initialize_chosen();
        bind_table_list_actions();
        bind_task_list_click();
        bind_date_field();
        //MarkItUp
        if (!(options.dataType === 'json' || options.dataType === 'JSON')) {
            markdown_textarea();
            focus_first_input_text();
        }

        $("#loading").hide();
        if (xhr.getResponseHeader('flash-message')) {
            $.jGrowl(xhr.getResponseHeader('flash-message'), {
                theme: 'success'
            });
        }
        if (xhr.getResponseHeader('flash-error-message')) {
            $.jGrowl(xhr.getResponseHeader('flash-error-message'), {
                theme: 'failure', sticky: true
            });
        }
        var first_char = xhr.status.toString().charAt(0);
        var is_error = first_char === '5';
        if (is_error) {
            var text = 'An unexpected error occured, please try again!';
            $.jGrowl(text, {
                theme: 'failure'
            });
        }
    });

    String.prototype.endsWith = function (suffix) {
        return this.indexOf(suffix, this.length - suffix.length) !== -1;
    };

    //JSON
    $.fn.serializeJSON = function () {
        var json = {};
        $.map($(this).serializeArray(), function (n, i) {
            if (n.name.endsWith('[]')) {
                if (json[n.name] === undefined)
                    json[n.name] = [];
                json[n.name].push(n.value);
            }
            else
                json[n.name] = n.value;
        });
        return json;
    };

    $.fn.serializeObject = function () {
        var values = {};
        $("form input, form select, form textarea").each(function () {
            values[this.name] = $(this).val();
        });

        return values;
    };
    function clear_form_elements(ele) {

        $(ele).find(':input').each(function () {
            switch (this.type) {
                case 'password':
                case 'select-multiple':
                case 'select-one':
                case 'text':
                case 'textarea':
                    $(this).val('');
                    break;
                case 'checkbox':
                case 'radio':
                    this.checked = false;
            }
        });
    }

    //Override $-rails confirm behaviour.
    //$.rails.allowAction = function (link) {
    //    var message = link.attr('data-confirm');
    //    if (!message) {
    //        return true;
    //    }
    //    apprise(message, {confirm: true}, function (response) {
    //        if (response) {
    //            link.removeAttr('data-confirm');
    //            link.trigger('click.rails');
    //        }
    //    });
    //    return false;
    //};

})($);

$.expr[':'].contains = function (a, i, m) {
    return $(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
};

function initialize_chosen() {
    $(".chzn-select").chosen({disable_search_threshold: 5});
    $(".chzn-select-deselect").chosen({
        allow_single_deselect: true,
        disable_search_threshold: 5
    });
}
function display_flash() {
    var el;
    $(".flash").each(function () {
        el = $(this);
        if (el.text().trim() !== "") {
            el.css("display", "block");
            el.find(".close-flash").click(function (e) {
                $(this).parent().fadeOut();
            });
        } else {
            $(this).css("display", "none");
        }
    });
}
//Flash message
function error_explanation(message) {
    var el = $(".flash.alert");
    if (message !== null) {
        el.append(message).css("display", "block");
    }
}
function focus_first_input_text() {
    //$('.form input:visible[type=text]:not(.chzn-search-input)').first().focus();
}
function markdown_textarea() {
    var el = $('.fancyEditor');
    var cacheResponse = [];
    var cacheResponse1 = [];
    el.markItUpRemove().markItUp(markdownSettings);
    el.textcomplete([
        { // mention strategy
            match: /(^|\s)@(\w*)$/,
            search: function (term, callback) {
                if ($.isEmptyObject(cacheResponse)) {
                    $.getJSON('/projects/' + gon.project_id + '/members').done(function (response) {
                        cacheResponse = response;
                        callback($.map(cacheResponse, function (member) {
                            return member.indexOf(term) === 0 ? member : null;
                        }));
                    });
                } else {
                    callback($.map(cacheResponse, function (member) {
                        return member.indexOf(term) === 0 ? member : null;
                    }));
                }
            },
            replace: function (value) {
                return '$1@' + value + ' ';
            },
            cache: true
        },
        { // Issues strategy
            match: /(\s)#((\w*)|\d*)$/,
            search: function (term, callback) {
                if ($.isEmptyObject(cacheResponse1)) {
                    $.getJSON('/projects/' + gon.project_id + '/issues_completion').done(function (response) {
                        cacheResponse1 = response;
                        callback($.map(cacheResponse1, function (issue) {
                            var tmp = '#' + issue[0];
                            var isTermMatch = issue[0].toString().indexOf(term) !== -1 || issue[1].toLowerCase().indexOf(term) !== -1;
                            return isTermMatch ? tmp + ' ' + issue[1] : null;
                        }));
                    });
                } else {
                    callback($.map(cacheResponse1, function (issue) {
                        var tmp = '#' + issue[0];
                        var isTermMatch = issue[0].toString().indexOf(term) === 0 || issue[1].toLowerCase().indexOf(term) === 0;
                        return isTermMatch ? tmp + ' ' + issue[1] : null;
                    }));
                }
            },
            replace: function (value) {
                return '$1' + value.substr(0, value.indexOf(' ')) + ' ';
            },
            cache: false
        }
    ]);
}

function bind_table_list_actions() {
    var table_row = $('table.list tr');
    table_row.hover(function () {
        table_row.removeClass('hover');
        $(this).addClass('hover');
    }, function () {
        $(this).removeClass('hover');
    });
}

// CHECKBOX
function checkAllBox(selector, context) {
    $(selector).click(function (e) {
        e.preventDefault();
        var cases = $(context).find(':checkbox');
        var checked = $(this).attr("cb_checked") === 'b';
        cases.attr('checked', checked);
        $(this).attr("cb_checked", checked ? "a" : "b");
    });
}
// TOOLBOX
function checkAll(selector, context) {
    $(selector).click(function (e) {
        e.preventDefault();
        var cases = $(context).find(':checkbox:not(:disabled)');

        var checked = $(this).attr("cb_checked") === 'b';
        cases.attr('checked', checked);
        $(this).attr("cb_checked", checked ? "a" : "b");
        if (checked) {
            $('.issue-tr:not(.disabled-toolbox)').addClass("toolbox-selection");
        } else {
            $('.issue-tr:not(.disabled-toolbox)').removeClass("toolbox-selection");
        }
    });
}

function checkboxToolbox(selector) {
    $(selector + " input[type=checkbox]").change(function () {
        var row = $(this).parent("td").parent("tr");
        if ($(this).is(':checked')) {
            $(".toolbox-selection").removeClass("toolbox-last");
            row.addClass("toolbox-selection").addClass("toolbox-last");
        }
        else {
            row.removeClass("toolbox-selection").removeClass("toolbox-last");
        }
    });
}

function listTrClick(rows_selector) {
    var rows = $(rows_selector);
    rows.click(function (e) {
        if ($(e.target)[0].tagName !== "A") {
            if ($(this).hasClass('disabled-toolbox'))
                return false;
            var el = $(this);
            var target = e.target || e.srcElement;
            if (!e.shiftKey && !$(target).is('input') && !e.ctrlKey && !e.metaKey) {
                rows.find("input[type=checkbox]").attr('checked', false);
                rows.removeClass("toolbox-selection").removeClass("toolbox-last");
                el.find("input[type=checkbox]").attr('checked', true);
                el.addClass("toolbox-selection").addClass("toolbox-last");
            } else if (e.shiftKey) {
                e.preventDefault();
                var last_selected_row = $('.toolbox-last');
                if (last_selected_row.length > 0 && last_selected_row[0] != el[0]) {
                    var between_rows = last_selected_row[0].rowIndex > el[0].rowIndex ? last_selected_row.prevUntil(el[0]) : last_selected_row.nextUntil(el[0]);
                    rows.removeClass("toolbox-last");
                    between_rows.find("input[type=checkbox]:not(:disabled)").attr('checked', true);
                    between_rows.addClass("toolbox-selection");
                    el.find("input[type=checkbox]:not(:disabled)").attr('checked', true);
                    el.addClass("toolbox-selection");
                    el.addClass("toolbox-last");
                }
                el.find("input[type=checkbox]").attr('checked', true);
                el.addClass("toolbox-selection").addClass("toolbox-last");
            } else if (e.ctrlKey || e.metaKey) {
                rows.removeClass("toolbox-last");
                el.find("input[type=checkbox]").attr('checked', true);
                el.addClass("toolbox-selection").addClass("toolbox-last");
            }
        }
    });
}


//initializer with optional hash: options are:
// list needed to get checkboxes.
function init_toolbox(selector, id, options) {
    var self_element = $(selector);
    self_element.jeegoocontext(id);
    self_element.mousedown(function (e) {
            if (e.which === 3) {
                var self_element = $(this);
                var checkbox = self_element.find(':checkbox');
                if (!checkbox[0].disabled) {
                    checkbox.attr('checked', true);
                    self_element.addClass("toolbox-selection");
                }
                menu_item_updater(options);
            }
        }
    );

}

function menu_item_updater(options) {
    var array = [];
    var i = 0;
    $(options.list + ' input:checked').each(function () {
        array[i] = $(this).val();
        i++;
    });
    $.ajax({
        url: $(options.list).data("link"),
        type: 'GET',
        dateType: 'script',
        data: {
            ids: array
        }
    });
}


function bind_menu_actions(toolbox_id) {
    $(".submenu a").click(function (e) {
        e.preventDefault();
        // find the context of the selected options: e.g: "category" for update categories of the selected documents
        var context = _.without($(this).parents(".submenu").attr('class').split(' '), 'submenu', 'hover');
        //put new value into hidden field which name is matching with context
        $("input#value_" + context).val($(this).data("id"));
        $(toolbox_id).find("form").submit();
    });
    $("a.action-link").click(function (e) {
        e.preventDefault();
        var context = _.without($(this).parents("li").attr('class').split(' '), 'hover');
        //put new value into hidden field which name is matching with context
        $("input#value_" + context).val($(this).data("id"));
        $(toolbox_id).find("form").submit();
    });
}

//Toggle icon: fieldset
function multi_toogle(selector) {
    $(selector).click(function (e) {
        var self_element = $(this);
        e.preventDefault();
        var id = self_element.attr("id");
        if (self_element.hasClass('icon-collapsed')) {
            self_element.switchClass('icon-collapsed', 'icon-expanded');
            self_element.find("> .octicon").switchClass('octicon-chevron-right', 'octicon-chevron-down');
        } else {
            self_element.switchClass('icon-expanded', 'icon-collapsed');
            self_element.find("> .octicon").switchClass('octicon-chevron-down', 'octicon-chevron-right');
        }
        $(".content." + id).slideToggle();
    });
}
//toggle content
function uniq_toogle(trigger_id, content) {
    $(trigger_id).click(function (e) {
        e.preventDefault();
        if ($(this).hasClass('icon-collapsed')) {
            $(this).switchClass('icon-collapsed', 'icon-expanded');
            $(trigger_id + "> .octicon").switchClass('octicon-chevron-right', 'octicon-chevron-down');
        } else {
            $(this).switchClass('icon-expanded', 'icon-collapsed');
            $(trigger_id + "> .octicon").switchClass('octicon-chevron-down', 'octicon-chevron-right');
        }
        $(content).slideToggle();
    });
}

//filters
function radio_button_behaviour(selector) {
    var ary = ["all", "open", "close", "today", "finished"]; //for option that don't use select box
    var id = "#td-" + $(selector).attr('class');
    if ($.inArray($(selector).val(), ary) === -1) {
        $(id).show();
        $(id).find(".chzn-select").chosen();
    } else {
        $(id).hide();
        $(id + " input").val();
    }
}
function binding_radio_button(selector) {
    $(selector).click(function (e) {
        radio_button_behaviour(this);
    });
}



function bind_calendar_button() {
    $(".change-month").click(function (e) {
        e.preventDefault();
        var self_element = $(this);
        var c = self_element.attr("id");
        $.ajax({
            url: self_element.attr("href"),
            dataType: "script",
            data: {date: c}
        });
    });
}


function bind_version_change_positions() {
    $(".change-position").click(function (e) {
        e.preventDefault();
        var self_element = $(this);
        var vid = self_element.parents("tr").attr("id");
        var ope = self_element.attr("class").split(" ");
        ope = ope[ope.length - 1];
        if (ope === "inc" || ope === "dec") {
            $.ajax({
                url: self_element.attr("href"),
                type: "post",
                dataType: "script",
                data: {
                    id: vid,
                    operator: ope
                }
            });
        }

    });
}

function bind_save_project_position() {
    $("#save-position").click(function (e) {
        e.preventDefault();
        var p_ids = [];
        var url = $(this).data('link');
        $.each($(".project-list.sortable li.project"), function (project) {
            p_ids.push($(this).attr("id"));
        });
        $.ajax({
            url: url,
            type: "post",
            dataType: "script",
            data: {
                ids: p_ids
            }
        });
    });
}


/*
 *  WIKI organization
 */
function bind_organization_behaviour(selector) {
    var remove = false;
    $(selector).sortable({
        connectWith: ".connectedSortable",
        dropOnEmpty: true,
        forcePlaceholderSize: true,
        forceHelperSize: true,
        placeholder: "ui-state-highlight",
        items: "> li",
        sort: function (event, ui) {
            remove = (ui.item.attr("class").indexOf("parent") !== -1 && ui.item.find("li").length === 0);
        },
        beforeStop: function (event, ui) {
            if (remove) {
                $(ui.helper).remove();
                $(".connectedSortable").sortable("refresh");
                remove = false;
            }
        }
    });
}
function add_sub_item(selector) {
    $(selector).click(function (e) {
        e.preventDefault();
        var parent_id = $(this).parent("li").attr("id").split("_")[1];
        $(this).parent().after("<li class='parent' style='list-style:none'><ul id='parent-" + parent_id + "' class='connectedSortable'></ul></li>");
        bind_organization_behaviour(".connectedSortable");
    });
}
function bind_set_organization_button(main_selector, list_selector) {
    $(list_selector).click(function (e) {
        var dom_pages = $(main_selector);
        //{page_id => {parent_id : value, position : value},...}
        var serialized_hash = {};
        var parent_ids = [];
        var tmp_parent_id = null;
        var tmp_item_id = 0;
        var is_undifined = false;
        var tmp_position = 0;
        //Define for each page parent id
        $.each(dom_pages, function (index, value) {
            tmp_position = $(value).index();
            is_undifined = (typeof $(value).parent("ul").parent("li").prev().attr("id") === "undefined");
            //put parent id value if defined, else put nil
            tmp_parent_id = !is_undifined ? $(value).parent("ul").parent("li").prev().attr("id").split("-")[1] : null;
            tmp_item_id = $(value).attr("id").split("-")[1];
            parent_ids.push(tmp_parent_id);
            serialized_hash[tmp_item_id] = {
                parent_id: tmp_parent_id,
                position: tmp_position
            };

        });
        var url = $(this).data('link');
        $.ajax({
            url: url,
            type: 'PUT',
            dataType: 'script',
            data: {"pages_organization": serialized_hash}
        });
    });


}
function project_selection_filter() {
    $(".project-selection-filter").click(function (e) {
        $(".project-selection-filter").removeClass("selected");
        $(this).addClass("selected");

    });
}

// UPDATE DOM with style !
function on_deletion_effect(element_id) {
    $(element_id).fadeOut(400, function () {
        $(this).remove();
    });
}

function on_addition_effect(element_id, content) {
    $(element_id).hide().html(content).fadeIn(500);
}
function on_append_effect(element_id, content) {
    $(element_id).append(content).fadeIn(500);
}

function on_replace_effect(element_id, content) {
    $(element_id).replaceWith(content).fadeIn(500);
}

function replace_list_content(content) {
    on_replace_effect("#" + gon.controller.replace('_', '-') + "-content", content);
}


function ajax_trigger(element, event, method) {
    $(element).on(event, function (e) {

        e.preventDefault();
        var self_element = $(this);
        $.ajax({
            url: self_element.data("link"),
            type: method,
            dataType: 'script',
            data: {value: self_element.val()}
        });
    });

}

function bind_info_tag() {
    $("span.octicon-info").click(function (e) {
        e.preventDefault();
        var el = $(this);
        if ((el.html() === "" || el.find('.help').css('display') === 'none') && el.attr('title') !== undefined) {
            var info = $(write_info(el.attr('title')));
            el.html(info);
            info.hide().fadeIn();
        }
        else {
            el.find('.help').fadeOut(function () {
                this.remove();
            });
        }
    });
}

function write_info(info) {
    return "<span class='help'>" + info + "</span>";
}

function bind_commentable() {
    $('#add-comment-form .octicon-x').click(function (e) {
        $('#add-comment-form').fadeOut();
    });
    $('#new-comment-link').click(function (e) {
        $('#add-comment-form').show();
    });
}

function bind_task_list_click() {
    var el = $('.task-list-item-checkbox');
    el.unbind('click');
    el.click(function (e) {
        var el = $(this);
        var context = $(this).parents('div.markdown-renderer');
        var split_ary = context.attr('id').split('-');
        var element_type = split_ary[0];
        var element_id = split_ary[1];
        var check_index = context.find('.task-list-item-checkbox').index(el);
        var is_check = el.is(':checked');

        $.ajax({
            url: '/rorganize/task_list_action_markdown',
            type: 'post',
            dataType: 'script',
            data: {
                is_check: is_check,
                element_type: element_type,
                element_id: element_id,
                check_index: check_index
            }
        });
    });
}

function bind_tab_nav(tab_id) {
    var tabs = $('#' + tab_id);
    var links = tabs.find('a');
    var content_tabs = [];
    var selected_type_id = $('#' + tab_id).find('ul > li a.selected').data('tab_id');
    $('#' + selected_type_id).css('display', 'block');
    links.each(function () {
        content_tabs.push($('#' + $(this).data('tab_id')));
    });
    links.click(function (e) {
        e.preventDefault();
        var el = $(this);
        var tab_id = el.data('tab_id');
        for (var i = 0; i < content_tabs.length; i++) {
            content_tabs[i].hide();
        }
        links.removeClass('selected');
        $('#' + tab_id).show();
        el.addClass('selected');
    });
}

function bind_dropdown() {
    $('.dropdown-link').dropdown();
}

function bind_date_field() {
    var test_input = $('<input type="date" name="bday">');
    var input_date = $('[type="date"]');
    if (test_input.prop('type') != 'date') { //if browser doesn't support input type="date", load files for $ UI Date Picker
        if (input_date.hasClass('hasDatepicker')) {
            input_date.datepicker("destroy");
        }
        input_date.datepicker({dateFormat: 'dd/mm/yy'});
    }


}