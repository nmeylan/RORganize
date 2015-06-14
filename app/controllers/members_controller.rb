# Author: Nicolas Meylan
# Date: 30 sept. 2012
# Encoding: UTF-8
# File: members_controller.rb

class MembersController < ApplicationController
  include RichController
  before_action :check_permission
  before_action :find_member, only: [:change_role]
  before_action :check_change_member_role, only: [:change_role, :create]
  before_action { |c| c.menu_context :project_menu }
  before_action { |c| c.menu_item('settings') }
  before_action { |c| c.top_menu_item('projects') }
  #GET /projects/
  def index
    load_members
    respond_to do |format|
      format.html { render :index, locals: {users: nil} }
      format.js { respond_to_js }
    end
  end

  #DELETE /project/:project_identifier/setting/members/:id
  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    respond_to do |format|
      format.js { respond_to_js locals: {id: params[:id]}, response_header: :success, response_content: t(:successful_deletion) }
    end
  end

  def new
    users = @project.non_member_users
    @member = Member.new
    respond_to do |format|
      format.js { respond_to_js locals: {roles: User.current.allowed_roles(@project), users: users, new: true} }
    end
  end

  def create
    success = Member.create(project_id: @project.id, role_id: params[:member][:role_id], user_id: params[:member][:user_id])
    load_members
    respond_to do |format|
      format.js { respond_to_js action: :new, locals: {users: nil, new: false}, response_header: :success, response_content: t(:successful_creation) }
    end
  end

  #Others method
  def change_role
    change_role_result = @member.change_role(params[:value])
    @members = change_role_result[:members]
    respond_to do |format|
      format.js { respond_to_js response_header: change_role_result[:saved] ? :success : :failure, response_content: change_role_result[:saved] ? t(:successful_update) : t(:failure_operation) }
    end
  end

  private

  def find_member
    @member = @project.members.includes(:role).find(params[:member_id])
  end

  def check_change_member_role
    role_id = params[:member] ? params[:member][:role_id] : params[:role_id]
    role_id = role_id || params[:value]
    new_role = Role.find_by_id(role_id)
    if !User.current.admin_act_as_admin? && not_allowed_to_grant_this_role?(new_role)
      render_403
    end
  end

  def not_allowed_to_grant_this_role?(new_role)
    allowed_roles = User.current.allowed_roles(@project)
    # Does user can't grant this role or try (by modify html) to downgrade a coworker role.
    !allowed_roles.include?(new_role) || (!@member.nil? && !allowed_roles.include?(@member.role))
  end

  def load_members
    @members_decorator = Member.members_by_project(@project.id, @sessions[:current_page], @sessions[:per_page], order('users.name'))
                             .decorate(context: {project: @project, roles: User.current.allowed_roles(@project)})
  end

end

