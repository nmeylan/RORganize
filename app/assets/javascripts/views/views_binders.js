/**
 * User: nmeylan
 * Date: 18.10.14
 * Time: 08:15
 */
function rich_list_index_binder(class_name, options){
    //Paginate
    //Checkboxes
    checkAll("#check-all", ".list");
    listTrClick(".list ."+class_name+"-tr");
    //Toolbox
    checkboxToolbox(".list");
    init_toolbox('.'+class_name+'.list .'+class_name+'-tr', class_name+'s-toolbox', {list: '.'+class_name+'.list'});
    //Filters

    initialize_filters(options);

    save_edit_filter("#filter-edit-save", "#filter-form");
}