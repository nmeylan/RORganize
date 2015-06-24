//
(function($) {

  $(document).ready(function() {
    // hide flash messages
    display_flash();
    bind_hotkeys();


    //MarkItUp
    focus_first_input_text();

    //bind info tag
    bind_info_tag();
    bind_task_list_click();
    bind_color_editor();

    bind_table_list_actions();
    bind_date_field();
  });
  $(document).ajaxSend(function(e, xhr, options) {
    $("#loading").show();
  });

  $(document).ajaxComplete(function(e, xhr, options) {
    //BIND_CHZN-SELECT
    bind_table_list_actions();
    bind_task_list_click();
    bind_date_field();
    //MarkItUp

    $("#loading").hide();
    if (xhr.getResponseHeader('flash-message')) {
      $.jGrowl(xhr.getResponseHeader('flash-message'), {
        theme: 'success'
      });
    }
    if (xhr.getResponseHeader('flash-error-message')) {
      $.jGrowl(xhr.getResponseHeader('flash-error-message'), {
        theme: 'failure', sticky: true
      });
    }
    var first_char = xhr.status.toString().charAt(0);
    var is_error = first_char === '5';
    if (is_error) {
      var text = 'An unexpected error occured, please try again!';
      $.jGrowl(text, {
        theme: 'failure'
      });
    }
  });

  String.prototype.endsWith = function(suffix) {
    return this.indexOf(suffix, this.length - suffix.length) !== -1;
  };

  //JSON
  $.fn.serializeJSON = function() {
    var json = {};
    $.map($(this).serializeArray(), function(n, i) {
      if (n.name.endsWith('[]')) {
        if (json[n.name] === undefined)
          json[n.name] = [];
        json[n.name].push(n.value);
      }
      else
        json[n.name] = n.value;
    });
    return json;
  };

  $.fn.serializeObject = function() {
    var values = {};
    $("form input, form select, form textarea").each(function() {
      values[this.name] = $(this).val();
    });

    return values;
  };
  function clear_form_elements(ele) {

    $(ele).find(':input').each(function() {
      switch (this.type) {
        case 'password':
        case 'select-multiple':
        case 'select-one':
        case 'text':
        case 'textarea':
          $(this).val('');
          break;
        case 'checkbox':
        case 'radio':
          this.checked = false;
      }
    });
  }

  //Override $-rails confirm behaviour.
  //$.rails.allowAction = function (link) {
  //    var message = link.attr('data-confirm');
  //    if (!message) {
  //        return true;
  //    }
  //    apprise(message, {confirm: true}, function (response) {
  //        if (response) {
  //            link.removeAttr('data-confirm');
  //            link.trigger('click.rails');
  //        }
  //    });
  //    return false;
  //};

})($);

