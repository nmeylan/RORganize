/*
 * Author: Nicolas Meylan
 * Date: 22 déc. 2012
 * Encoding: UTF-8
 * File: scenarios.js
 */

window.Scenario = Backbone.Model.extend({
   project_id : '',
   mUrl : '', //Model url
   initialize : function Scenario() {
      this.steps = new Steps;
   },
   url :function(){
      return this.mUrl; //change project
   },
   validate: function(attributes){
      if(attributes.name === ""){
         return "Name can't be blank.";
      }
   },
   setUrl : function(fetch){ //fetch params is used when model is fetch.
      if(fetch)
         this.mUrl = document.URL;
      else
         this.mUrl = (this.id ? '/projects/'+this.project_id+'/scenarios/'+this.id : '/projects/'+this.project_id+'/scenarios/');
   }

});

window.Scenarios = Backbone.Collection.extend({
   model : Scenario,
   initialize : function() {
      console.log('Scenario collection Constructor');
   }
});
