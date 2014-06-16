/**
 * User: Nicolas
 * Date: 15/12/13
 * Time: 03:14
 */

function on_load_wiki_scripts(){
    bind_version_change_positions();
    wiki_organize_pages();
}

function wiki_organize_pages(){
    bind_organization_behaviour(".connectedSortable");
    jQuery(".connectedSortable li.item").prepend("<a href='#' class='add_sub_item icon icon-add'><span class='octicon octicon-plus'></span></a> ");
    add_sub_item(".add_sub_item");
    bind_set_organization_button("#organize_pages li.item", "#serialize");
}