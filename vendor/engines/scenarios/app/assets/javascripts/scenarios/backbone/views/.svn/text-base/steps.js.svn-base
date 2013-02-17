/*
 * Author: Nicolas Meylan
 * Date: 28 déc. 2012
 * Encoding: UTF-8
 * File: steps.js
 */
/*
 * Steps requiere a scenario_id
 * Steps collection view is a <ul>
 * Contain some <div>
 * <div> are create in StepView
 */
(function($) {
   window.StepsView = Backbone.View.extend({
      el : $('#steps_form'),
      initialize : function() {
         this.model = new Steps;
         this.model.project_id = jQuery("#project_id").val();
         this.model.scenario_id = $("#scenario_id").val();
         if(this.model.scenario_id){
            this.model.setUrl("fetch");
            this.model.fetch({
               error:function(model){
                  $.jGrowl("Scenario must be created before.", {
                     theme: 'failure'
                  });
               }
            });
         }

         this.listenTo(this.model, 'add', this.addOne);
         this.listenTo(this.model, 'reset', this.addAll);
      // this.listenTo(this.model, 'all', this.render);
      },
      events : {
         "click .add_step" : "addOne"
      },
      render : function() {

      },
      addOne: function(e) {
         e.preventDefault();
         var stepView = new StepView({
            model : new Step({
               scenario_id : $("#scenario_id").val()
            })
         });

         $("#steps").append(stepView.render().el);
      },
      getStep: function(e){
         var stepView = new StepView({
            model : new Step({
               scenario_id : $("#scenario_id").val(),
               id : e.id,
               name: e.attributes.name
            })

         });
         $("#steps").append(stepView.render().el);
      },
      addAll: function() {
         this.model.each(this.getStep);
      }
   });
   var stepsView = new StepsView();

})(jQuery);
