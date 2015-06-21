/**
 * User: Nicolas
 * Date: 14/12/13
 * Time: 13:24
 */
function on_load_permissions_scripts() {
    permissions_index();
}
function permissions_index() {
    jQuery("tr.body").each(function () {
        var id = jQuery(this).attr("class").split(' ')[1];
        checkAllBox("#check-all-" + id, jQuery(this));
    });
    $('.check-all').each(function () {
        var id = jQuery(this).attr('id');
        var classes = id.split('-');
        checkAllBox("#" + id, jQuery("td.body." + classes.join('.')));
    });
    $('table.permissions-list').each(function () {
        if ($(this).find('.permissions-list.body.misc').children().length == 0) {
            $(this).find('td.misc').hide();
        }
    });
}
