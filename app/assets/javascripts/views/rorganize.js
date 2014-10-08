/**
 * User: nmeylan
 * Date: 22.08.14
 * Time: 22:46
 */
function on_load_rorganize_scripts() {

    if (gon.action === 'view_profile') {
        bind_activities();
        on_activities_load();
    }
}

function on_activities_load() {
    createOverlay("#comments-overlay", 150);
}