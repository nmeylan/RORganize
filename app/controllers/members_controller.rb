# Author: Nicolas Meylan
# Date: 30 sept. 2012
# Encoding: UTF-8
# File: members_controller.rb

class MembersController < ApplicationController
  before_filter :find_project
  before_filter :check_permission, :except => [:create]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item("settings") }
  before_filter {|c| c.top_menu_item("projects")}
  include ApplicationHelper
  #GET /projects/
  def index
    @members = Member.find_all_by_project_id(@project)
    @roles = Role.find(:all)
    @users = User.find(:all)
    @users = @users.select{|user| !@members.collect{|member| member.user.id}.include?(user.id)}
    respond_to do |format|
      format.html
    end
  end

  #DELETE /project/:project_identifier/setting/members/:id
  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    @journal = Journal.create(:user_id => current_user.id,
      :journalized_id => @member.id,
      :journalized_type => @member.class.to_s,
      :notes => '',
      :action_type => "deleted",
      :project_id => @project.id)
    render_index_js(t(:successful_deletion))
  end

  def create
    member = Member.create(:project_id => @project.id, :role_id => params[:role], :user_id => params[:user])
    role = Role.find_by_id(params[:role])
    @journal = Journal.create(:user_id => current_user.id,
      :journalized_id => member.id,
      :journalized_type => member.class.to_s,
      :notes => '',
      :action_type => "created",
      :project_id => @project.id)
    JournalDetail.create(:journal_id => @journal.id,
      :property => "Role",
      :property_key => "role_id",
      :old_value => nil,
      :value => role.name
    )
    render_index_js(t(:successful_creation))
  end
  #Others method
  def change_role
    member = Member.find_by_id(params[:member_id])
    role = Role.find_all_by_id([member.role_id,params[:role_id]])
    member.update_column(:role_id, params[:role_id])
    @journal = Journal.create(:user_id => current_user.id,
      :journalized_id => member.id,
      :journalized_type => member.class.to_s,
      :notes => '',
      :action_type => "updated",
      :project_id => @project.id)
    JournalDetail.create(:journal_id => @journal.id,
      :property => "Role",
      :property_key => "role_id",
      :old_value => role[0].name,
      :value => role[1].name
    )
    render_index_js
  end




  #Private methods
  private

  def render_index_js(message = t(:successful_update))
    @members = Member.find_all_by_project_id(@project)
    @roles = Role.find(:all)
    @users = User.find(:all)
    @users = @users.select{|user| !@members.collect{|member| member.user.id}.include?(user.id)}
    respond_to do |format|
      format.js{
        render :update do |page|
          page.replace 'members_content', :partial => 'members/list'
          response.headers['flash-message'] = message
        end}
    end
  end
end

