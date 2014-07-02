//
(function ($) {
    $(document).ready(function () {
        // hide flash messages
        display_flash();

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
            case 'my' :
                on_load_my_scripts();
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
            case 'roadmap' :
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
        jQuery('.fancyEditor').markItUp(mySettings);
        //BIND_CHZN-SELECT
        $(".chzn-select").chosen();
        $(".chzn-select-deselect").chosen({allow_single_deselect: true});


    });
    jQuery(document).ajaxSend(function (e, xhr, options) {
        jQuery("#loading").show();
        var token = jQuery("meta[name='csrf-token']").attr("content");
        xhr.setRequestHeader("X-CSRF-Token", token);
    });

    $(document).ajaxComplete(function (e, xhr, options) {
        //BIND_CHZN-SELECT
        $(".chzn-select").chosen();
        $(".chzn-select-deselect").chosen({allow_single_deselect: true});

        //MarkItUp
        jQuery('.fancyEditor').markItUp(mySettings);
        $("#loading").hide();
        if (xhr.getResponseHeader('flash-message')) {
            $.jGrowl(xhr.getResponseHeader('flash-message'), {
                theme: 'success'
            });
        }
        if (xhr.getResponseHeader('flash-error-message')) {
            $.jGrowl(xhr.getResponseHeader('flash-error-message'), {
                theme: 'failure'
            });
        }
        var first_char = xhr.status.toString().charAt(0);
        var is_error = first_char == '5' || first_char == '4';
        if (is_error) {
            $.jGrowl('An unexpected error occured, please try again!', {
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
            if (n['name'].endsWith('[]')) {
                if (json[n['name']] === undefined)
                    json[n['name']] = [];
                json[n['name']].push(n['value']);
            }
            else
                json[n['name']] = n['value'];
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
    }


})(jQuery);


function display_flash() {
    var el;
    jQuery(".flash").each(function () {
        el = jQuery(this);
        if (el.text().trim() != "") {
            el.css("display", "block");
            el.find(".close_flash").click(function(e){
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
    if (message != null) {
        el.append(message).css("display", "block");
    }

}

//bind action on delete button
function button_delete_with_message(url, message) {
    event.preventDefault();
    apprise('' + message, {
        'confirm': true
    }, function (r) {
        if (r) {
            jQuery.ajax({
                url: url,
                type: 'DELETE',
                dataType: 'script'
            });
        }
    });
}

function createOverlay(id, top) {
    jQuery(id).overlay({
        // custom top position
        top: top,
        // some mask tweaks suitable for facebox-looking dialogs
        mask: {
            // you might also consider a "transparent" color for the mask
            color: '#000',
            // load mask a little faster
            loadSpeed: 200,
            opacity: 0.3
        },
        // disable this for modal dialog-type of overlays
        closeOnClick: false,
        // load it immediately after the construction
        load: false

    });
}

//Submit form with ajax
function ajax_submit_form(form_id) {
    var serialized_form = jQuery(form_id).serialize();
    var action = jQuery(form_id).attr("action");
    var method = jQuery(form_id).attr("method") ? jQuery(form_id).attr("method") : "POST";
    jQuery.ajax({
        url: action,
        datatype: "script",
        type: method,
        data: serialized_form
    });
}

//Checklist JS
function checklist_statuses_color(self) {
    var statuses = {};
    statuses['New'] = "#9B4D4D";
    statuses['Started'] = "#FFC773";
    statuses['Finish'] = "#3E7C3E";
    var id = jQuery(self).attr("id").replace('(', '\\(').replace(')', '\\)');
    jQuery("#label-" + id).css("color", statuses[jQuery("#" + id + " :selected").text()]);
}
function checklist_remove_item() {
    jQuery("#items .icon-del").click(function () {
        var id = jQuery(this).attr('id').replace('link-', '').replace('(', '\\(').replace(')', '\\)');
        jQuery("#item-" + id).remove();
    });
}
function checklist_build_select(item_value, option_for_select) {
    var select_status = "<div class='autocomplete-combobox nosearch no-padding_left' id='item-" + item_value.replace(/\s/g, "") + "'>";
    select_status += "<select name='items[" + item_value + "]' class='chzn-select cbb-medium' id='" + item_value.replace(/\s/g, "") + "'>" + option_for_select + "</select>";
    select_status += "<label style='margin-left:10px' id='label-" + item_value.replace(/\s/g, "") + "'>" + item_value + "</label>";
    select_status += "<a href='#' class='icon icon-del' id='link-" + item_value.replace(/\s/g, "") + "'><span class='octicon octicon-trashcan'></span></a>";
    select_status += "</div>";
    jQuery("#items").prepend(select_status);
    jQuery(".chzn-select").chosen();
}
function checklist_add_item(checklist_statuses_json) {
    jQuery("#add_checklist_item").click(function () {
        var item_value = jQuery("#item_field").val();
        if (item_value != "") {
            //Options for select
            var option_for_select = "";
            jQuery(jQuery.parseJSON(JSON.stringify(checklist_statuses_json))).each(function () {
                var ID = this.id;
                var NAME = this.name;
                option_for_select += "<option value ='" + ID + "'>" + NAME + "</option>";
            });
            //Adding new select box with label in DOM
            checklist_build_select(item_value, option_for_select);
            //reset text field value
            jQuery("#item_field").val('');
            //new item is the first
            checklist_statuses_color(jQuery("#items select:first"));
            //binding on change event for the new select
            jQuery("#items select").change(function () {
                checklist_statuses_color(jQuery(this));
            });

            //binding delete button
            checklist_remove_item();
        }
    });
}
function checklist_behaviour(statuses) {
    var checklist_statuses_json = (eval(statuses.replace(/&quot;/g, "\"")));
    jQuery(function () {
        jQuery("#items").sortable();
        jQuery("#items").disableSelection();
    });
    jQuery(document).ready(function () {
        //Binding event on select boxes
        jQuery("#items select").each(function () {
            checklist_statuses_color(this);
        });
        jQuery("#items select").change(function () {
            checklist_statuses_color(this);
        });
    });
    //add button
    checklist_add_item(checklist_statuses_json);
    //Binding event for del button
    checklist_remove_item();
}
// CHECKBOX
function checkAllBox(selector, context) {
    jQuery(selector).click(function (e) {
        e.preventDefault();
        var cases = jQuery(context).find(':checkbox');
        var checked = jQuery(this).attr("cb_checked") == 'b';
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
        checked ? jQuery(".issue_tr").addClass("toolbox_selection") : jQuery(".issue_tr").removeClass("toolbox_selection");
    });
}

function checkboxToolbox(selector) {
    jQuery(selector + " input[type=checkbox]").click(function () {
        if (jQuery(this).is(':checked'))
            jQuery(this).parent("td").parent("tr").addClass("toolbox_selection");
        else
            jQuery(this).parent("td").parent("tr").removeClass("toolbox_selection");
    });
}

function listTrClick(selector) {
    jQuery(selector).click(function () {
        if (jQuery(this).find("input[type=checkbox]").is(':checked')) {
            jQuery(this).find("input[type=checkbox]").attr('checked', false);
            jQuery(this).removeClass("toolbox_selection");
        }
        else {
            jQuery(this).find("input[type=checkbox]").attr('checked', true);
            jQuery(this).addClass("toolbox_selection");
        }
    });
}

function listUniqTrClick(selector) {
    jQuery(selector).click(function () {
        if (jQuery(this).find("input[type=checkbox]").is(':checked')) {
            jQuery(this).find("input[type=checkbox]").attr('checked', false);
            jQuery(this).removeClass("toolbox_selection");
        }
        else {
            jQuery(selector).find("input[type=checkbox]").attr('checked', false);
            jQuery(selector).removeClass("toolbox_selection");
            jQuery(this).find("input[type=checkbox]").attr('checked', true);
            jQuery(this).addClass("toolbox_selection");
        }
    });
}

//initializer with optional hash: options are:
// list needed to get checkboxes.
function init_toolbox(selector, id, options) {
    var self_element = jQuery(selector);
    self_element.jeegoocontext(id, {
        livequery: true
    });
    self_element.mousedown(function (e) {
            if (e.which == 3) {
                var self_element = jQuery(this);
                self_element.find(':checkbox').attr('checked', true);
                menu_item_updater(options);
                self_element.addClass("toolbox_selection");
            }
        }
    );

}

function menu_item_updater(options) {
    var array = [];
    var i = 0;
    jQuery(options["list"] + ' input:checked').each(function () {
        array[i] = jQuery(this).val();
        i++;
    });
    jQuery.ajax({
        url: jQuery(options["list"]).data("link"),
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
    jQuery("a.action_link").click(function (e) {
        e.preventDefault();
        var context = _.without(jQuery(this).parents("li").attr('class').split(' '), 'hover');
        //put new value into hidden field which name is matching with context
        jQuery("input#value_" + context).val(jQuery(this).data("id"));
        jQuery(toolbox_id).find("form").submit();
    });
    jQuery("#open_delete_overlay").click(function (e) {
        jQuery('#delete_overlay').overlay().load();
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
        }else {
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
    if (jQuery.inArray(jQuery(selector).val(), ary) == -1)
        jQuery(id).show();
    else {
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
    jQuery("#filters_list").change(function (e) {
        var domobject = jQuery(jQuery.parseJSON(json_content));
        var selected = jQuery(this).val();
        var tmp = "";
        var selector = "";
        jQuery(this).find("option").each(function () {
            tmp = jQuery(this).val();
            selector = "tr." + tmp.toLowerCase().replace(' ', '_');
            if ((jQuery(selector).length < 1) && jQuery.inArray(jQuery(this).val(), selected) != -1) {
                jQuery("#filter_content").append(domobject[0][tmp]);

                //binding radio button action
                binding_radio_button("#filter_content " + selector + " input[type=radio]");
                radio_button_behaviour("#filter_content " + selector + " input[type=radio]");
                if (tmp == 'Status')
                    jQuery("#filter_content " + selector + " input[type=radio]#status_open").attr('checked', 'checked');

            } else if (jQuery(selector).length > 0 && jQuery.inArray(jQuery(this).val(), selected) == -1) {
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
        jQuery("#filter_content").html("");
        jQuery("#type_filter").attr('checked', 'checked');
        _.each(present_filters, function (value, key) {
            radio = "#" + key + "_" + value.operator;
            tmp = key;
            selector = "tr." + tmp.toLowerCase().replace(' ', '_');
            jQuery("#filters_list").find("option[value='" + key + "']").attr("selected", "selected");
            jQuery("#filter_content").append(domobject[0][tmp]);
            jQuery(radio).attr('checked', 'checked');
            jQuery();
            //binding radio button action
            binding_radio_button("#filter_content " + selector + " input[type=radio]");
            radio_button_behaviour("#filter_content " + selector + " input[type=radio]");
            if (value.operator != 'open')
                jQuery("#td-" + key).show();
            jQuery("#td-" + key).find("input").val(value.value);
            if (_.isArray(value.value)) {
                _.each(value.value, function (v) {
                    jQuery("#td-" + key).find("select").find("option[value='" + v + "']").attr("selected", "selected");
                });
            }
        });
        jQuery(".content").hide();
    } else {
        jQuery("#filters_list").chosen();
        jQuery("#filters_list_chzn").hide();
        jQuery("#filter_content").hide();
        jQuery(".content").hide();
    }
}

//Overlay init code here

//Query overlay
function create_query_overlay(e, ajax_url) {
    e.preventDefault();
    jQuery('#create_query_overlay').overlay().load();
    jQuery.ajax({
        url: ajax_url,
        type: 'GET',
        dataType: 'script'
    });
}

//Per page issue list
function per_page() {
    jQuery("#per_page").change(function () {
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

function edit_notes() {
    jQuery(".edit_notes").click(function (e) {
        e.preventDefault();
        jQuery('#edit_note_form').remove();
        var journal_id = jQuery(this).attr("id").replace("link_edit_note_", '');
        var note_id = "#note_" + journal_id;
        var form = "<div id='edit_note_form' class='edit_note'>";
        form += "<textarea id='edit_note' name='notes' rows='12'>";
        form += jQuery(note_id).text();
        form += "</textarea>";
        form += "<button id='send_edit_note'>Save</button>";
        form += "</div>";
        jQuery(note_id).append(form);
        jQuery('#edit_note').markItUp(mySettings);
        edit_notes_bind_save_button("#send_edit_note", jQuery(this).attr("href"), journal_id)
    });
}

function edit_notes_bind_save_button(id, url, journal_id) {
    jQuery(id).click(function (e) {
        e.preventDefault();
        jQuery.ajax({
            url: url,
            type: 'post',
            dataType: 'script',
            data: {
                notes: jQuery("#edit_note").val(),
                journal_id: journal_id
            }
        });
    })
}

function bind_calendar_button() {
    jQuery(".change_month").click(function (e) {
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

function bind_star_project() {
    jQuery(".star").click(function (e) {
        var self_element = jQuery(this);
        self_element.hasClass("icon-fav-off") ? self_element.switchClass('icon-fav-off', 'icon-fav') : self_element.switchClass('icon-fav', 'icon-fav-off');
    });
}

function bind_version_change_positions() {
    jQuery(".change_position").click(function (e) {
        e.preventDefault();
        var self_element = jQuery(this);
        var vid = self_element.parents("tr").attr("id");
        var ope = self_element.attr("class").split(" ");
        ope = ope[3];
        if (ope == "inc" || ope == "dec") {
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
    jQuery("#save_position").click(function (e) {
        e.preventDefault();
        var p_ids = [];
        var url = jQuery(this).data('link');
        jQuery.each(jQuery(".project_list.sortable li"), function (project) {
            p_ids.push(jQuery(this).attr("id"));
        });
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
        jQuery(this).parent().after("<li class='parent' style='list-style:none'>\n\
                <ul id='parent_" + parent_id + "' class='connectedSortable'></ul></li>");
        bind_organization_behaviour(".connectedSortable");
    });
}
function bind_set_organization_button(main_selector, list_selector) {
    jQuery(list_selector).click(function (e) {
        var dom_pages = jQuery(main_selector);
        //{page_id => {parent_id : value, position : value},...}
        var serialized_hash = {};
        var parent_ids = new Array();
        var tmp_parent_id = null;
        var tmp_item_id = 0;
        var is_undifined = false;
        var tmp_position = 0;
        //Define for each page parent id
        jQuery.each(dom_pages, function (index, value) {
            tmp_position = jQuery(value).index();
            is_undifined = (typeof jQuery(value).parent("ul").parent("li").prev().attr("id") === "undefined");
            //put parent id value if defined, else put nil
            tmp_parent_id = !is_undifined ? jQuery(value).parent("ul").parent("li").prev().attr("id").split("_")[1] : null;
            tmp_item_id = jQuery(value).attr("id").split("_")[1];
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
    jQuery(".project_selection_filter").click(function (e) {
        jQuery(".project_selection_filter").removeClass("selected");
        jQuery(this).addClass("selected");

    });
}
// LOG TIME
//Date is optional
function fill_log_issue_time_overlay(url, context, date) {
    if (jQuery(context).attr("id") === "pick_calendar")
        date = jQuery(context).val();

    jQuery.ajax({
        url: url,
        type: 'GET',
        dataType: 'script',
        data: {spent_on: date}
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

function on_replace_effect(element_id, content) {
    $(element_id).replaceWith(content).fadeIn(500);
}

function initialize_filters(options) {
    if (gon) {
        //Display or hide filter's conditions
        add_filters(gon.DOM_filter);
        load_filter(gon.DOM_filter, (options && options["dom_persisted_filter"]) ? options["dom_persisted_filter"] : gon.DOM_persisted_filter);
    }
    $("#type_filter").click(function (e) {
        $("#filters_list_chzn").show();
        $("#filter_content").show();
    });
    $("#type_all").click(function (e) {
        $("#filters_list_chzn").hide();
        $("#filter_content").hide();
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
        })

    })
}

