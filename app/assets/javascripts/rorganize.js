//

(function ($) {
    $(document).ready(function() {
        // hide flash messages
        display_flash();
        $(".chzn-select").chosen();
        $(".chzn-select-deselect").chosen({allow_single_deselect: true});
    });

    $(document).ajaxComplete(function(e, xhr, options) {
        $(".chzn-select").chosen();
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
    });

    //JSON
    $.fn.serializeJSON = function () {
        var json = {};
        jQuery.map($(this).serializeArray(), function (n, i) {
            json[n['name']] = n['value'];
        });
        return json;
    };

    $.fn.serializeObject = function () {
        var values = {}
        $("form input, form select, form textarea").each(function () {
            values[this.name] = $(this).val();
        });

        return values;
    }
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

})(jQuery);

function display_flash() {
    jQuery(".flash").each(function () {
        if (jQuery(this).text() != "") {
            jQuery(this).css("display", "block");
        } else {
            jQuery(this).css("display", "none");
        }
    });
}
//Flash message
function error_explanation(message) {
    jQuery(".flash.alert").text("");
    if (message != null) {
        jQuery(".flash.alert").append(message).css("display", "block");
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
//bind action on delete button
function button_delete(url) {
    event.preventDefault();
    apprise('Are you sure to want to delete this item?', {
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
//bind action on delete button
function button_delete_with_data(url, data) {
    event.preventDefault();
    apprise('Are you sure to want to delete this item?', {
        'confirm': true
    }, function (r) {
        if (r) {
            jQuery.ajax({
                url: url,
                type: 'DELETE',
                dataType: 'script',
                data: eval(data)
            });
        }
    });
}
//bind action on post button
function button_post_with_message(url, message, data) {
    event.preventDefault();
    apprise(message, {
        'confirm': true
    }, function (r) {
        if (r) {
            jQuery.ajax({
                url: url,
                type: 'POST',
                dataType: 'script',
                data: eval(data)
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
function ajax_submit_form(form_id){
    var serialized_form = jQuery(form_id).serialize();
    var action = jQuery(form_id).attr("action");
    var method = jQuery(form_id).attr("method") ? jQuery(form_id).attr("method") :  "POST";
    jQuery.ajax({
        url : action,
        datatype : "script",
        type : method,
        data : serialized_form
    });
}

function activities_overlay(url) {
    jQuery('.open_overlay').click(function (e) {
        e.preventDefault();
        var id = jQuery(this).attr("id").split(".")[0];
        var date = jQuery(this).attr("id").split(".")[1];
        jQuery('#activity_overlay').overlay().load();
        jQuery.ajax({
            url: url,
            type: 'GET',
            data: {
                activity_date: date,
                issue_id: id
            },
            dataType: 'script'
        });
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
    select_status += "<a href='#' class='icon icon-del' id='link-" + item_value.replace(/\s/g, "") + "'></a>";
    select_status += "</div>";
    jQuery("#items").prepend(select_status);
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
            jQuery(".chzn-select").chosen();
        }
    });
}
function checklist_behaviour(statuses) {
    var checklist_statuses = statuses;
    var checklist_statuses_json = (eval(checklist_statuses.replace(/&quot;/g, "\"")));
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
        var checked = jQuery(this).attr("cb_checked") == 'b' ? true : false;
        cases.attr('checked', checked);
        jQuery(this).attr("cb_checked", checked ? "a" : "b");
    });
}
// TOOLBOX
function checkAll(selector, context) {
    jQuery(selector).click(function (e) {
        e.preventDefault();
        var cases = jQuery(context).find(':checkbox');
        var checked = jQuery(this).attr("cb_checked") === 'b' ? true : false;
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
// url needed to send the ajax request
// list needed to get checkboxes.
function init_toolbox(selector, id, options) {
    jQuery(selector).jeegoocontext(id, {
        livequery: true
    });
    jQuery(selector).mousedown(function (e) {
        if (e.which == 3) {
            jQuery(this).find(':checkbox').attr('checked', true);
            menu_item_updater(options);
            jQuery(this).addClass("toolbox_selection");
        }
    });
}

function menu_item_updater(options) {
    var array = [];
    var i = 0;
    jQuery(options["list"] + ' input:checked').each(function () {
        array[i] = jQuery(this).val();
        i++;
    });
    jQuery.ajax({
        url: options["url"],
        type: 'GET',
        dateType: 'script',
        data: {
            ids: array
        }
    });
}

//tooltip
function init_tooltip(selector, url) {
    jQuery(selector).tooltip({
        effect: 'slide',
        predelay: 1000,
        position: 'bottom left',
        offset: [10, 500],
        tip: '#tooltip',
        onBeforeShow: function () {
            jQuery.ajax({
                url: url,
                datatype: 'script',
                data: {
                    id: this.getTrigger().attr('id')
                }
            });
        }
    });
}

//Toogle icon: fieldset
function multi_toogle() {
    jQuery(".toggle").click(function (e) {
        e.preventDefault();
        var id = jQuery(this).attr("id");
        if (jQuery(this).hasClass('icon-collapsed'))
            jQuery(this).switchClass('icon-collapsed', 'icon-expanded');
        else
            jQuery(this).switchClass('icon-expanded', 'icon-collapsed');
        jQuery(".content." + id).slideToggle();
    });
}
//toogle content
function uniq_toogle(content) {
    jQuery(".toggle").click(function (e) {
        e.preventDefault();
        if (jQuery(this).hasClass('icon-collapsed'))
            jQuery(this).switchClass('icon-collapsed', 'icon-expanded');
        else
            jQuery(this).switchClass('icon-expanded', 'icon-collapsed');
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
        var rails_hash = json_content;
        var domobject = jQuery(jQuery.parseJSON(JSON.stringify(rails_hash)));
        var selected = jQuery(this).val();
        var tmp = "";
        var selector = "";
        jQuery(this).find("option").each(function () {
            tmp = jQuery(this).val();
            selector = "tr." + tmp.toLowerCase().replace(' ', '_');
            if ((jQuery(selector).length < 1) && jQuery.inArray(jQuery(this).val(), selected) != -1) {
                jQuery("#filter_content").append(domobject[0][tmp]);
                //binding action for date field
                jQuery(selector + " .calendar").datepicker({
                    dateFormat: 'yy-mm-dd'
                });
                //binding radio button action
                binding_radio_button("#filter_content " + selector + " input[type=radio]");
                radio_button_behaviour("#filter_content " + selector + " input[type=radio]");
                if (tmp == 'Status')
                    jQuery("#filter_content " + selector + " input[type=radio]#status_open").attr('checked', 'checked');
                jQuery(".chzn-select").chosen();
            } else if (jQuery(selector).length > 0 && jQuery.inArray(jQuery(this).val(), selected) == -1) {
                jQuery(selector).remove();
            } else {

            }
        });
    });
}
function load_filter(json_content, present_filters) {
    var rails_hash = json_content;
    var domobject = jQuery(jQuery.parseJSON(JSON.stringify(rails_hash)));
    var tmp = "";
    var selector = "";
    var radio = "";
    if (_.any(present_filters)) {
        jQuery("#type_filter").attr('checked', 'checked');
        _.each(present_filters, function (value, key) {
            radio = "#" + key + "_" + value.operator;
            tmp = key;
            selector = "tr." + tmp.toLowerCase().replace(' ', '_');
            jQuery("#filters_list").find("option[value='" + key + "']").attr("selected", "selected");
            jQuery("#filter_content").append(domobject[0][tmp]);
            jQuery(radio).attr('checked', 'checked');
            jQuery();
            //binding action for date field
            jQuery(selector + " .calendar").datepicker({
                dateFormat: 'yy-mm-dd'
            });
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
            jQuery(".chzn-select").trigger("liszt:updated");
        });
        jQuery(".content").hide();
    } else {
        jQuery("#filters_list_chzn").hide();
        jQuery("#filter_content").hide();
        jQuery(".content").hide();
    }
}

function bind_calendar_field() {

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

//Show checklist overlay
function show_checklist_overlay(url) {
    jQuery(".icon-checklist").click(function (e) {
        e.preventDefault();
        jQuery.ajax({
            url: url,
            data: {
                id: jQuery(this).attr('id')
            },
            dataType: 'script'
        });
        jQuery('#checklist_overlay').overlay().load();
    });
}

//Per page issue list
function per_page(url) {
    jQuery("#per_page").change(function () {
        jQuery.ajax({
            url: url,
            data: {
                per_page: jQuery('#per_page :selected').val()
            },
            type: 'GET',
            dataType: 'script'
        });
    });
}

function edit_notes(url) {
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
        edit_notes_bind_save_button("#send_edit_note", url, journal_id)
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

function activities_filter(url) {
    jQuery(".activities_filter").click(function (e) {
        var id = jQuery(this).attr("id");
        jQuery.ajax({
            url: url,
            type: 'POST',
            dataType: 'script',
            data: {type: id}
        });
    });
}

function bind_calendar_button(url) {
    jQuery(".change_month").click(function (e) {
        e.preventDefault();
        var c = jQuery(this).attr("id");
        jQuery.ajax({
            url: url,
            dataType: "script",
            data: {date: c}
        });
    });
}

function bind_star_project(vurl) {
    jQuery(".star").click(function (e) {
        e.preventDefault();
        var id = jQuery(this).parents("li").attr("id");
        jQuery.ajax({
            url: vurl,
            type: "post",
            dataType: "script",
            data: {
                star_project_id: id
            }
        });
    });
}

function bind_version_change_positions(vurl) {
    jQuery(".change_position").click(function () {
        var vid = jQuery(this).parents("tr").attr("id");
        var ope = jQuery(this).attr("class").split(" ");
        ope = ope[3];
        if (ope == "inc" || ope == "dec") {
            jQuery.ajax({
                url: vurl,
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

function bind_save_project_position(vurl) {
    jQuery("#save_position").click(function (e) {
        e.preventDefault();
        var p_ids = [];
        jQuery.each(jQuery(".project.list.sortable li"), function (project) {
            p_ids.push(jQuery(this).attr("id"));
        });
        jQuery.ajax({
            url: vurl,
            type: "post",
            dataType: "script",
            data: {
                ids: p_ids
            }
        });
    });
}

//Coworker
function bind_tr_ajax(selector, vurl) {
    jQuery(selector).click(function (e) {
        var member_id = jQuery(this).attr("id");
        var getActivity = jQuery(selector).hasClass("toolbox_selection");
        jQuery.ajax({
            url: vurl,
            type: "get",
            dataType: "script",
            data: {
                id: member_id,
                getAct: getActivity
            }
        })
    });
}

function bind_coworker_radio_filter(selector, list) {
    jQuery(selector).click(function () {
        var value = jQuery(this).val().replace(/\s/g, "_");
        if (value === "All") {
            jQuery(list + " tr").show();
        } else {
            jQuery(list + " tr").hide();
            jQuery(list + " tr." + value).show();
        }
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
function bind_set_organization_button(main_selector, list_selector, url) {
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

        jQuery.ajax({
            url: url,
            type: 'PUT',
            dataType: 'script',
            data: {"pages_organization": serialized_hash}
        });
    });


}
function project_selection_filter(url) {
    jQuery(".project_selection_filter").click(function (e) {
        jQuery(".project_selection_filter").removeClass("selected");
        jQuery(this).addClass("selected");
        var id = jQuery(this).attr("id");
        jQuery.ajax({
            url: url,
            type: 'GET',
            dataType: 'script',
            data: {filter: id}
        });
    });
}
// LOG TIME
//Date is optional
function fill_log_issue_time_overlay(url, issue_id, context, date) {
    if (jQuery(context).attr("id") === "pick_calendar")
        date = jQuery(context).val();

    jQuery.ajax({
        url: url,
        type: 'GET',
        dataType: 'script',
        data: {issue_id: issue_id, spent_on: date}
    });
}