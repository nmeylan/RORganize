/**
 * User: Nicolas
 * Date: 07/12/13
 * Time: 03:37
 */

function on_load_issues_scripts(options) {
    switch (gon.action) {
        case 'index' :
            issues_index(options);
            uniq_toogle("#issue.toggle", ".content");
            break;
        case 'show' :
            issues_show();
            break;
        case 'new' :
            issues_form();
            break;
        case 'edit' :
            issues_form();
            break;
        case 'create' :
            issues_form();
            break;
        case 'update' :
            issues_form();
            break;
        case 'apply_custom_query' :
            issues_index(options);
            uniq_toogle("#issue.toggle", ".content");
            break;
    }


}

function issues_index(options) {
    //Paginate
    per_page();
    //Checkboxes
    checkAll("#check_all", ".list");
    listTrClick(".list .issue_tr");
    //Toolbox
    checkboxToolbox(".list");
    init_toolbox('.issue.list .issue_tr', 'issues_toolbox', {list: '.issue.list'});
    //Filters

    initialize_filters(options);

    save_edit_filter("#filter_edit_save","#filter_form");


}

function issues_show() {
    multi_toogle("#gantt_informations");
    jQuery(".content.gantt_informations").hide();
    jQuery('a.lightbox').lightBox({
        fixedNavigation: true,
        imageLoading: "<%= asset_path 'lightbox-ico-loading.gif' %>",
        imageBtnClose: "<%= asset_path 'lightbox-btn-close.gif' %>",
        imageBtnPrev: "<%= asset_path 'lightbox-btn-prev.gif' %>",
        imageBtnNext: "<%= asset_path 'lightbox-btn-next.gif' %>",
        imageBlank: "<%= asset_path 'lightbox-blank.gif' %>",
        containerResizeSpeed: 350
    });
    jQuery('#update_issue').hide();
    createOverlay("#checklist_overlay", 150);
    createOverlay("#spent_time_overlay", 150);
    jQuery(".open_checklist_overlay").click(function (e) {
        e.preventDefault();
        jQuery("#checklist_overlay").overlay().load();
    });
    jQuery("#update_issue_link").click(function () {
        jQuery('#update_issue').show();
    });

    edit_notes();
    jQuery('#log_time').click(function (e) {
        e.preventDefault();
        fill_log_issue_time_overlay(jQuery(this).attr('href'), this);
        jQuery('#spent_time_overlay').overlay().load();
    });
    checklist_behaviour(gon.checklist_statuses);

}

function issues_form() {
    jQuery("#issue_version_id").change(function (e) {
        e.preventDefault();
        var self = this;
        var date = jQuery('#issue_version_id option:selected').attr("id");
        if (date != "")
            jQuery('#calendar').val(date)
    });
    on_load_attachments_scripts();
}