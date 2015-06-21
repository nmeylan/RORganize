/**
 * User: Nicolas
 * Date: 14/12/13
 * Time: 10:32
 */

function members_index() {
    ajax_trigger(".member.list select", 'change', 'POST');
}
