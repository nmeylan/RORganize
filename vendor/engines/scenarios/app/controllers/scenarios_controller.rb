# Author: Nicolas Meylan
# Date: 7 déc. 2012
# Encoding: UTF-8
# File: scenarios_controller.rb

class ScenariosController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_project
  before_filter :check_permission, :except => [:create, :update]
  include ApplicationHelper
  helper_method :sort_column, :sort_direction
  require 'will_paginate'
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }

  def index
    @scenarios = Scenario.find_all_by_project_id(@project.id)
    params[:per_page] ? session['controller_scenarios_per_page'] = params[:per_page] : session['controller_scenarios_per_page'] = (session['controller_scenarios_per_page'] ? session['controller_scenarios_per_page'] : 25)
    @scenarios = Scenario.paginated_scenarios(params[:page], session['controller_scenarios_per_page'],
                                     sort_column + " " + sort_direction, "",@project.id)
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.replace "scenarios_content", :partial => 'scenarios/list'
        end
      end
    end
  end

  def new
    @scenario = Scenario.new
    @scenario.steps = [Step.new]
    @scenario.attachments.build
    @actors = Enumeration.find_all_by_opt('SCAC')
    @issues = Issue.find_all_by_project_id(@project.id);
    @users = @project.members.collect{|member| member.user}
    respond_to do |format|
      format.html
    end
  end

  def create
    params[:scenario][:project_id] = @project.id
    @scenario = Scenario.new(params[:scenario])
    respond_to do |format|
      if @scenario.save
        format.html { redirect_to(@scenario, :notice => t(:successful_created)) }
        format.json  { render :json => @scenario, :status => :created, :responseText => t(:successful_created)}
      else
        format.html { render :action => "new" }
        format.json  { render :json => @scenario.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @scenario = Scenario.find(params[:id], :include => [:steps])
    @actors = Enumeration.find_all_by_opt('SCAC')
    @issues = Issue.find_all_by_project_id(@project.id);
    @users = @project.members.collect{|member| member.user}
    respond_to do |format|
      format.html
      format.json  { render :json => @scenario, :status => :ok, :responseText => t(:successful_created)}
    end
  end
  def show
    @scenario = Scenario.find(params[:id], :include => [:version,:actor,:steps])
  end
  def update
    @scenario = Scenario.find(params[:id])

    respond_to do |format|
      if @scenario.update_attributes(params[:scenario])
        format.html { redirect_to(@scenario, :notice => t(:successfull_update)) }
        format.json  { render :json => @scenario, :status => :ok, :xhr => "success" }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @scenario.errors.full_messages , :status => :unprocessable_entity }
      end
    end
  end

  #Private methods
  private
  def find_project
    @project = Project.find_by_identifier(params[:project_id])
    render_404 if @project.nil?
  end

  def sort_column
    params[:sort] ? session['controller_scenarios_sort'] = params[:sort] : session['controller_scenarios_sort'] = (session['controller_scenarios_sort'] ? session['controller_scenarios_sort'] : 'id')
    session['controller_scenarios_sort']
  end

  def sort_direction
    params[:direction] ? session['controller_scenarios_direction'] = params[:direction] : session['controller_scenarios_direction'] = (session['controller_scenarios_direction'] ? session['controller_scenarios_direction'] : 'desc')
    session['controller_scenarios_direction']
  end
end
