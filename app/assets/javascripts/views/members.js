/**
 * User: Nicolas
 * Date: 14/12/13
 * Time: 10:32
 */
function on_load_members_scripts() {
    members_index()
}

function members_index() {
    ajax_trigger(".member.list select", 'change', 'POST');
}
