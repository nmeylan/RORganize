/**
 * User: Nicolas
 * Date: 30/11/13
 * Time: 07:58
 */
function on_load_documents_scripts(options) {
    switch (gon.action) {
        case 'index' :
            rich_list_index_callback('document', options);
            break;
        case 'show' :
            documents_show();
            break;
        case 'new' :
            on_load_attachments_scripts();
            break;
        case 'edit' :
            on_load_attachments_scripts();
            break;
        case 'create' :
            on_load_attachments_scripts();
            break;
        case 'update' :
            on_load_attachments_scripts();
            break;
        case 'apply_custom_query' :
            rich_list_index_callback('document', options);
            break;
    }
}

function documents_index(options) {

    rich_list_index_binder('document', options);
}

function documents_show() {
    jQuery('a.lightbox').lightBox({
        fixedNavigation: true,
        imageLoading: "<%= asset_path 'lightbox-ico-loading.gif' %>",
        imageBtnClose: "<%= asset_path 'lightbox-btn-close.gif' %>",
        imageBtnPrev: "<%= asset_path 'lightbox-btn-prev.gif' %>",
        imageBtnNext: "<%= asset_path 'lightbox-btn-next.gif' %>",
        imageBlank: "<%= asset_path 'lightbox-blank.gif' %>",
        containerResizeSpeed: 350
    });
}