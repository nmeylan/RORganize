/**
 * User: nmeylan
 * Date: 24.07.14
 * Time: 10:18
 */
function bind_activities() {
    jQuery('a.toggle').click(function (e) {
        e.preventDefault();
        jQuery(this).next('.journal_details.more').slideToggle();
    });
    var circles = jQuery('.date_circle');
    var filters = jQuery('.filter_selection');
    circles.click(function (e) {
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
    circles.hover(function(e){
        var el = jQuery(this);
        el.next('.journals').addClass('hover');
    }, function(e){
        var el = jQuery(this);
        el.next('.journals').removeClass('hover');
    });
    filters.unbind();
    filters.change(function(e){
        var form = jQuery('form#activities_filter');
        form.submit();
    });
}