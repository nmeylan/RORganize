/**
 * User: Nicolas
 * Date: 30/11/13
 * Time: 07:58
 */
function on_load_documents_scripts(options) {
    switch (gon.action) {
        case 'index' :
            documents_index(options);
            uniq_toogle("#document.toggle",".content");
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
    }
}

function documents_index(options){
    checkAll("#check_all", ".list");
    listTrClick(".list .document_tr");
    checkboxToolbox(".list");
    init_toolbox('.document.list .document_tr', 'documents_toolbox', {list: '.document.list'});
    initialize_filters(options);
}

function documents_show(){
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