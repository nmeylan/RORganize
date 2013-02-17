/*
 * Author: Nicolas Meylan
 * Date: 22 déc. 2012
 * Encoding: UTF-8
 * File: issue.js
 */



window.Issue = Backbone.Model.extend({
   project_id : '',
   mUrl : '',
   step_id : '',
   initialize : function Issue() {
      
   },

   validate: function(attributes){
      if(attributes.subject === ""){
         return "Subject can't be blank.";
      }
   },
   url :function(){
      return this.mUrl;
   },
   setUrl : function(action){
      if(action === "fetch")
         this.mUrl = '/project/'+this.project_id+'/scenarios/'+this.scenario_id+'/steps/'+this.step_id+'/load_issues';
      else
         this.mUrl = (this.id ? '/project/'+this.project_id+'/scenarios/'+this.scenario_id+'/steps/'+this.id :
            '/project/'+this.project_id+'/scenarios/'+this.scenario_id+'/steps/');
   }
});


window.Issues = Backbone.Collection.extend({
   model : Issue,
   project_id : '',
   mUrl : '',
   step_id : '',
   initialize : function() {
   },
   url :function(){
      return this.mUrl;
   },
   setUrl : function(action){
      if(action === "fetch")
         this.mUrl = '/project/'+this.project_id+'/scenarios/'+this.scenario_id+'/steps/'+this.step_id+'/load_issues';
      else
         this.mUrl = (this.id ? '/project/'+this.project_id+'/scenarios/'+this.scenario_id+'/steps/'+this.id :
            '/project/'+this.project_id+'/scenarios/'+this.scenario_id+'/steps/');
   }
});