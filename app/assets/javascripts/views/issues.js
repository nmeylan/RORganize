/**
 * User: Nicolas
 * Date: 07/12/13
 * Time: 03:37
 */

function on_load_issues_scripts(options) {
    switch (gon.action) {
        case 'index' :
            rich_list_index_callback('issue', options);
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
            rich_list_index_callback('issue', options);
            break;
    }


}

function issues_index(options) {
    rich_list_index_binder('issue', options);


}

function issues_show() {
    multi_toogle("#gantt-informations");
    jQuery(".content.gantt-informations").hide();
    jQuery('a.lightbox').lightBox({
        fixedNavigation: true,
        imageLoading: "<%= asset_path 'lightbox-ico-loading.gif' %>",
        imageBtnClose: "<%= asset_path 'lightbox-btn-close.gif' %>",
        imageBtnPrev: "<%= asset_path 'lightbox-btn-prev.gif' %>",
        imageBtnNext: "<%= asset_path 'lightbox-btn-next.gif' %>",
        imageBlank: "<%= asset_path 'lightbox-blank.gif' %>",
        containerResizeSpeed: 350
    });
    jQuery('#update-issue').hide();
    jQuery('#update-issue h2').click(function (e) {
        e.preventDefault();
        jQuery('#update-issue').fadeOut();
    });
    createOverlay("#spent-time-overlay", 150);

    jQuery("#update-issue-link").click(function () {
        jQuery('#update-issue').show();
    });
    jQuery('#log-time').click(function (e) {
        e.preventDefault();
        fill_log_issue_time_overlay(jQuery(this).attr('href'), this);
        jQuery('#spent-time-overlay').overlay().load();
    });

}

function issues_form() {
    var select = jQuery("#issue_version_id");
    update_version_info(select);
    select.change(function (e) {
        e.preventDefault();
        var self = this;
        var phase = update_version_info(select);
        var date = phase.data("target_date");
        if (date != "")
            jQuery('#calendar').val(date);
    });
    on_load_attachments_scripts();
}

function update_version_info(select) {
    var phase = select.find('option:selected');
    var info = $('#version-info');
    var title = phase.data('version_info');
    info.attr('title', title);
    var help = info.find('.help');
    if (title === undefined) {
        help.hide();
    } else {
        var isHelpVisible = help.length > 0 && help.css('display') !== 'none';
        info.remove('.help').html(write_info(title));
        if (!isHelpVisible) {
            info.find('.help').hide();
        }
    }
    return phase;
}