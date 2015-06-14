# Author: Nicolas Meylan
# Date: 23 oct. 2012
# Encoding: UTF-8
# File: roles_controller.rb

class RolesController < ApplicationController
  include RichController
  before_action :check_permission
  before_action  :find_role, only: [:edit, :destroy, :update]
  before_action { |c| c.menu_context :admin_menu }
  before_action { |c| c.menu_item(params[:controller]) }
  before_action { |c| c.top_menu_item('administration') }

  #Get /administration/roles
  def index
    @roles_decorator = Role.select('*').paginated(@sessions[:current_page], @sessions[:per_page], order('roles.name')).decorate
    respond_to do |format|
      format.html
      format.js { respond_to_js }
    end
  end

  #GET /administration/roles/new
  def new
    @role = Role.new
    load_form_content
    respond_to do |format|
      format.html
    end
  end

  #POST /administration/roles/new
  def create
    @role = Role.create(role_params)
    load_form_content
    generic_create_callback(@role, roles_path)
  end

  #GET /administration/roles/edit/:id
  def edit
    load_form_content
    respond_to do |format|
      format.html
    end
  end

  #PUT /administration/roles/edit/:id
  def update
    @role.attributes = role_params
    load_form_content
    generic_update_callback(@role, roles_path)
  end

  #DELETE /administration/roles/:id
  def destroy
    simple_js_callback(@role.destroy, :delete, @role, {id: params[:id]})
  end

  private
  def role_params
    params.require(:role).permit(Role.permit_attributes)
  end

  def find_role
    @role = Role.includes(:issues_statuses, :assignable_roles).find(params[:id])
  end

  def load_form_content
    @roles = Role.all_non_locked
    @issues_statuses = IssuesStatus.all.includes(:enumeration)
  end
end
