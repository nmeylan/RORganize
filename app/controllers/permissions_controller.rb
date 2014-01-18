# Author: Nicolas Meylan
# Date: 12 oct. 2012
# Encoding: UTF-8
# File: permissions_controller.rb

class PermissionsController < ApplicationController
  before_filter :check_permission, :except => [:update_permissions]
  include ApplicationHelper
  include PermissionsHelper
  include Rorganize::PermissionManager::PermissionManagerHelper
  before_filter { |c| c.menu_context :admin_menu }
  before_filter { |c| c.menu_item(params[:controller])}
  before_filter {|c| c.top_menu_item('administration')}

  #GET administration/permissions
  def index
    @roles = Role.all
    respond_to do |format|
      format.html
    end
  end

  #GET administration/permission/new
  def new
    @permission = Permission.new
    respond_to do |format|
      format.html {render :action => 'new', :locals =>{:controllers =>  Permission.controller_list}}
    end
  end

  #POST administration/permission/new
  def create
    @permission = Permission.new(params[:permission])
    respond_to do |format|
      if @permission.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to :action => 'index', :controller => 'permissions'}
        format.json  { render :json => @permission,
          :status => :created, :location => @permission}
      else
        Permission.controller_list
        format.html  { render :action => 'new' }
        format.json  { render :json => @permission.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  #GET administration/permission/edit/:id
  def edit
    @permission = Permission.find_by_id(params[:id])
    controllers = Permission.controller_list
    respond_to do |format|
      format.html {render :action => 'edit', :locals =>{:controllers => controllers}}
    end
  end

  #PUT administration/permission/:id
  def update
    @permission = Permission.find(params[:id])
    respond_to do |format|
      if @permission.update_attributes(params[:permission])
        flash[:notice] = t(:successful_update)
        format.html { redirect_to :action => 'index', :controller => 'permissions'}
        format.json  { render :json => @permission,
          :status => :created, :location => @permission}
      else

        format.html  {render :action => 'edit', :locals =>{:controllers =>  Permission.controller_list}}
        format.json  { render :json => @permission.errors,
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
      format.html { redirect_to permissions_path}
      format.js {js_redirect_to (permissions_path)}
    end
  end
  #Other methods
  def list
    permissions = Permission.permission_list(params[:role_name])
    respond_to do |format|
      format.html {render :action => 'list', :locals => {:permissions => permissions[:permission_hash],:selected_permissions => permissions[:selected_permissions]}}
    end
  end

  def update_permissions
    @role = Role.find_by_name(params[:role_name].gsub('_', ' '))
    saved = @role.update_permissions(params[:permissions])
    if saved
      reload_permission(@role.id)
      @roles = Role.find(:all)
      respond_to do |format|
        flash[:notice] = t(:successful_update)
        format.html { redirect_to :action => 'index', :controller => 'permissions'}
      end
    else
      list
    end
  end

end

