# Author: Nicolas Meylan
# Date: 10 oct. 2012
# Encoding: UTF-8
# File: profiles_controller.rb

require 'shared/activities'
class ProfilesController < ApplicationController
  include RichController
  before_action :authenticate_user!
  before_action :find_user
  before_action :set_pagination, only: [:custom_queries]
  helper_method :sort_column, :sort_direction
  helper ProjectsHelper
  helper IssuesHelper
  helper QueriesHelper
  helper UsersHelper
  include ActivityCallback
  include ProjectsPreferenceCallback

  def show
    @user_decorator = User.eager_load([members: [:role, :project, assigned_issues: :status]]).find_by_slug(User.current.slug).decorate
    init_activities_sessions
    activities_data = selected_filters
    load_activities(@user_decorator)
    activity_callback(activities_data,:show)
  end

  def activity
    show
  end

  def change_password
    if request.post?
      change_password!
    else
      @user_decorator = @user.decorate
      respond_to do |format|
        format.html {}
      end
    end
  end

  def change_email
    if request.post?
      change_email!
    else
      @user_decorator = @user.decorate
      respond_to do |format|
        format.html
      end
    end
  end

  def change_avatar
    if request.post?
      change_avatar!
    else
      @user_decorator = @user.decorate
      respond_to do |format|
        format.html
      end
    end
  end

  def delete_avatar
    @user.delete_avatar
    flash[:notice] = t(:successful_update)
    respond_to do |format|
      format.js { js_redirect_to change_avatar_profile_path }
    end
  end

  def custom_queries
    @queries_decorator = Query.created_by(@user).eager_load(:user)
                             .paginated(@sessions[:current_page], @sessions[:per_page], order('queries.name'))
                             .decorate(context: {queries_url: custom_queries_profile_path, action_name: 'custom_queries'})
    if request.xhr?
      render json: {list: @queries_decorator.display_collection}
    else
      render :custom_queries
    end
  end

  def projects
    @projects_decorator = @user.owned_projects(nil).decorate(context: {allow_to_sort: true})
    respond_to do |format|
      format.html { render :projects }
    end
  end

  def star_project
    member, message = save_star_project
    js_callback(true, [message], {button: view_context.toggle_star_project_link(params[:project_id], member.is_project_starred)})
  end

  def save_project_position
    update_project_position
    js_callback(true, [t(:successful_update)])
  end

  def spent_time
    if params[:date]
      @date = params[:date].to_date
    else
      @date = Date.today
    end
    time_entries = @user.time_entries_for_month(@date.year, @date.month)
    @time_entries = time_entries.inject(Hash.new { |h, k| h[k] = [] }) { |memo, time_entry| memo[time_entry.spent_on] << time_entry; memo }
    respond_to do |format|
      format.html
      format.js { respond_to_js }
    end
  end

  #OTHER METHODS
  def act_as
    if @user.admin?
      (session['act_as'].nil? || session['act_as'].eql?('User')) ? session['act_as'] = 'Admin' : session['act_as'] = 'User'
      @user.act_as_admin(session['act_as'])
      respond_to do |format|
        format.html { redirect_to :back }
      end
    else
      render_403
    end
  end

  def notification_preferences
    @keys = Preference.notification_keys
    if request.post?
      save_preferences
    else
      @preferences = @user.preferences.where(key: @keys.values)
    end
  end

  def save_preferences
    Preference.delete_all(key: @keys.values, user_id: @user.id)
    if params[:preferences]
      params[:preferences].values.each do |preference_key|
        @user.preferences << Preference.new(key: preference_key.to_i, boolean_value: true)
      end
    end
    @user.save
    respond_to do |format|
      flash[:notice] = t(:successful_preferences)
      format.html { redirect_to action: 'notification_preferences' }
    end
  end

  private
  def find_user
    @user = User.find(User.current.id)
  end

  def user_params
    params.require(:user).permit(User.permit_attributes)
  end


  def change_password!
    if password_match_retype?
      respond_to do |format|
        flash[:notice] = t(:successful_update)
        format.html { redirect_to profile_path }
      end
    else
      @user.errors.add(:passwords, ': do not match')
      respond_to do |format|
        format.html
      end
    end
  end

  def change_email!
    @user.email = user_params[:email]
    respond_to do |format|
      if !@user.email_changed?
        format.html { redirect_to profile_path }
      elsif @user.save
        flash[:notice] = t(:successful_update)
        format.html { redirect_to profile_path }
      else
        format.html
      end
    end
  end

  def change_avatar!
    if user_params[:avatar].nil?
      @user_decorator = @user.decorate
    else
      @user.avatar = Avatar.new(attachable_type: 'User', attachable_id: @user.id)
      @user.avatar.avatar = user_params[:avatar]
      if @user.save_avatar
        flash[:notice] = t(:successful_update)
        respond_to do |format|
          format.html { redirect_to change_avatar_profile_path }
        end
      else
        @user.generate_default_avatar
        @user_decorator = @user.decorate
      end
    end

  end

  def password_match_retype?
    user_params[:password].eql?(user_params[:retype_password]) && @user.update_attributes(password: user_params[:password])
  end

end
