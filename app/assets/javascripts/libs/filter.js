/**
 * User: nmeylan
 * Date: 18.10.14
 * Time: 08:11
 */
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
                if (tmp === 'Status') {
                    jQuery("#filter-content " + selector + " input[type=radio]#status-open").attr('checked', 'checked');
                }

            } else if (jQuery(selector).length > 0 && jQuery.inArray(jQuery(this).val(), selected) === -1) {
                jQuery(selector).remove();
            }
        });
        bind_date_field();
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
            //binding radio button action
            binding_radio_button("#filter-content " + selector + " input[type=radio]");
            radio_button_behaviour("#filter-content " + selector + " input[type=radio]");
            if (value.operator !== 'open') {
                jQuery("#td-" + key).show();
            }
            jQuery("#td-" + key).find("input").val(value.value);
            if (_.isArray(value.value)) {
                _.each(value.value, function (v) {
                    jQuery("#td-" + key).find("select").find("option[value='" + v + "']").attr("selected", "selected");
                });
            }
        });
        $(document).ready(function () {
                jQuery(".content").hide();
            }
        );
    } else {
        jQuery("#filters-list").chosen();
        jQuery("#filters_list_chosen").hide();
        jQuery("#filter-content").hide();
        jQuery(".content").hide();
    }
}
function initialize_filters(options) {
    if (gon) {
        //Display or hide filter's conditions
        add_filters(gon.DOM_filter);
        load_filter(gon.DOM_filter, (options && options.dom_persisted_filter) ? options.dom_persisted_filter : gon.DOM_persisted_filter);
    }
    $("#type-filter").click(function (e) {
        $("#filters_list_chosen").show();
        $("#filter-content").show();
    });
    $("#type-all").click(function (e) {
        $("#filters_list_chosen").hide();
        $("#filter-content").hide();
    });

}

function save_edit_filter(link_id, form_id) {
    jQuery(link_id).click(function (e) {
        e.preventDefault();
        var self_element = jQuery(this);
        json = jQuery(form_id).serializeJSON();
        apprise(self_element.data('confirm-message'), {confirm: true}, function (response) {
            if (response) {
                jQuery.ajax({
                    url: self_element[0].href,
                    type: 'put',
                    dataType: 'script',
                    data: json
                });
            }
        });


    });
}