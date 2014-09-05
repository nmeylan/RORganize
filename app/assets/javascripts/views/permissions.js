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
    $('.check_all').each(function(){
        var id = jQuery(this).attr('id');
        var classes = id.split('_');
        checkAllBox("#"+id, jQuery("td.body."+classes.join('.')));
    });
     bind_tab_nav('permissions_tab');
}
