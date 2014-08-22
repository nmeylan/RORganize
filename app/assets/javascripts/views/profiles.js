/**
 * User: Nicolas
 * Date: 14/12/13
 * Time: 17:08
 */
function on_load_profiles_scripts() {

    profiles_spent_time();
    profiles_project();
    if (gon.action === 'show') {
        bind_activities();
        on_activities_load();
    }
}

function profiles_spent_time(){
    bind_calendar_button();
    jQuery('.log_time').click(function (e) {
        e.preventDefault();
        fill_log_issue_time_overlay(jQuery(this).attr('href'),this);
        createOverlay("#spent_time_overlay", 150);
        jQuery('#spent_time_overlay').overlay().load();

    });
}

function profiles_project(){
    jQuery(".sortable").sortable();
    bind_save_project_position();
    bind_star_project();
}

function on_activities_load(){
    createOverlay("#comments_overlay", 150);
}