# Author: Nicolas Meylan
# Date: 30 sept. 2012
# Encoding: UTF-8
# File: members_controller.rb

class MembersController < ApplicationController
  before_filter :find_project
  before_filter :check_permission, :except => [:create]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item('settings') }
  before_filter {|c| c.top_menu_item('projects')}
  include ApplicationHelper
  #GET /projects/
  def index
    @members = Member.where(:project_id => @project.id).includes(:role, :user)
    roles = Role.find(:all)
    users = User.find(:all)
    users =users.select{|user| !@members.collect{|member| member.user.id}.include?(user.id)}
    respond_to do |format|
      format.html{render :action => 'index', :locals => {:roles => roles, :users => users}}
    end
  end

  #DELETE /project/:project_identifier/setting/members/:id
  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    render_index_js(true,t(:successful_deletion))
  end

  def create
    success = Member.create(:project_id => @project.id, :role_id => params[:role], :user_id => params[:user])
    render_index_js(success, t(:successful_creation))
  end
  #Others method
  def change_role
    member = Member.find_by_id(params[:member_id])
    success = member.update_attribute(:role_id, params[:role_id])
    render_index_js(success)
  end

  #Private methods
  private

  def render_index_js(success = true, message = t(:successful_update))
    @members = Member.where(:project_id => @project.id).includes(:role, :user)
    roles = Role.find(:all)
    users = User.find(:all)
    users = users.select{|user| !@members.collect{|member| member.user.id}.include?(user.id)}
    respond_to do |format|
      format.js{
        render :update do |page|
          page.replace 'members_content', :partial => 'members/list', :locals => {:roles => roles, :users => users}
          success ? (response.headers['flash-message'] = message) : (response.headers['flash-error-message'] = t(:failure_operation))
        end}
    end
  end
end

