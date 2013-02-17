/*
 * Author: Nicolas Meylan
 * Date: 29 déc. 2012
 * Encoding: UTF-8
 * File: issues.js
 */
/*
 * Issues requiere a step_id
 * Issues collection view is a <ul>
 * Contain some <li>
 * <li> are create in IssueView
 *
 */
(function($) {
   window.IssuesView = Backbone.View.extend({
      initialize : function() {
         this.model = new Issues;
         this.model.project_id = jQuery("#project_id").val();
         this.model.scenario_id = $("#scenario_id").val();
         this.model.step_id = $(this.el).attr("id");
         if(this.model.step_id != "undefined"){
            this.model.setUrl("fetch");
            this.model.fetch({
               error:function(model){
                  $.jGrowl("Step must be created before.", {
                     theme: 'failure'
                  });
               }
            });
         }
         _.bindAll(this);

         this.listenTo(this.model, 'add', this.addOne);
         this.listenTo(this.model, 'reset', this.addAll);
      },
      events : {

      },
      addOne: function(e) {
         var issueView = new IssueView({
            model : new Issue({
               id : e.id,
               step_id : $(this.el).attr("id"),
               subject: e.attributes.subject
            })

         });
         $(this.el).append(issueView.render().el);
      },
      addAll: function() {
         this.$el.html("");
         this.model.each(this.addOne);
      }
   });

})(jQuery);

