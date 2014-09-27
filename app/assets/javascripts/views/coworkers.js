function on_load_coworkers_scripts() {
    listTrClick(".list .member_tr", true);
    checkboxToolbox(".list");
    bind_tr_ajax(".member_tr");
    bind_coworker_radio_filter(".radio_filter", ".list")
}

//Coworker
function bind_tr_ajax(selector) {
    jQuery(selector).click(function (e) {
        var getActivity = jQuery(this).hasClass("toolbox_selection");
        jQuery.ajax({
            url: jQuery(this).data("link"),
            type: "get",
            dataType: "script",
            data: {getAct: getActivity}
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