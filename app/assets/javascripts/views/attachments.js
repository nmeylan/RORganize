/**
 * User: Nicolas
 * Date: 30/11/13
 * Time: 09:06
 */

function on_load_attachments_scripts() {
    jQuery(".add_attachment_link").click(function (e){
        e.preventDefault();
        var self_element = jQuery(this);
        var content = self_element.data("content");
        var id = self_element.data("id");
        self_element.parent().parent().append(content);
    });
}
