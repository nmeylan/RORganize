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
        checkAllBox("#check_all_" + id, jQuery(this));
    });
    $('.check_all').each(function () {
        var id = jQuery(this).attr('id');
        var classes = id.split('_');
        checkAllBox("#" + id, jQuery("td.body." + classes.join('.')));
    });
    bind_tab_nav('permissions_tab');
    $('table.permissions_list').each(function () {
        if ($(this).find('.permissions_list.body.no_category').children().length == 0) {
            console.log($(this).find('td.no_category'));
            $(this).find('td.no_category').hide();
        }
    });
}
