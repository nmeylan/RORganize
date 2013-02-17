/*
 * Author: Nicolas Meylan
 * Date: 22 déc. 2012
 * Encoding: UTF-8
 * File: step.js
 */
/*
 * StepView is a div
 * Step requiere scenario_id
 * Step contain a IssuesView
 *
 */
(function($) {
   $.fn.serializeObject = function() {
      var values = {}
      $("form input, form select, form textarea").each( function(){
         values[this.name] = $(this).val();
      });

      return values;
   };

   window.StepView = Backbone.View.extend({
      tagName : "div",
      initialize : function() {
         _.templateSettings = {
            interpolate: /\[\%\=(.+?)\%\]/g,
            evaluate: /\[\%(.+?)\%\]/g
         };
         this.template = _.template($('#step-template').html(), "", _.templateSettings);
         this.model.project_id = jQuery("#project_id").val();
         if(this.model.id){ //if model already exist, fetch to get data from server
            this.model.setUrl("fetch");
            this.model.fetch();
         }
         this.listenTo(this.model, 'change', this.render);
         this.listenTo(this.model, 'destroy', this.remove);

      },
      events : {
         "keydown .steps_textfield" : "createStep", //when focus is lost in the the textfield, save step.
         "click .remove_step" : "destroyStep",   //when destroy link is clicked, destroy step.
         "click .open_add_overlay" : "openAddIssueOverlay",   //when add issue link is clicked, open add overlay.
         "click .open_create_overlay" : "openCreateIssueOverlay",   //when add issue link is clicked, open create overlay.
         "click .save_issues" : "linkWithIssues",
         "click .save_new_issue" : "createIssue"

      },
      //Construct params hash, for rails controller
      newAttributes: function(event) {
         return {
            step: {
               name: $(event.currentTarget).val(),
               scenario_id: $("#scenario_id").val()
            }
         }
      },
      render : function(options) {
         var renderedContent = this.template({
            step : this.model.toJSON(),
            options : options
         });
         this.$el.html(renderedContent);
         this.issuesView = new IssuesView({
            el:this.$('.step_issues')
         });
         //add_issues_overlay init
         createOverlay("#step_issue_overlay_"+this.model.id, 150);
         createOverlay("#create_issue_overlay_"+this.model.id, 150);
         //overlay settings
         checkAll("#step_issue_overlay_"+this.model.id+" #check_all", ".list");
         listTrClick("#step_issue_overlay_"+this.model.id+" .list");
         checkboxToolbox("#step_issue_overlay_"+this.model.id+" .list");
         //Create issues list for step
         this.$el.find(this.issuesView.el).html(this.issuesView.render());
         return this;
      },
      destroyStep : function(){
         //restore the default url
         this.model.setUrl("default");
         this.model.destroy({
            success : function(model, xhr, options){
               $.jGrowl("Step : "+xhr.name+" was successfully deleted.", {
                  theme: 'success'
               });
            },
            error : function(model, xhr, options){
               $.jGrowl("Step deletion failed.", {
                  theme: 'failure'
               });
            }
         });

      },
      createStep : function(e) {
         if((e.type == "keydown" && e.keyCode == 13)){
            e.preventDefault();
            this.model.attributes.scenario_id = $("#scenario_id").val();
            //restore the default url
            this.model.setUrl("default");
            //set new params
            var params = this.newAttributes(e);
            if(this.model.attributes.scenario_id != ""){// save if scenario exist
               //Send a POST or PUT request to the server.
               this.model.save(params, {
                  success : function(model, xhr, options){
                     $.jGrowl("Step : "+xhr.name+" was successfully saved.", {
                        theme: 'success'
                     });
                  },
                  error : function(model, xhr, options){
                     $.jGrowl( $.parseJSON(xhr.responseText), {
                        theme: 'failure'
                     });
                  }
               });
            }else{
               $.jGrowl("Scenario must be created before.", {
                  theme: 'failure'
               });
            }
         }
      },
      openAddIssueOverlay : function(e){
         e.preventDefault();
         var self = this;
         //before load, check selected issues
         $("#step_issue_overlay_"+this.model.id).overlay().onBeforeLoad(function(){
            $("#step_issue_overlay_"+self.model.id).find(".list .toolbox_selection :checkbox").attr("checked",false);
            $("#step_issue_overlay_"+self.model.id).find(".list .toolbox_selection").removeClass("toolbox_selection");
            $("#"+self.model.id+" li a").each(function(index){
               var id = $(this).attr("class");
               $("#step_issue_overlay_"+self.model.id).find(".list tr td a#"+id+"")
               .parents("tr")
               .addClass("toolbox_selection")
               .find(":checkbox")
               .attr("checked",true);
            });
         });

         $("#save_issues").addClass(this.model.id+"");
         $(this.el).find("#step_issue_overlay_"+this.model.id).overlay().load();
      },
      openCreateIssueOverlay : function(e){
         e.preventDefault();
         $("#create_issue_overlay_"+this.model.id).overlay().load();
         $(".chzn-select-deselect").chosen({allow_single_deselect:true});
      },
      linkWithIssues: function(e){
         this.model.setUrl("add_issues");
         var issue_ids = [];
         _.each($(this.el).find("#step_issue_overlay_"+this.model.id).find(':checkbox:checked'), function(e){
            issue_ids.push($(e).val());
         });
         $.ajax({
            url:this.model.mUrl,
            type: "POST",
            dataType: "JSON",
            data : {
               issue_ids :issue_ids
            },
            success:function(){
               $.jGrowl("Issues successfully added.", {
                  theme: 'success'
               });
            }
         });

         this.issuesView.model.setUrl("fetch");
         this.issuesView.model.fetch();
      },
      createIssue: function(e){
         e.preventDefault();
         this.model.setUrl("create_issue");
         var self = this;
         $.ajax({
            url:this.model.mUrl,
            type: "POST",
            dataType: "JSON",
            data : $("#create_issue_form_"+self.model.id).serialize(),
            success:function(model, xhr, options){
               $.jGrowl("Issue successfully created.", {
                  theme: 'success'
               });
               //               self.issuesView.addOne(new Issue(model));
               $("#create_issue_overlay_"+self.model.id).overlay().close();
               self.model.setUrl("load_issues");
               $.ajax({
                  url:self.model.mUrl,
                  type: "GET",
                  dataType: "JSON",
                  success :function(model, xhr, options){
                     self.render(model);
                  }
               });

            },
            error:function(model, xhr, options){
               $.jGrowl( $.parseJSON(model.responseText), {
                  theme: 'failure'
               });
            }
         });
      }

   });


})(jQuery);
