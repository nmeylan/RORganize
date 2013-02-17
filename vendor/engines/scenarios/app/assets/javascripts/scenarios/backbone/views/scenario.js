/*
 * Author: Nicolas Meylan
 * Date: 22 déc. 2012
 * Encoding: UTF-8
 * File: scenario.js
 */

(function($) {
   $.fn.serializeObject = function() {
      var values = {}
      $("form input, form select, form textarea").each( function(){
         values[this.name] = $(this).val();
      });

      return values;
   };
   $(document).ready(function(){
      window.ScenarioView = Backbone.View.extend({
         el : jQuery('#scenario'),
         initialize : function() {
            this.model.project_id = jQuery("#project_id").val();
            this.model.setUrl(true);
            this.model.fetch();
            this.template = _.template($('#scenario-template').html());
         },
         events : {
            "submit form#scenario" : 'createScenario'
         },
         newAttributes: function(event) {
            var new_scenario_form = $(event.currentTarget).serializeObject();
            return {
               scenario: {
                  name: new_scenario_form["scenario[name]"],
                  description: new_scenario_form ["scenario[description]"],
                  version_id: new_scenario_form ["scenario[version_id]"],
                  actor_id: new_scenario_form ["scenario[actor_id]"]
               }
            }
         },
         createScenario : function(e) {
            e.preventDefault();
            this.model.setUrl(false);
            var params = this.newAttributes(e);
            this.model.set(params);
            this.model.save(params, {
               success : function(model, xhr, options){
                  $("#scenario_id").val(model.attributes.id);

                  $.jGrowl(xhr.name+" was successfully saved.", {
                     theme: 'success'
                  });
               },
               error : function(model, xhr, options){
                  $.jGrowl( $.parseJSON(xhr.responseText), {
                     theme: 'failure'
                  });
               }
            });
         },
         error : function(model, error) {
            console.log(model, error);
            return this;
         },
         render : function() {
            var renderedContent = this.template(this.model.toJSON());
            $(this.el).html(renderedContent);
            return this;
         }
      });
      var scenarioView = new ScenarioView({
         el: $("#scenario"),
         model: new Scenario()
      });
   });


})(jQuery);