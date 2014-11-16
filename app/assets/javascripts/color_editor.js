/**
 * User: nmeylan
 * Date: 16.11.14
 * Time: 15:46
 */


function bind_color_editor() {
    var editor_fields = $(".color-editor-field");
    var editor_field;
    editor_fields.each(function () {
        editor_field = $(this);
        var color_bg = $("<span class='color-editor-bg'></span>");
        var container = $("<div class='color-editor dropdown'></div>");

        color_editor_wrap_elements(editor_field, color_bg, container);
        color_editor_key_event(editor_field, color_bg);
    });
}

function color_editor_wrap_elements(editor_field, color_bg, container) {
    editor_field.wrap(container);
    editor_field.attr('data-toggle', 'dropdown');
    editor_field.dropdown();
    color_bg.insertBefore(editor_field);
    var dropdown = dropdown_color_editor(color_bg, editor_field);
    dropdown.insertAfter(editor_field);
    set_editor_colors(editor_field, color_bg);
}

function color_editor_key_event(editor_field, color_bg) {
    editor_field.keypress(function (e) {
        var val = editor_field.val();
        if (val.indexOf('#') !== 0)
            editor_field.val('#' + val);
        set_editor_colors(editor_field, color_bg);
    });
}

function set_editor_colors(editor_field, color_bg) {
    color_bg.css('background-color', '#' + editor_field.val());
    editor_field.css('color', '#' + editor_field.val());
}

function dropdown_color_editor(color_bg, editor_field) {
    var dropdown = $("<div class='dropdown-menu-content colors dropdown-menu '></div>");
    var rows = [];
    rows.push(['e11d21', 'eb6420', 'fbca04', '009800', '006b75', '207de5', '0052cc', '5319e7']);
    rows.push(['f7c6c7', 'fad8c7', 'fef2c0', 'bfe5bf', 'bfdadc', 'c7def8', 'bfd4f2', 'd4c5f9']);
    for(var i= 0; i < rows.length; i++){
        dropdown_color_editor_row(rows[i], dropdown,color_bg, editor_field);
    }
    return dropdown;
}

function dropdown_color_editor_row(colors, dropdown, color_bg, editor_field) {
    var row = $("<ul class='color-chooser'></ul>");
    dropdown.append(row);
    var color;
    var color_element;
    for (var i = 0; i < colors.length; i++) {
        color = colors[i];
        color_element = $("<li data-hex-value='" + color + "' ><span class='color-chooser-color' style='background-color:#" + color + "'></span></li>");
        row.append(color_element);
        dropdown_color_editor_click_event(color_element, editor_field, color_bg);
    }
}

function dropdown_color_editor_click_event(color_element, editor_field, color_bg) {
    color_element.click(function (e) {
        var value = $(this).attr('data-hex-value');
        editor_field.val('#' + value);
        set_editor_colors(editor_field, color_bg);
    });
}