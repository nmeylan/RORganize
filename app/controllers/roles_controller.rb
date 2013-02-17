# Author: Nicolas Meylan
# Date: 23 oct. 2012
# Encoding: UTF-8
# File: roles_controller.rb

class RolesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_permission
  before_filter { |c| c.menu_context :admin_menu }
  before_filter { |c| c.menu_item(params[:controller])}
  include ApplicationHelper

  #Get /administration/roles
  def index
    @roles = Role.find(:all)
    respond_to do |format|
      format.html
    end
  end

  #GET /administration/roles/new
  def new
    @role = Role.new
    respond_to do |format|
      format.html
    end
  end

  #POST /administration/roles/new
  def create
    @role = Role.new(params[:role])
    respond_to do |format|
      if @role.save
        flash[:notice] = t(:successful_creation)
        format.html {redirect_to :action => 'index'}
      else
        format.html  { render :action => "new" }
        format.json  { render :json => @role.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  #GET /administration/roles/edit/:id
  def edit
    @role = Role.find_by_id(params[:id])
    respond_to do |format|
      format.html
    end
  end

  #PUT /administration/roles/edit/:id
  def update
    @role = Role.find_by_id(params[:id])
    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = t(:successful_update)
        format.html {redirect_to :action => 'index'}
      else
        format.html {render :action => 'edit'}
      end
    end
  end

  #DELETE /administration/roles/:id
  def destroy
    @role = Role.find_by_id(params[:id])
    @role.destroy
    @roles = Role.find(:all)
    respond_to do |format|
      flash[:notice] = t(:successful_deletion)
      format.html {redirect_to :action => 'index'}
      format.js do
        render :update do |page|
          page.replace 'roles_content', :partial => 'roles/list'
        end
      end
    end
  end
end
