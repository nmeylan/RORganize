# Author: Nicolas Meylan
# Date: 12 oct. 2012
# Encoding: UTF-8
# File: permissions_controller.rb

class PermissionsController < ApplicationController
  include Rorganize::RichController
  include PermissionsHelper
  include Rorganize::Managers::PermissionManager::PermissionManagerHelper
  include Rorganize::Managers::PermissionManager::PermissionListCreator

  before_filter :check_permission, :except => [:update_permissions]
  before_filter { |c| c.menu_context :admin_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('administration') }

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
      format.html { render :new, :locals => {:controllers => load_controllers.values} }
    end
  end

  #POST administration/permission/new
  def create
    @permission_decorator = Permission.new(permission_params).decorate
    respond_to do |format|
      if @permission_decorator.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to :action => 'index', :controller => 'permissions' }
        format.json { render :json => @permission_decorator,
                             :status => :created, :location => @permission_decorator }
      else
        Permission.controller_list
        format.html { render :new }
        format.json { render :json => @permission_decorator.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

  #GET administration/permission/edit/:id
  def edit
    @permission_decorator = Permission.find_by_id(params[:id])
    if @permission_decorator
      @permission_decorator = @permission_decorator.decorate
      respond_to do |format|
        format.html { render :action => 'edit', :locals => {:controllers => load_controllers.values} }
      end
    else
      render_404
    end
  end

  #PUT administration/permission/:id
  def update
    @permission_decorator = Permission.find(params[:id]).decorate
    respond_to do |format|
      if @permission_decorator.update_attributes(permission_params)
        flash[:notice] = t(:successful_update)
        format.html { redirect_to permissions_path }
        format.json { render :json => @permission_decorator,
                             :status => :created, :location => @permission_decorator }
      else

        format.html { render :edit, :locals => {:controllers => load_controllers.values} }
        format.json { render :json => @permission_decorator.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

  #DELETE administration/permission/:id
  def destroy
    @permission = Permission.find(params[:id])
    @permission.destroy
    flash[:notice] = t(:successful_deletion)
    respond_to do |format|
      format.html { redirect_to permissions_path }
      format.js { js_redirect_to (permissions_path) }
    end
  end

  #Other methods
  def list
    @permissions_decorator = Permission.select('*').decorate(context: {role_name: params[:role_name], controller_list: load_controllers})
    respond_to do |format|
      format.html { render :list }
    end
  end

  def update_permissions
    @role = Role.find_by_name(params[:role_name].tr('_', ' '))
    saved = @role.update_permissions(params[:permissions])
    if saved
      reload_permission(@role.id)
      @roles = Role.select('*')
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

end

