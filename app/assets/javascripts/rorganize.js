//
(function ($) {
    $(document).ready(function () {
        // hide flash messages
        display_flash();
        bind_hotkeys();

        //BIND ACTIONS : depending on which controller is called
        switch (gon.controller) {
            case 'coworkers' :
                on_load_coworkers_scripts();
                break;
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
            case 'wiki' :
                on_load_wiki_scripts();
                break;
        }

        //MarkItUp
        markdown_textarea();
        //BIND_CHZN-SELECT
        initialize_chosen();
        //Paginate
        per_page();

        //bind info tag
        bind_info_tag();
        bind_commentable();
        bind_task_list_click();
        bind_color_editor();

        //help overlay
        createOverlay("#hotkeys-overlay", 150);
        $('#open-hotkey-link').click(function (e) {
            e.preventDefault();
            $("#hotkeys-overlay").overlay().load();
        });
        bind_table_list_actions();

    });
    jQuery(document).ajaxSend(function (e, xhr, options) {
        jQuery("#loading").show();
        var token = jQuery("meta[name='csrf-token']").attr("content");
        xhr.setRequestHeader("X-CSRF-Token", token);
    });

    $(document).ajaxComplete(function (e, xhr, options) {
        //BIND_CHZN-SELECT
        initialize_chosen();
        bind_table_list_actions();
        bind_task_list_click();
        //MarkItUp
        if (options.dataType !== 'JSON') {
            markdown_textarea();
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
        var is_error = first_char === '5' || first_char === '4';
        if (is_error) {
            var text = xhr.status.toString() === '403' ? "You don't have the required permissions to do this action" : 'An unexpected error occured, please try again!';
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
        jQuery.map($(this).serializeArray(), function (n, i) {
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

    //Override jquery-rails confirm behaviour.
    $.rails.allowAction = function (link) {
        var message = link.attr('data-confirm');
        if (!message) {
            return true;
        }
        apprise(message, {confirm: true}, function (response) {
            if (response) {
                link.removeAttr('data-confirm');
                link.trigger('click.rails');
            }
        });
        return false;
    };

})(jQuery);

jQuery.expr[':'].contains = function (a, i, m) {
    return jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
};

function initialize_chosen() {
    $(".chzn-select").chosen({disable_search_threshold: 5});
    $(".chzn-select-deselect").chosen({allow_single_deselect: true, disable_search_threshold: 5});
}
function display_flash() {
    var el;
    jQuery(".flash").each(function () {
        el = jQuery(this);
        if (el.text().trim() !== "") {
            el.css("display", "block");
            el.find(".close-flash").click(function (e) {
                jQuery(this).parent().fadeOut();
            });
        } else {
            jQuery(this).css("display", "none");
        }
    });
}
//Flash message
function error_explanation(message) {
    var el = jQuery(".flash.alert");
    if (message !== null) {
        el.append(message).css("display", "block");
    }
}
function markdown_textarea() {
    var el = jQuery('.fancyEditor');
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
    el.focus();
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

$.tools.overlay.addEffect("slide",
    function (position, done) {
        this.getOverlay().removeClass('animated bounceOutUp');
        this.getOverlay().css(position).show().addClass('animated bounceInDown').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function () {
            $(this).removeClass('animated bounceInDown');
        });
    },
    // close function
    function (done) {
        // fade out the overlay
        this.getOverlay().removeClass('animated bounceInDown');
        this.getOverlay().addClass('animated bounceOutUp').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function () {
            $(this).removeClass('animated bounceOutUp').hide();
        });
    }
);
function createOverlay(id, top) {
    jQuery(id).overlay({
        // custom top position
        top: top,
        // some mask tweaks suitable for facebox-looking dialogs
        effect: 'slide',
        speed: 'slow',

        mask: {
            // you might also consider a "transparent" color for the mask
            color: '#000',
            // load mask a little faster
            loadSpeed: 200,
            opacity: 0.3,
            zIndex: 8
        },
        // disable this for modal dialog-type of overlays
        closeOnClick: false,
        // load it immediately after the construction
        load: false,
        onBeforeLoad: function (e) {
            var self = this;
            var overlay = self.getOverlay();
            $(self).removeClass('animated bounceInDown bounceOutUp');
            overlay.find('.close-button').remove();
            var close_button = $('<span class="medium-octicon octicon-x close-button"></span>');
            close_button.click(function (e) {
                e.preventDefault();
                self.close();
            });
            overlay.append(close_button);
        }

    });
}

// CHECKBOX
function checkAllBox(selector, context) {
    jQuery(selector).click(function (e) {
        e.preventDefault();
        var cases = jQuery(context).find(':checkbox');
        var checked = jQuery(this).attr("cb_checked") === 'b';
        cases.attr('checked', checked);
        jQuery(this).attr("cb_checked", checked ? "a" : "b");
    });
}
// TOOLBOX
function checkAll(selector, context) {
    jQuery(selector).click(function (e) {
        e.preventDefault();
        var cases = jQuery(context).find(':checkbox');
        var checked = jQuery(this).attr("cb_checked") === 'b';
        cases.attr('checked', checked);
        jQuery(this).attr("cb_checked", checked ? "a" : "b");
        if (checked) {
            jQuery('.issue-tr').addClass("toolbox-selection");
        } else {
            jQuery('.issue-tr').removeClass("toolbox-selection");
        }
    });
}

function checkboxToolbox(selector) {
    jQuery(selector + " input[type=checkbox]").change(function () {
        var row = jQuery(this).parent("td").parent("tr");
        if (jQuery(this).is(':checked')) {
            jQuery(".toolbox-selection").removeClass("toolbox-last");
            row.addClass("toolbox-selection").addClass("toolbox-last");
        }
        else {
            row.removeClass("toolbox-selection").removeClass("toolbox-last");
        }
    });
}

function listTrClick(rows_selector) {
    var rows = jQuery(rows_selector);
    rows.click(function (e) {
        var el = jQuery(this);
        var target = e.target || e.srcElement;
        if (!e.shiftKey && !$(target).is('input') && !e.ctrlKey && !e.metaKey) {
            rows.find("input[type=checkbox]").attr('checked', false);
            rows.removeClass("toolbox-selection").removeClass("toolbox-last");
            el.find("input[type=checkbox]").attr('checked', true);
            el.addClass("toolbox-selection").addClass("toolbox-last");
        } else if (e.shiftKey) {
            e.preventDefault();
            var last_selected_row = $('.toolbox-last');
            if (last_selected_row.length > 0) {
                var between_rows = last_selected_row[0].rowIndex > el[0].rowIndex ? last_selected_row.prevUntil(el[0]) : last_selected_row.nextUntil(el[0]);
                rows.removeClass("toolbox-last");
                between_rows.find("input[type=checkbox]").attr('checked', true);
                between_rows.addClass("toolbox-selection").addClass("toolbox-last");
            }
            el.find("input[type=checkbox]").attr('checked', true);
            el.addClass("toolbox-selection").addClass("toolbox-last");
        } else if (e.ctrlKey || e.metaKey) {
            rows.removeClass("toolbox-last");
            el.find("input[type=checkbox]").attr('checked', true);
            el.addClass("toolbox-selection").addClass("toolbox-last");
        }
    });
}


//initializer with optional hash: options are:
// list needed to get checkboxes.
function init_toolbox(selector, id, options) {
    var self_element = jQuery(selector);
    self_element.jeegoocontext(id);
    self_element.mousedown(function (e) {
            if (e.which === 3) {
                var self_element = jQuery(this);
                self_element.find(':checkbox').attr('checked', true);
                menu_item_updater(options);
                self_element.addClass("toolbox-selection");
            }
        }
    );

}

function menu_item_updater(options) {
    var array = [];
    var i = 0;
    jQuery(options.list + ' input:checked').each(function () {
        array[i] = jQuery(this).val();
        i++;
    });
    jQuery.ajax({
        url: jQuery(options.list).data("link"),
        type: 'GET',
        dateType: 'script',
        data: {
            ids: array
        }
    });
}


function bind_menu_actions(toolbox_id) {
    jQuery(".submenu a").click(function (e) {
        e.preventDefault();
        // find the context of the selected options: e.g: "category" for update categories of the selected documents
        var context = _.without(jQuery(this).parents(".submenu").attr('class').split(' '), 'submenu', 'hover');
        //put new value into hidden field which name is matching with context
        jQuery("input#value_" + context).val(jQuery(this).data("id"));
        jQuery(toolbox_id).find("form").submit();
    });
    jQuery("a.action-link").click(function (e) {
        e.preventDefault();
        var context = _.without(jQuery(this).parents("li").attr('class').split(' '), 'hover');
        //put new value into hidden field which name is matching with context
        jQuery("input#value_" + context).val(jQuery(this).data("id"));
        jQuery(toolbox_id).find("form").submit();
    });
    jQuery("#open-delete-overlay").click(function (e) {
        jQuery('#delete-overlay').overlay().load();
    });
}

//Toggle icon: fieldset
function multi_toogle(selector) {
    jQuery(selector).click(function (e) {
        var self_element = jQuery(this);
        e.preventDefault();
        var id = self_element.attr("id");
        if (self_element.hasClass('icon-collapsed')) {
            self_element.switchClass('icon-collapsed', 'icon-expanded');
            self_element.find("> .octicon").switchClass('octicon-chevron-right', 'octicon-chevron-down');
        } else {
            self_element.switchClass('icon-expanded', 'icon-collapsed');
            self_element.find("> .octicon").switchClass('octicon-chevron-down', 'octicon-chevron-right');
        }
        jQuery(".content." + id).slideToggle();
    });
}
//toggle content
function uniq_toogle(trigger_id, content) {
    jQuery(trigger_id).click(function (e) {
        e.preventDefault();
        if (jQuery(this).hasClass('icon-collapsed')) {
            jQuery(this).switchClass('icon-collapsed', 'icon-expanded');
            jQuery(trigger_id + "> .octicon").switchClass('octicon-chevron-right', 'octicon-chevron-down');
        } else {
            jQuery(this).switchClass('icon-expanded', 'icon-collapsed');
            jQuery(trigger_id + "> .octicon").switchClass('octicon-chevron-down', 'octicon-chevron-right');
        }
        jQuery(content).slideToggle();
    });
}

//filters
function radio_button_behaviour(selector) {
    var ary = ["all", "open", "close", "today", "finished"]; //for option that don't use select box
    var id = "#td-" + jQuery(selector).attr('class');
    if (jQuery.inArray(jQuery(selector).val(), ary) === -1) {
        jQuery(id).show();
    }else {
        jQuery(id).hide();
        jQuery(id + " input").val();
    }
}
function binding_radio_button(selector) {
    jQuery(selector).click(function (e) {
        radio_button_behaviour(this);
    });
}
//Param is json object that containing html: {'assigned_to':"<td>some html</td>",....}
function add_filters(json_content) {
    jQuery("#filters-list").change(function (e) {
        var domobject = jQuery(jQuery.parseJSON(json_content));
        var selected = jQuery(this).val();
        var tmp = "";
        var selector = "";
        jQuery(this).find("option").each(function () {
            tmp = jQuery(this).val();
            selector = "tr." + tmp.toLowerCase().replace(' ', '_');
            if ((jQuery(selector).length < 1) && jQuery.inArray(jQuery(this).val(), selected) !== -1) {
                jQuery("#filter-content").append(domobject[0][tmp]);

                //binding radio button action
                binding_radio_button("#filter-content " + selector + " input[type=radio]");
                radio_button_behaviour("#filter-content " + selector + " input[type=radio]");
                if (tmp === 'Status'){
                    jQuery("#filter-content " + selector + " input[type=radio]#status-open").attr('checked', 'checked');
                }

            } else if (jQuery(selector).length > 0 && jQuery.inArray(jQuery(this).val(), selected) === -1) {
                jQuery(selector).remove();
            }
        });
        $(".chzn-select").chosen();
        $(".chzn-select-deselect").chosen({allow_single_deselect: true});
    });
}
function load_filter(json_content, present_filters) {
    present_filters = jQuery.parseJSON(present_filters);
    var domobject = jQuery(jQuery.parseJSON(json_content));
    var tmp = "";
    var selector = "";
    var radio = "";
    if (_.any(present_filters)) {
        jQuery("#filter-content").html("");
        jQuery("#type-filter").attr('checked', 'checked');
        _.each(present_filters, function (value, key) {
            radio = "#" + key + "_" + value.operator;
            tmp = key;
            selector = "tr." + tmp.toLowerCase().replace(' ', '_');
            jQuery("#filters-list").find("option[value='" + key + "']").attr("selected", "selected");
            jQuery("#filter-content").append(domobject[0][tmp]);
            jQuery(radio).attr('checked', 'checked');
            jQuery();
            //binding radio button action
            binding_radio_button("#filter-content " + selector + " input[type=radio]");
            radio_button_behaviour("#filter-content " + selector + " input[type=radio]");
            if (value.operator !== 'open'){
                jQuery("#td-" + key).show();
            }
            jQuery("#td-" + key).find("input").val(value.value);
            if (_.isArray(value.value)) {
                _.each(value.value, function (v) {
                    jQuery("#td-" + key).find("select").find("option[value='" + v + "']").attr("selected", "selected");
                });
            }
        });
        jQuery(".content").hide();
    } else {
        jQuery("#filters-list").chosen();
        jQuery("#filters_list_chzn").hide();
        jQuery("#filter-content").hide();
        jQuery(".content").hide();
    }
}

//Overlay init code here

//Query overlay
function create_query_overlay(e, ajax_url) {
    e.preventDefault();
    jQuery('#create-query-overlay').overlay().load();
    jQuery.ajax({
        url: ajax_url,
        type: 'GET',
        dataType: 'script'
    });
}

//Per page issue list
function per_page() {
    jQuery("#per-page").change(function () {
        jQuery.ajax({
            url: jQuery(this).data("link"),
            data: {
                per_page: this.value
            },
            type: 'GET',
            dataType: 'script'
        });
    });
}


function bind_calendar_button() {
    jQuery(".change-month").click(function (e) {
        e.preventDefault();
        var self_element = jQuery(this);
        var c = self_element.attr("id");
        jQuery.ajax({
            url: self_element.attr("href"),
            dataType: "script",
            data: {date: c}
        });
    });
}


function bind_version_change_positions() {
    jQuery(".change-position").click(function (e) {
        e.preventDefault();
        var self_element = jQuery(this);
        var vid = self_element.parents("tr").attr("id");
        var ope = self_element.attr("class").split(" ");
        ope = ope[3];
        if (ope === "inc" || ope === "dec") {
            jQuery.ajax({
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
    jQuery("#save-position").click(function (e) {
        e.preventDefault();
        var p_ids = [];
        var url = jQuery(this).data('link');
        jQuery.each(jQuery(".project-list.sortable li.project"), function (project) {
            p_ids.push(jQuery(this).attr("id"));
        });
        console.log(p_ids);
        jQuery.ajax({
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
    jQuery(selector).sortable({
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
                jQuery(ui.helper).remove();
                jQuery(".connectedSortable").sortable("refresh");
                remove = false;
            }
        }
    });
}
function add_sub_item(selector) {
    jQuery(selector).click(function (e) {
        e.preventDefault();
        var parent_id = jQuery(this).parent("li").attr("id").split("_")[1];
        jQuery(this).parent().after("<li class='parent' style='list-style:none'><ul id='parent-" + parent_id + "' class='connectedSortable'></ul></li>");
        bind_organization_behaviour(".connectedSortable");
    });
}
function bind_set_organization_button(main_selector, list_selector) {
    jQuery(list_selector).click(function (e) {
        var dom_pages = jQuery(main_selector);
        //{page_id => {parent_id : value, position : value},...}
        var serialized_hash = {};
        var parent_ids = [];
        var tmp_parent_id = null;
        var tmp_item_id = 0;
        var is_undifined = false;
        var tmp_position = 0;
        //Define for each page parent id
        jQuery.each(dom_pages, function (index, value) {
            tmp_position = jQuery(value).index();
            is_undifined = (typeof jQuery(value).parent("ul").parent("li").prev().attr("id") === "undefined");
            //put parent id value if defined, else put nil
            tmp_parent_id = !is_undifined ? jQuery(value).parent("ul").parent("li").prev().attr("id").split("-")[1] : null;
            tmp_item_id = jQuery(value).attr("id").split("-")[1];
            parent_ids.push(tmp_parent_id);
            serialized_hash[tmp_item_id] = {parent_id: tmp_parent_id, position: tmp_position};

        });
        var url = jQuery(this).data('link');
        jQuery.ajax({
            url: url,
            type: 'PUT',
            dataType: 'script',
            data: {"pages_organization": serialized_hash}
        });
    });


}
function project_selection_filter() {
    jQuery(".project-selection-filter").click(function (e) {
        jQuery(".project-selection-filter").removeClass("selected");
        jQuery(this).addClass("selected");

    });
}
// LOG TIME
//Date is optional
function fill_log_issue_time_overlay(url, context, date) {
    if (jQuery(context).attr("id") === "pick-calendar"){
        date = jQuery(context).valueAsDate;
    }
    jQuery.ajax({
        url: url,
        type: 'GET',
        dataType: 'script',
        data: {spent_on: date }
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

function initialize_filters(options) {
    if (gon) {
        //Display or hide filter's conditions
        add_filters(gon.DOM_filter);
        load_filter(gon.DOM_filter, (options && options.dom_persisted_filter) ? options.dom_persisted_filter : gon.DOM_persisted_filter);
    }
    $("#type-filter").click(function (e) {
        $("#filters_list_chzn").show();
        $("#filter-content").show();
    });
    $("#type-all").click(function (e) {
        $("#filters_list_chzn").hide();
        $("#filter-content").hide();
    });

}

function ajax_trigger(element, event, method) {
    jQuery(element).on(event, function (e) {

        e.preventDefault();
        var self_element = jQuery(this);
        jQuery.ajax({
            url: self_element.data("link"),
            type: method,
            dataType: 'script',
            data: {value: self_element.val()}
        });
    });

}

function save_edit_filter(link_id, form_id) {
    jQuery(link_id).click(function (e) {
        e.preventDefault();
        var self_element = jQuery(this);
        json = jQuery(form_id).serializeJSON();
        jQuery.ajax({
            url: self_element[0].href,
            type: 'put',
            dataType: 'script',
            data: json
        });

    });
}

function bind_info_tag() {
    jQuery("span.octicon-info").click(function (e) {
        e.preventDefault();
        var el = jQuery(this);
        if (el.html() === "" || el.find('.help').css('display') === 'none') {
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

function bind_color_editor() {
    var editor_field = $(".color-editor-field");
    var color_bg = $("<span class='color-editor-bg'></span>");
    var container = $("<div class='color-editor'></div>");
    editor_field.wrap(container);
    color_bg.insertBefore(editor_field);
    color_bg.css('background-color', '#' + editor_field.val());
    editor_field.keydown(function (e) {
        var val = editor_field.val();
        if (val.indexOf('#') !== 0)
            editor_field.val('#' + val);
        color_bg.css('background-color', '#' + editor_field.val());
        editor_field.css('color', '#' + editor_field.val());
    });
}