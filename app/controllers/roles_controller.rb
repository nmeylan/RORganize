# Author: Nicolas Meylan
# Date: 23 oct. 2012
# Encoding: UTF-8
# File: roles_controller.rb

class RolesController < ApplicationController
  include Rorganize::RichController
  before_filter :check_permission
  before_filter { |c| c.menu_context :admin_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('administration') }

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
    @issues_statuses = IssuesStatus.all.includes(:enumeration)
    respond_to do |format|
      format.html
    end
  end

  #POST /administration/roles/new
  def create
    @role = Role.new(role_params)
    @role.set_statuses(params[:issues_statuses])

    @issues_statuses = IssuesStatus.select('*').includes(:enumeration)
    generic_create_callback(@role, roles_path)
  end

  #GET /administration/roles/edit/:id
  def edit
    @role = Role.find_by_id(params[:id])
    @issues_statuses = IssuesStatus.select('*').includes(:enumeration)
    respond_to do |format|
      format.html
    end
  end

  #PUT /administration/roles/edit/:id
  def update
    @role = Role.find_by_id(params[:id])
    @role.set_statuses(params[:issues_statuses])
    @role.attributes = role_params
    respond_to do |format|
      if @role.save
        flash[:notice] = t(:successful_update)
        format.html { redirect_to roles_path }
      else
        @issues_statuses = IssuesStatus.select('*').includes(:enumeration)
        format.html { render :edit }
      end
    end
  end

  #DELETE /administration/roles/:id
  def destroy
    @role = Role.find_by_id(params[:id])
    simple_js_callback(@role.destroy, :delete, {id: params[:id]})
  end

  private
  def role_params
    params.require(:role).permit(Role.permit_attributes)
  end
end
