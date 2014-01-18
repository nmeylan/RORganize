# Author: Nicolas Meylan
# Date: 23 oct. 2012
# Encoding: UTF-8
# File: roles_controller.rb

class RolesController < ApplicationController
  before_filter :check_permission
  before_filter { |c| c.menu_context :admin_menu }
  before_filter { |c| c.menu_item(params[:controller])}
  before_filter {|c| c.top_menu_item('administration')}
  include ApplicationHelper

  #Get /administration/roles
  def index
    @roles = Role.find(:all)
    respond_to do |format|
      format.html
    end
  end

  #GET /administration/roles/new
  def new
    @role = Role.new
    @old_issues_statuses = IssuesStatus.select('*').includes(:enumeration)
    respond_to do |format|
      format.html
    end
  end

  #POST /administration/roles/new
  def create
    @role = Role.new(params[:role])
    if(params[:old_issues_statuses])
      issues_statuses = IssuesStatus.select('*').where(:id => params[:old_issues_statuses].values)
      issues_statuses.each{|status|@role.old_issues_statuses << status}
    end
    respond_to do |format|
      if @role.save
        flash[:notice] = t(:successful_creation)
        format.html {redirect_to :action => 'index'}
      else
        @old_issues_statuses = IssuesStatus.select('*').includes(:enumeration)
        format.html  { render :action => 'new' }
        format.json  { render :json => @role.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  #GET /administration/roles/edit/:id
  def edit
    @role = Role.find_by_id(params[:id])
    @old_issues_statuses = IssuesStatus.select('*').includes(:enumeration)
    respond_to do |format|
      format.html
    end
  end

  #PUT /administration/roles/edit/:id
  def update
    @role = Role.find_by_id(params[:id])
    issues_statuses = IssuesStatus.select('*').where(:id => params[:old_issues_statuses].values)
    @role.old_issues_statuses.clear
    issues_statuses.each{|status|@role.old_issues_statuses << status}
    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = t(:successful_update)
        format.html {redirect_to :action => 'index'}
      else
        @old_issues_statuses = IssuesStatus.select('*').includes(:enumeration)
        format.html {render :action => 'edit'}
      end
    end
  end

  #DELETE /administration/roles/:id
  def destroy
    @role = Role.find_by_id(params[:id])
    @role.destroy
    @roles = Role.find(:all)
    respond_to do |format|
      format.html {redirect_to :action => 'index'}
      format.js {respond_to_js :response_header => :success, :response_content => t(:successful_deletion), :locals => { :id => @role.id}}
    end
  end
end
