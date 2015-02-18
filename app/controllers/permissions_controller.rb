# Author: Nicolas Meylan
# Date: 12 oct. 2012
# Encoding: UTF-8
# File: permissions_controller.rb

class PermissionsController < ApplicationController
  include Rorganize::RichController
  include PermissionsHelper
  include Rorganize::Managers::PermissionManager::PermissionManagerHelper
  include Rorganize::Managers::PermissionManager::PermissionListCreator

  before_action { |c| c.add_action_alias= {'update_permissions' => 'list'} }
  before_action :find_permission, only: [:edit, :update, :destroy]
  before_action :check_permission
  before_action { |c| c.menu_context :admin_menu }
  before_action { |c| c.menu_item(params[:controller]) }
  before_action { |c| c.top_menu_item('administration') }

  #GET administration/permissions
  def index
    @roles = Role.all
    respond_to do |format|
      format.html
    end
  end

  #GET administration/permission/new
  def new
    @permission_decorator = Permission.new.decorate
    respond_to do |format|
      format.html { render :new, locals: {controllers: load_controllers} }
    end
  end

  #POST administration/permission/new
  def create
    @permission_decorator = Permission.new(permission_params).decorate
    generic_create_callback(@permission_decorator, permissions_path, {controllers: load_controllers})
  end

  #GET administration/permission/edit/:id
  def edit
    respond_to do |format|
      format.html { render action: 'edit', locals: {controllers: load_controllers} }
    end
  end

  #PUT administration/permission/:id
  def update
    @permission_decorator.attributes = permission_params
    generic_update_callback(@permission_decorator, permissions_path, {controllers: load_controllers})
  end

  #DELETE administration/permission/:id
  def destroy
    generic_destroy_callback(@permission_decorator, permissions_path)
  end

  #Other methods
  def list
    @permissions_decorator = Permission.select('*').decorate(context: {role_name: params[:role_name], controller_list: build_controller_group_hash})
    respond_to do |format|
      format.html { render :list }
    end
  end

  def update_permissions
    @role = Role.find_by_name(params[:role_name].tr('_', ' '))
    saved = @role.update_permissions(params[:permissions])
    if saved
      reload_permission(@role.id)
      respond_to do |format|
        flash[:notice] = t(:successful_update)
        format.html { redirect_to permissions_path }
      end
    else
      list
    end
  end

  private
  def permission_params
    params.require(:permission).permit(Permission.permit_attributes)
  end

  def find_permission
    @permission_decorator = Permission.find(params[:id]).decorate
  end

end

