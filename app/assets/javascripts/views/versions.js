/**
 * User: Nicolas
 * Date: 15/12/13
 * Time: 03:10
 */
function on_load_versions_scripts(){
    switch(gon.action){
        case 'index' :
            versions_index();
            break;
        case 'new' :
            versions_form();
            break;
        case 'edit' :
            versions_form();
            break;
        case 'create' :
            versions_form();
            break;
        case 'update' :
            versions_form();
            break;
    }

}

function versions_index(){
    bind_version_change_positions();
}

function versions_form(){
    console.log("aaa");
    jQuery('#calendar_start').datepicker({dateFormat: 'dd/mm/yy'});
    jQuery('#calendar').datepicker({dateFormat: 'dd/mm/yy'});
}