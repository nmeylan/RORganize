/**
 * User: Nicolas
 * Date: 07/12/13
 * Time: 03:37
 */

function on_load_issues_scripts(options) {
    switch (gon.action) {
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
    }


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