/**
 * User: Nicolas
 * Date: 30/11/13
 * Time: 09:06
 */

function on_load_attachments_scripts() {
    bind_remove_attachment_field_link();
    jQuery(".add_attachment_link").click(function (e) {
        e.preventDefault();
        var self_element = jQuery(this);
        var content = self_element.data("content");
        var id = self_element.data("id");
        self_element.parent().parent().append(content);
        bind_remove_attachment_field_link();
    });
}

function bind_remove_attachment_field_link() {
    jQuery('.remove_attachment_field_link').click(function (e) {
        e.preventDefault();
        var el = jQuery(this);
        el.parents('.attachments').fadeOut('slow', function () {
            this.remove();
        })
    });
}