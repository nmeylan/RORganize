# Author: Nicolas Meylan
# Date: 29 sept. 2012
# Encoding: UTF-8
# File: users_controller.rb
# Comment: For administrator panel

class UsersController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :check_permission, :except => [:update_permissions]
  before_filter { |c| c.menu_context :admin_menu }
  before_filter { |c| c.menu_item(params[:controller])}
  before_filter {|c| c.top_menu_item("administration")}

  include ApplicationHelper
  require 'will_paginate'
  #GET /administration/users
  def index
    params[:per_page] ? session['controller_users_per_page'] = params[:per_page] : session['controller_users_per_page'] = (session['controller_users_per_page'] ? session['controller_users_per_page'] : 25)
    @users = User.paginated_users(params[:page], session['controller_users_per_page'], sort_column + " " + sort_direction)
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.replace "users_content", :partial => 'users/list'
        end
      end
    end
  end

  #Get /administration/users/new
  def new
    @user = User.new
    respond_to do |format|
      format.html
    end
  end

  #Post /administration/users/new
  def create
    @user = User.new(params[:user])
    @user.created_at = Time.now.to_formatted_s(:db)
    @user.updated_at = Time.now.to_formatted_s(:db)
    @user.admin = params[:user][:admin]
    respond_to do |format|
      if @user.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to :action => 'show', :controller => 'users', :id => @user}
        format.json  { render :json => @user,
          :status => :created, :location => @user}
      else
        format.html  { render :action => "new" }
        format.json  { render :json => @user.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  #Get /administration/users/edit/:id
  def edit
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  #Put /administration/users/edit/:id
  def update
    @user = User.find(params[:id])
    @user.admin = (params[:user][:admin].eql?("1"))
    params[:user][:updated_at] = Time.now.to_formatted_s(:db)
    @user.attributes=params[:user]
    respond_to do |format|
      if !@user.changed?
        format.html { redirect_to :action => 'show', :controller => 'users', :id => @user }
        format.json  { render :json => @user,
          :status => :created, :location => @user}
      elsif @user.save
        flash[:notice] = t(:successful_update)
        format.html { redirect_to :action => 'show', :controller => 'users', :id => @user}
        format.json  { render :json => @user,
          :status => :created, :location => @user}
      else
        format.html  { render :action => "edit" }
        format.json  { render :json => @user.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  #Get /administration/users/:id
  def show
    @user = User.find(params[:id])
    @journals = Journal.find_all_by_journalized_type_and_journalized_id(@user.class.to_s, @user, :include => [:details])
    respond_to do |format|
      format.html
    end
  end

  #DELETE /administration/users/:id
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = t(:successful_deletion)
    respond_to do |format|
      format.html { redirect_to users_path}
      format.js do
        render :update do |page|
          page.redirect_to users_path
        end
      end
    end
  end



  private
  def sort_column
    params[:sort] ? session['controller_users_sort'] = params[:sort] : session['controller_users_sort'] = (session['controller_users_sort'] ? session['controller_users_sort'] : 'id')
    session['controller_users_sort']
  end

  def sort_direction
    params[:direction] ? session['controller_users_direction'] = params[:direction] : session['controller_users_direction'] = (session['controller_users_direction'] ? session['controller_users_direction'] : 'desc')
    session['controller_users_direction']
  end

end