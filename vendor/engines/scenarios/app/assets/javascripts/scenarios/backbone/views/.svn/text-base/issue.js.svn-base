/*
 * Author: Nicolas Meylan
 * Date: 22 déc. 2012
 * Encoding: UTF-8
 * File: issue.js
 */
/*
 * IssueView is a <li>
 * Requiere step_id
 *
 */
(function($) {
   window.IssueView = Backbone.View.extend({
      tagName : "li",
      initialize : function() {
         _.templateSettings = {
            interpolate: /\[\%\=(.+?)\%\]/g,
            evaluate: /\[\%(.+?)\%\]/g
         };
         this.template = _.template($('#issue-template').html(), "", _.templateSettings);
         this.model.project_id = jQuery("#project_id").val();
      
      },
      events : {
      },
      render : function() {
         var renderedContent = this.template({
            issue : this.model.toJSON()
         });
         this.$el.html(renderedContent);
         return this;
      }

   });


})(jQuery);
