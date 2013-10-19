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
    controller_list
    @permission = Permission.new
    respond_to do |format|
      format.html
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
        controller_list
        format.html  { render :action => 'new' }
        format.json  { render :json => @permission.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  #GET administration/permission/edit/:id
  def edit
    @permission = Permission.find(params[:id])
    controllers = controller_list
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
        controller_list
        format.html  { render :action => 'edit' }
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
      format.js do
        render :update do |page|
          page.redirect_to permissions_path
        end
      end
    end
  end
  #Other methods
  def list
    controllers = controller_list
    permission_hash = Hash.new{|h,k| h[k] = {}}
    role = Role.find_by_name(params[:role_name].gsub('_', ' '))
    selected_permissions = role.permissions.collect{|permission| permission.id}
    permissions = Permission.find(:all)
    tmp_ary = []
    tmp_hash = {}
    controllers.each do |controller|
      tmp_ary = permissions.select{ |permission| permission.controller.eql?(controller)}
      tmp_ary.each do |permission|
        tmp_hash[permission.name] = permission.id
      end
     permission_hash[controller] = tmp_hash
      tmp_hash = {}
    end
    respond_to do |format|
      format.html {render :action => 'list', :locals => {:permissions => permission_hash, :selected_permissions => selected_permissions}}
    end
  end

  def update_permissions
    @role = Role.find_by_name(params[:role_name].gsub('_', ' '))
    if params[:permissions]
      permissions_id = params[:permissions].values
      permissions = Permission.find_all_by_id(permissions_id)
      @role.permissions.clear
      permissions_id.each do |permission_id|
        permission = permissions.select{|perm| perm.id == permission_id.to_i }
        @role.permissions << permission
      end
    end
    if @role.save
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
  private
  def controller_list
    controllers =  Rails.application.routes.routes.collect{|route| route.defaults[:controller]}
    unused_controller = %w(rorganize my)
    controllers = controllers.uniq!.select{|controller_name| controller_name && !controller_name.match(/.*\/.*/) && !unused_controller.include?(controller_name)}
    controllers.collect! do |controller|
      controller = controller.capitalize
    end
    return controllers
  end
end

