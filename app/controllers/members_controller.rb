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
    members_roles = Member.find_members_and_roles_by_project_id(@project.id)
    @members = members_roles[:members]
    roles = members_roles[:roles]
    respond_to do |format|
      format.html{render :action => 'index', :locals => {:roles => roles, :users => nil}}
    end
  end

  #DELETE /project/:project_identifier/setting/members/:id
  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    respond_to do |format|
      format.js {respond_to_js :locals => {:id => params[:id]}, :response_header => :success, :response_content => t(:successful_deletion)}
    end
  end

  def new
    members_roles = Member.find_members_and_roles_by_project_id(@project.id)
    ids = members_roles[:members].collect{|member| member.user.id}
    users = User.where("id NOT IN (?)", ids)
    @member = Member.new
    respond_to do |format|
      format.js {respond_to_js :locals => {:roles => members_roles[:roles], :users => users, :new => true}}
    end
  end

  def create
    success = Member.create(:project_id => @project.id, :role_id => params[:role], :user_id => params[:user])
    members_roles = Member.find_members_and_roles_by_project_id(@project.id)
    @members = members_roles[:members]
    roles = members_roles[:roles]
    respond_to do |format|
      format.js {respond_to_js :action => :new, :locals => {:roles => roles, :users => nil, :new => false},:response_header => :success, :response_content => t(:successful_creation)}
    end
  end
  #Others method
  def change_role
    member = Member.find_by_id(params[:member_id])
    change_role_result = member.change_role(params[:value])
    @members = change_role_result[:members]
    respond_to do |format|
      format.js {respond_to_js :response_header => change_role_result[:saved] ? :success : :failure, :response_content =>  change_role_result[:saved] ? t(:successful_update) : t(:failure_operation)}
    end
  end

end

