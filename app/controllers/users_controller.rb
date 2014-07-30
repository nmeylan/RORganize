# Author: Nicolas Meylan
# Date: 29 sept. 2012
# Encoding: UTF-8
# File: users_controller.rb
# Comment: For administrator panel

require 'shared/history'
class UsersController < ApplicationController
  include Rorganize::RichController
  before_filter :check_permission
  before_filter { |c| c.menu_context :admin_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('administration') }

  #GET /administration/users
  def index
    @users = User.paginated(@sessions[:current_page], @sessions[:per_page], order('users.name')).decorate
    respond_to do |format|
      format.html
      format.js { respond_to_js }

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
    @user = User.new(user_params)
    @user.created_at = Time.now.to_formatted_s(:db)
    @user.updated_at = Time.now.to_formatted_s(:db)
    @user.admin = user_params[:admin]
    respond_to do |format|
      if @user.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to :action => 'show', :controller => 'users', :id => @user }
        format.json { render :json => @user,
                             :status => :created, :location => @user }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  #Get /administration/users/edit/:id
  def edit
    @user = User.find_by_slug(params[:id])
    respond_to do |format|
      format.html
    end
  end

  #Put /administration/users/edit/:id
  def update
    @user = User.find_by_slug(params[:id])
    @user.admin = (user_params[:admin].eql?('1'))
    user_params[:updated_at] = Time.now.to_formatted_s(:db)
    @user.attributes = user_params
    respond_to do |format|
      if !@user.changed?
        format.html { redirect_to :action => 'show', :controller => 'users', :id => @user }
        format.json { render :json => @user,
                             :status => :created, :location => @user }
      elsif @user.save
        flash[:notice] = t(:successful_update)
        format.html { redirect_to :action => 'show', :controller => 'users', :id => @user }
        format.json { render :json => @user,
                             :status => :created, :location => @user }
      else
        format.html { render :action => 'edit' }
        format.json { render :json => @user.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

  #Get /administration/users/:id
  def show
    @user = User.find_by_slug(params[:id]).decorate
    @history = History.new(Journal.where(:journalized_type => 'User', :journalized_id => @user.id).eager_load([:details]))
    respond_to do |format|
      format.html
    end
  end

  #DELETE /administration/users/:id
  def destroy
    @user = User.find_by_slug(params[:id])
    @user.destroy
    flash[:notice] = t(:successful_deletion)
    respond_to do |format|
      format.html { redirect_to users_path }
      format.js { js_redirect_to(users_path) }
    end
  end


  private

  def user_params
    params.require(:user).permit(User.permit_attributes)
  end

end