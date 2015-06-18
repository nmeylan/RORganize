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
//= require rorganize
//= require_tree .

$(function () {
    App.setup(document, 'front');
});