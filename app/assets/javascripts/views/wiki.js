/**
 * User: Nicolas
 * Date: 15/12/13
 * Time: 03:14
 */

function on_load_wiki_scripts() {
    if (gon.action === 'organize_pages')
        wiki_organize_pages();
}

function wiki_organize_pages() {
    jQuery("#wiki-pages").addClass('organize');
    bind_organization_behaviour(".connectedSortable");
    jQuery(".connectedSortable li.item").prepend("<a href='#' class='add-sub-item icon icon-add'><span class='octicon octicon-plus'></span></a> ");
    add_sub_item(".add-sub-item");
    bind_set_organization_button("#wiki-pages li.item", "#serialize");
}