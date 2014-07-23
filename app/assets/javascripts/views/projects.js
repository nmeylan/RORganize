/**
 * User: Nicolas
 * Date: 14/12/13
 * Time: 13:48
 */
function on_load_projects_scripts() {
    if (gon.action === 'index')
        project_selection_filter();
    else if (gon.action === 'activity')
        project_activities();
}

function project_activities() {
    jQuery('a.toggle').click(function (e) {
        e.preventDefault();
        jQuery(this).next('.journal_details.more').slideToggle();
    });

    jQuery('.date_circle').click(function (e) {
        e.preventDefault();
        var el = jQuery(this);
        var next = el.next('.journals');
        if (next.is(':visible')) {
            el.addClass('collasped_circle');
            next.fadeOut();
        } else {
            el.removeClass('collasped_circle');
            next.fadeIn();
        }
    });
    jQuery('.date_circle').hover(function(e){
        var el = jQuery(this);
        el.next('.journals').addClass('hover');
    }, function(e){
        var el = jQuery(this);
        el.next('.journals').removeClass('hover');
    });
}