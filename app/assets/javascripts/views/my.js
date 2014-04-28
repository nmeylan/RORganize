/**
 * User: Nicolas
 * Date: 14/12/13
 * Time: 17:08
 */
function on_load_my_scripts() {

    my_spent_time();

    my_project();
}

function my_spent_time(){
    bind_calendar_button();
    jQuery('.log_time').click(function (e) {
        e.preventDefault();
        fill_log_issue_time_overlay(jQuery(this).attr('href'),this);
        createOverlay("#spent_time_overlay", 150);
        jQuery('#spent_time_overlay').overlay().load();

    });
}

function my_project(){
    jQuery(".sortable").sortable();
    bind_save_project_position();
    bind_star_project();
}