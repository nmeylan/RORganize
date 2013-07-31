# Author: Nicolas Meylan
# Date: 24 déc. 2012
# Encoding: UTF-8
# File: steps_controller.rb

class StepsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_project, :find_scenario
  include ApplicationHelper

  def index
    respond_to do |format|
      format.html { render :action => "edit", :controller => "scenario", :id => @scenario.id}
      format.json  { render :json => @scenario.steps, :status => :ok, :responseText => t(:successful_created)}
    end
  end

  def create
    @step = Step.new(params[:step])
    scenario = Scenario.find(@step.scenario_id)
    respond_to do |format|
      if @step.save && scenario.update_attribute("updated_at", Time.now)
        format.html { redirect_to(@step, :notice => t(:successful_created)) }
        format.json  { render :json => @step, :status => :created, :responseText => t(:successful_created)}
      else
        format.html { render :action => "new" }
        format.json  { render :json => @step.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @step = Step.find(params[:id])
    respond_to do |format|
      format.html
      format.json  { render :json => @step, :status => :ok, :responseText => t(:successful_created)}
    end
  end

  def update
    @step = Step.find(params[:id])
    scenario = Scenario.find(@step.scenario_id)
    respond_to do |format|
      if @step.update_attributes(params[:step]) && scenario.update_attribute("updated_at", Time.now)
        format.html { redirect_to(@step, :notice => t(:successfull_update)) }
        format.json  { render :json => @step, :status => :ok, :xhr => "success" }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @step.errors.full_messages , :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @step = Step.find(params[:id])
    @step.destroy
    respond_to do |format|
      format.html { redirect_to(@step, :notice => t(:successfull_update)) }
      format.json  { render :json => @step, :status => :ok, :xhr => "success" }
    end
  end

  #Others method
  def add_issues
    @step = Step.find(params[:id])
    ids = params[:issue_ids]
    @issues = Issue.find_all_by_id(ids)
    @step.issues.clear
    @issues.each do |issue|
      @step.issues << issue
    end
    scenario = Scenario.find(@step.scenario_id)
    scenario.update_attribute("updated_at", Time.now)
    @step.save
    respond_to do |format|
      format.json { render :json => @step.issues, :status => :ok, :xhr => "success" }
    end
  end

  def load_issues
    @step = Step.find(params[:id])
    respond_to do |format|
      format.json { render :json => @step.issues, :status => :ok, :xhr => "success" }
    end
  end

  def create_simple_issue
    @issue = Issue.new(params[:issue])
    @step = Step.find(params[:id])
    @issue.tracker_id = Tracker.find_by_name("Task").id
    @issue.status_id = IssuesStatus.find_by_enumeration_id(Enumeration.find_by_name_and_opt("New", "ISTS")).id
    @issue.project_id = @project.id
    @issue.done = 0
    @issue.author_id = current_user.id
    @step.issues << @issue
    scenario = Scenario.find(@step.scenario_id)
    scenario.update_attribute("updated_at", Time.now)
    respond_to do |format|
      if @issue.save
        @journal = Journal.create(:user_id => @issue.author_id,
          :journalized_id => @issue.id,
          :journalized_type => @issue.class.to_s,
          :created_at => @issue.created_at,
          :notes => "",
          :action_type => "created",
          :project_id => @project.id)
        format.json { render :json => @issue, :status => :ok, :xhr => "success" }
      else
        format.json { render :json => @issue.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  def load_all_issues
    @issues = Issue.find_all_by_project_id(@project.id, :order => "id DESC")
    respond_to do |format|
      format.json { render :json => @issues, :status => :ok, :xhr => "success" }
    end
  end
  #Private methods
  private
#  def find_project
#    @project = Project.find_by_identifier(params[:project_id])
#    render_404 if @project.nil?
#  end

  def find_scenario
    @scenario = Scenario.find(params[:scenario_id])
    render_404 if @scenario.nil?
  end
end