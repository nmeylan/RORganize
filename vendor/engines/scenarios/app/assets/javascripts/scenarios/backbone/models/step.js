/*
 * Author: Nicolas Meylan
 * Date: 22 déc. 2012
 * Encoding: UTF-8
 * File: step.js
 */


window.Step = Backbone.Model.extend({
   project_id : '',
   mUrl : '',
   scenario_id : '',
   initialize : function Step() {
      this.bind("error", function(model, error){
         console.log(error);
      });
   },
   url :function(){
      return this.mUrl;
   },
   validate: function(attributes){
      if(attributes.name === ""){
         return "Name can't be blank.";
      }
      if(attributes.scenario_id === ""){
         return "Scenario must be created before.";
      }
   },
   setUrl : function(action){
      if(action === "fetch")
         this.mUrl = '/project/'+this.project_id+'/scenarios/'+this.attributes.scenario_id+'/steps/'+this.id+'/edit';
      else if(action === "add_issues")
         this.mUrl = '/project/'+this.project_id+'/scenarios/'+this.attributes.scenario_id+'/steps/'+this.id+'/add_issues';
      else if(action === "create_issue")
         this.mUrl = '/project/'+this.project_id+'/scenarios/'+this.attributes.scenario_id+'/steps/'+this.id+'/create_simple_issue';
      else if(action === "load_issues")
         this.mUrl = '/project/'+this.project_id+'/scenarios/'+this.attributes.scenario_id+'/steps/load_all_issues';
      else
         this.mUrl = (this.id ? '/project/'+this.project_id+'/scenarios/'+this.attributes.scenario_id+'/steps/'+this.id :
            '/project/'+this.project_id+'/scenarios/'+this.attributes.scenario_id+'/steps/');
   }
});

window.Steps = Backbone.Collection.extend({
   model : Step,
   project_id : '',
   mUrl : '',
   scenario_id : '',
   initialize : function() {
   },
   url :function(){
      return this.mUrl;
   },
   validate: function(attributes){
      if(attributes.name === ""){
         return "Name can't be blank.";
      }
      if(this.scenario_id === ""){
         return "Scenario must be created before.";
      }
   },
   setUrl : function(action){
      if(action === "fetch")
         this.mUrl = '/project/'+this.project_id+'/scenarios/'+this.scenario_id+'/steps/';
      else
         this.mUrl = (this.id ? '/project/'+this.project_id+'/scenarios/'+this.attributes.scenario_id+'/steps/'+this.id :
            '/project/'+this.project_id+'/scenarios/'+this.attributes.scenario_id+'/steps/');
   }
});