$.expr[':'].contains = function(a, i, m) {
  return $(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
};

function initialize_chosen() {

}
function display_flash() {
  var el;
  $(".flash").each(function() {
    el = $(this);
    if (el.text().trim() !== "") {
      el.css("display", "block");
      el.find(".close-flash").click(function(e) {
        $(this).parent().fadeOut();
      });
    } else {
      $(this).css("display", "none");
    }
  });
}
//Flash message
function error_explanation(message) {
  var el = $(".flash.alert");
  if (message !== null) {
    el.append(message).css("display", "block");
  }
}
function focus_first_input_text() {
  //$('.form input:visible[type=text]:not(.chzn-search-input)').first().focus();
}


function bind_table_list_actions() {
  var table_row = $('table.list tr');
  table_row.hover(function() {
    table_row.removeClass('hover');
    $(this).addClass('hover');
  }, function() {
    $(this).removeClass('hover');
  });
}

// CHECKBOX
function checkAllBox(selector, context) {
  $(selector).click(function(e) {
    e.preventDefault();
    var cases = $(context).find(':checkbox');
    var checked = $(this).attr("cb_checked") === 'b';
    cases.prop('checked', checked);
    $(this).attr("cb_checked", checked ? "a" : "b");
  });
}


//Toggle icon: fieldset
function multiToggle(element) {
  element.click(function(e) {
    var el = $(this);
    e.preventDefault();
    var id = el.attr("id");
    if (el.hasClass('icon-collapsed')) {
      el.switchClass('icon-collapsed', 'icon-expanded');
      el.find("> .octicon").switchClass('octicon-chevron-right', 'octicon-chevron-down');
    } else {
      el.switchClass('icon-expanded', 'icon-collapsed');
      el.find("> .octicon").switchClass('octicon-chevron-down', 'octicon-chevron-right');
    }
    $(".content." + id).slideToggle();
  });
}
//toggle content
function uniq_toogle(trigger_id, content) {
  $(trigger_id).click(function(e) {
    e.preventDefault();
    if ($(this).hasClass('icon-collapsed')) {
      $(this).switchClass('icon-collapsed', 'icon-expanded');
      $(trigger_id + "> .octicon").switchClass('octicon-chevron-right', 'octicon-chevron-down');
    } else {
      $(this).switchClass('icon-expanded', 'icon-collapsed');
      $(trigger_id + "> .octicon").switchClass('octicon-chevron-down', 'octicon-chevron-right');
    }
    $(content).slideToggle();
  });
}

//filters
function radio_button_behaviour(selector) {
  var ary = ["all", "open", "close", "today", "finished"]; //for option that don't use select box
  var id = "#td-" + $(selector).attr('class');
  if ($.inArray($(selector).val(), ary) === -1) {
    $(id).show();
    $(id).find(".chzn-select").chosen();
  } else {
    $(id).hide();
    $(id + " input").val();
  }
}
function binding_radio_button(selector) {
  $(selector).click(function(e) {
    radio_button_behaviour(this);
  });
}


function bind_calendar_button() {
  $(".change-month").click(function(e) {
    e.preventDefault();
    var self_element = $(this);
    var c = self_element.attr("id");
    $.ajax({
      url: self_element.attr("href"),
      dataType: "script",
      data: {date: c}
    });
  });
}


function bind_version_change_positions() {
  $(".change-position").click(function(e) {
    e.preventDefault();
    var self_element = $(this);
    var vid = self_element.parents("tr").attr("id");
    var ope = self_element.attr("class").split(" ");
    ope = ope[ope.length - 1];
    if (ope === "inc" || ope === "dec") {
      $.ajax({
        url: self_element.attr("href"),
        type: "post",
        dataType: "script",
        data: {
          id: vid,
          operator: ope
        }
      });
    }

  });
}

// UPDATE DOM with style !
function on_deletion_effect(element_id) {
  $(element_id).fadeOut(400, function() {
    $(this).remove();
  });
}

function on_append_effect(element_id, content) {
  $(element_id).append(content).fadeIn(500);
}

function on_replace_effect(element_id, content) {
  $(element_id).replaceWith(content).fadeIn(500);
}

function bind_info_tag() {
  $("span.octicon-info").click(function(e) {
    e.preventDefault();
    var el = $(this);
    if ((el.html() === "" || el.find('.help').css('display') === 'none') && el.attr('title') !== undefined) {
      var info = $(write_info(el.attr('title')));
      el.html(info);
      info.hide().fadeIn();
    }
    else {
      el.find('.help').fadeOut(function() {
        this.remove();
      });
    }
  });
}

function write_info(info) {
  return "<span class='help'>" + info + "</span>";
}

function bind_task_list_click() {
  var el = $('.task-list-item-checkbox');
  el.unbind('click');
  el.click(function(e) {
    var el = $(this);
    var context = $(this).parents('div.markdown-renderer');
    var split_ary = context.attr('id').split('-');
    var element_type = split_ary[0];
    var element_id = split_ary[1];
    var check_index = context.find('.task-list-item-checkbox').index(el);
    var is_check = el.is(':checked');

    $.ajax({
      url: '/rorganize/task_list_action_markdown',
      type: 'post',
      dataType: 'script',
      data: {
        is_check: is_check,
        element_type: element_type,
        element_id: element_id,
        check_index: check_index
      }
    });
  });
}

function bind_date_field() {
  var test_input = $('<input type="date" name="bday">');
  var input_date = $('[type="date"]');
  if (test_input.prop('type') != 'date') { //if browser doesn't support input type="date", load files for $ UI Date Picker
    if (input_date.hasClass('hasDatepicker')) {
      input_date.datepicker("destroy");
    }
    input_date.datepicker({dateFormat: 'dd/mm/yy'});
  }


}