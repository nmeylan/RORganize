/**
 * User: Nicolas
 * Date: 14/12/13
 * Time: 13:48
 */
function on_load_projects_scripts() {
    if (gon.action === 'index')
        project_selection_filter();
    else if (gon.action === 'activity') {
        bind_activities();
        on_activities_load();
    }
}

function on_activities_load(){
    createOverlay("#comments_overlay", 150);
}
