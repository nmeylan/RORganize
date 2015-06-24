// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//= require jquery
//= require jquery_ujs
//= require jquery-ui-1.10.4.custom.min.js
//= require underscore-min.js
//= require chosen-jquery
//= require jquery.jeegoocontext.min.js
//= require mousetrap.min
//= require textcomplete.min
//= require jquery.jgrowl
//= require bootstrap
//= require peek
//= require peek/views/rblineprof
//= require peek/views/performance_bar

//= require_tree ./libs
//= require_tree ./patch
//= require_tree .

$(function () {
    App.setup(document, 'front');
});

$(document).ajaxSend(function(e, xhr, options) {
  $("#loading").show();
});

$(document).ajaxComplete(function(e, xhr, options) {

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