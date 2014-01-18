/**
 * User: Nicolas
 * Date: 14/12/13
 * Time: 13:24
 */
function  on_load_permissions_scripts(){
    permissions_index();
}
function permissions_index(){
    multi_toogle(".toggle");
    jQuery(".content").each(function(){
        var id = jQuery(this).attr("class").split(' ')[1];
        checkAllBox("#check_all_"+id, jQuery(this));
    });
}
