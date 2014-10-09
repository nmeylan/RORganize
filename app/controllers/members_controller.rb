# Author: Nicolas Meylan
# Date: 30 sept. 2012
# Encoding: UTF-8
# File: members_controller.rb

class MembersController < ApplicationController
  include Rorganize::RichController
  before_filter :check_permission
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item('settings') }
  before_filter { |c| c.top_menu_item('projects') }
  #GET /projects/
  def index
    @members_decorator = Member.where(:project_id => @project.id).where('members.role_id <> ?', Role.non_member.id)
    .paginated(@sessions[:current_page], @sessions[:per_page], order('users.name')).fetch_dependencies
    .decorate(context: {project: @project, roles: Role.select('*')})
    respond_to do |format|
      format.html { render :index, :locals => {:users => nil} }
      format.js { respond_to_js }
    end
  end

  #DELETE /project/:project_identifier/setting/members/:id
  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    respond_to do |format|
      format.js { respond_to_js :locals => {:id => params[:id]}, :response_header => :success, :response_content => t(:successful_deletion) }
    end
  end

  def new
    members = Member.eager_load(:user, :role).where(:project_id => @project.id)
    non_member_id = Role.non_member.id
    ids = members.collect { |member| member.user.id unless member.role_id.eql?(non_member_id) }
    users = User.where('users.id NOT IN (?)', ids.compact)
    @member = Member.new
    respond_to do |format|
      format.js { respond_to_js :locals => {:roles => Role.select('*'), :users => users, :new => true} }
    end
  end

  def create
    success = Member.create(:project_id => @project.id, :role_id => params[:role], :user_id => params[:user])
    @members_decorator = Member.where(:project_id => @project.id).where('members.role_id <> ?', Role.non_member.id)
    .paginated(@sessions[:current_page], @sessions[:per_page], order('users.name')).fetch_dependencies
    .decorate(context: {project: @project, roles: Role.select('*')})
    respond_to do |format|
      format.js { respond_to_js :action => :new, :locals => {:users => nil, :new => false}, :response_header => :success, :response_content => t(:successful_creation) }
    end
  end

  #Others method
  def change_role
    member = Member.find_by_id(params[:member_id])
    change_role_result = member.change_role(params[:value])
    @members = change_role_result[:members]
    respond_to do |format|
      format.js { respond_to_js :response_header => change_role_result[:saved] ? :success : :failure, :response_content => change_role_result[:saved] ? t(:successful_update) : t(:failure_operation) }
    end
  end

end

