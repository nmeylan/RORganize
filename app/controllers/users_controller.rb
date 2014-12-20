# Author: Nicolas Meylan
# Date: 29 sept. 2012
# Encoding: UTF-8
# File: users_controller.rb
# Comment: For administrator panel

require 'shared/history'
class UsersController < ApplicationController
  include Rorganize::RichController
  before_action :check_permission
  before_action { |c| c.menu_context :admin_menu }
  before_action { |c| c.menu_item(params[:controller]) }
  before_action { |c| c.top_menu_item('administration') }

  #GET /administration/users
  def index
    @users_decorator = User.paginated(@sessions[:current_page], @sessions[:per_page], order('users.name')).decorate
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
    respond_to do |format|
      if @user.save
        success_generic_create_callback(format, user_path(@user.slug))
      else
        error_generic_create_callback(format, @user)
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
    @user.attributes = user_params
    respond_to do |format|
      select_update_callback(format)
    end
  end

  #Get /administration/users/:id
  def show
    @user_decorator = User.find_by_slug(params[:id]).decorate
    @history = History.new(Journal.where(journalizable_type: 'User', journalizable_id: @user_decorator.id).eager_load([:details]))
    respond_to do |format|
      format.html
    end
  end

  #DELETE /administration/users/:id
  def destroy
    @user = User.find_by_slug(params[:id])
    generic_destroy_callback(@user, users_path)
  end

  private
  def select_update_callback(format)
    if !@user.changed?
      success_generic_update_callback(format, user_path(@user.slug), false)
    elsif @user.save
      success_generic_update_callback(format, user_path(@user.slug))
    else
      error_generic_update_callback(format, @user)
    end
  end

  def user_params
    params.require(:user).permit(User.permit_attributes)
  end

end