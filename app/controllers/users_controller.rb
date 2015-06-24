# Author: Nicolas Meylan
# Date: 29 sept. 2012
# Encoding: UTF-8
# File: users_controller.rb
# Comment: For administrator panel

require 'shared/history'
class UsersController < ApplicationController
  include RichController

  before_action :find_user, only: [:show, :edit, :update, :destroy]
  before_action :check_permission
  before_action { |c| c.menu_context :admin_menu }
  before_action { |c| c.menu_item(params[:controller]) }
  before_action { |c| c.top_menu_item('administration') }

  #GET /administration/users
  def index
    @users_decorator = User.paginated(@sessions[:current_page], @sessions[:per_page], order('users.name')).decorate
    if request.xhr?
      render json: {list: @users_decorator.display_collection}
    else
      render :index
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
    generic_create_callback(@user, -> { user_path(@user.slug) })
  end

  #Get /administration/users/edit/:id
  def edit
    respond_to do |format|
      format.html
    end
  end

  #Put /administration/users/edit/:id
  def update
    @user.attributes = user_params
    generic_update_callback(@user, -> {@user.reload; user_path(@user.slug)})
  end

  #Get /administration/users/:id
  def show
    @user_decorator = @user.decorate
    @history = History.new(Journal.where(journalizable_type: 'User', journalizable_id: @user_decorator.id).eager_load([:details]))
    respond_to do |format|
      format.html
    end
  end

  #DELETE /administration/users/:id
  def destroy
    generic_destroy_callback(@user, users_path)
  end

  private

  def find_user
    @user = User.find_by_slug!(params[:id])
  end

  def user_params
    params.require(:user).permit(User.permit_attributes)
  end

end